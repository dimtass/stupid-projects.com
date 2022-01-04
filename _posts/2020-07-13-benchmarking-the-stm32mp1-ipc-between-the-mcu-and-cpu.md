---
title: Benchmarking the STM32MP1 IPC between the MCU and CPU (part 1)
date: 2020-07-13T16:07:32+00:00
author: dimtass
layout: post
categories: ["Post series"]
tags: ["STM32", "STM32MP1", "Embedded Linux", "Benchmarks", "SBC"]
img_src: "/images"
img_width: 580
img_extras: ".shadow"
---
## Intro

_Update: The second part is [here]({% post_url 2020-07-18-benchmarking-the-stm32mp1-ipc-between-the-mcu-and-cpu-part-2 %})._

Long time no see. Well, having two babies at home is really not recommended for personal stupid projects. Nevertheless, I've found some time to dive into the [STM32MP157C-DK2](https://www.st.com/en/evaluation-tools/stm32mp157c-dk2.html) dev kit that I've received recently from ST. Let me say beforehand, that this is a really great board and of course it has it's cons and pros, which I will mention later in this post. Although it's being a year that this board has been released I didn't had the chance to use it and I'm glad I received this sample.

I need to mention that this post is not an introduction to the dev kit and it's a bit advanced as it deals with more advanced concepts. One thing I like with some new SoCs that were released the last couple of years, is the integrated MCU aside with the CPU, which shares the same resources and peripherals. This is a really powerful option and it allows you to split your functionality to real-time and critical application that run on the MCU and more advanced userspace applications that run on Linux on the CPU.

The MCU is an STM32 ARM Cortex-M4 core (CM4) running at 209MHz and the application CPU is a dual Cortex-A7 (CA7) running at 650MHz. Well, yes, this is a fast CM4 and a slow CA7. As I've said those two can share almost all the same peripherals and the OpenAMP API is used as an IPC to exchange data between those two.

I have quite some experience working with real-time Linux kernels and I really like this concept, that's why I always support a PREEMPT-RT (P-RT) kernel to my [meta-allwinner-hx](https://gitlab.com/dimtass/meta-allwinner-hx) Yocto meta layer. Although the P-RT is really nice to have when a low latency is needed, it's still far too bloated and slow compared to a baremetal firmware running on an MCU. I won't get into the details of this, because I think it's obvious. Therefore, the STM32MP1 and other similar SoCs combine the best of the those two worlds and you can use the CM4 for critical timing applications and the CA7 for everything else, like the GUI, networking, remote updates e.t.c.

In case of STM32MP1 the [OpenAMP](https://github.com/OpenAMP/open-amp) framework is used for the IPC between the CM4 and CA7. When I've went through the docs for the STM32MP1 the first thing it came to my mind is to benchmark and evaluate its performance and this series of post is about getting into this and find out what are the options you have and how good they perform.

## Reading the docs

One thing I like about ST is the very good documentation. Well, tbh it's far from excellent but it's better compared to other documentation I've seen. Generally, bad or missing documentation is a well know problem with almost all vendors and in my opinion Texas Instruments and ST are far better compare to other vendors (I'll exclude NXP imx6, which is also well documented).

When you start with a new SoC and you already have experience with other SoCs then it's easier to retrieve valuable information faster and also search for specific information you know it's important. Nevertheless, I really enjoyed getting into the STM32MP1 documentation in the [wiki](https://wiki.st.com/stm32mpu/wiki/Development_zone), because I found really good explanations for the Linux graphic stack, trusted firmware, OS-TEE and the boot chain. For example have a look to the DRM/KMS overview [here](https://wiki.st.com/stm32mpu/wiki/DRM_KMS_overview), it's really good.

Of course there are many things that are missing from the docs, but I need also to say that this is a quite complex SoC and there are so many tools and frameworks involved in the development process that it would need tens of thousands of pages to explain everything and this is not manageable even for ST. For example, you'll find your self lost the moment you want to create your own Yocto distro as there is very few info on how to do that and that's the reason I've decided to write a template bsp layer that greatly simplifies the process.

## Contributions

While getting a dive into the SoC, I couldn't help my self not to fix some things, therefore I've did some contributions, like [this](https://github.com/STMicroelectronics/meta-st-stm32mp/pull/14#issuecomment-620623682) and [this](https://github.com/STMicroelectronics/meta-st-stm32mp/pull/13#issuecomment-620483337) and I've also created this meta layer [here](https://github.com/dimtass/meta-stm32mp1-bsp-base). I'm also planning to contribute with a kernel module and a userspace application that will use netlink between the userspace and the kernel module, but I'll explain why later. This will be demonstrated in the next post, though as it's related to the IPC performance.

## IPC options

OK, so let's now see what are the current options that you get with the STM32MP1 when it comes to IPC between the CM4 and CA7. I've already mentioned the OpenAMP which ST names it the direct buffer exchange mode, but you can also use an indirect buffer exchange mode. Both are well explained [here](https://wiki.st.com/stm32mpu/wiki/Exchanging_buffers_with_the_coprocessor), but I'll add a couple of more information here.

Generally, the OpenAMP has a weakness which is integrated to the implementation and this is the hard-coded buffer size limitation, which is set to 512 bytes. We'll see later how this affects the transfer speed, but as you can imagine this size might not be enough in some cases. Therefore, before you decide which IPC option you're going to choose you need to be sure how many data and how fast you need to share between the CM4 and CA7.

Another problem with OpenAMP is that there's no zero-copy or DMA support, which means that buffers are copied from all ends and therefore the performance is expected to be affected by this. On top of that the buffers are not cacheable, which means further CPU cycles for fetching buffers and then copy them.

OpenAMP comes with 2 examples/implementations in the SDK. The first is a TTY device on the Linux side, which means that you transfer can data from/to the userspace by interfacing a tty com port. You can see this implementation [here](https://github.com/STMicroelectronics/STM32CubeMP1/tree/master/Projects/STM32MP157C-DK2/Applications/OpenAMP/OpenAMP_TTY_echo). If that sounds bad to you, then it is actually as bad as it sounds, because exchanging data that way really sucks, especially on the Linux side (interfacing a tty with code). The only way I think this is useful and makes sense is if you port your existing code from a device that used a CPU and an external MCU and they were exchanging data via a UART port. Otherwise, it doesn't make much sense to use it. Nevertheless, being loyal to the blog's name I've spent some time to implement this and see how it performs. More about this later.

The second implementation is the OpenAMP raw, which you can use a kernel module to interface with the CM4 and the firmware implementation is [here](https://github.com/STMicroelectronics/STM32CubeMP1/tree/master/Projects/STM32MP157C-DK2/Applications/OpenAMP/OpenAMP_raw). In order to exchange data with the userspace in this case you need a kernel module like this one [here](https://github.com/torvalds/linux/blob/master/samples/rpmsg/rpmsg_client_sample.c). But as you can see, this is pretty much useless because you can't interface with the module from the userspace, therefore you need to write your own module and use ioctl or netlink (or anything else you like). But more about this on the next post. (Edit: actually I've seen that ST provides a module with IOCTL support [here](https://github.com/STMicroelectronics/meta-st-stm32mpu-app-logicanalyser/blob/thud/recipes-kernel/rpsmg-sdb-mod/files/stm32_rpmsg_sdb.c)).

On the other hand, there is also the indirect buffer option, which compared to the OpenAMP, it allows sharing much larger buffers (of any size), in cached memory, with zero-copy and also using DMA. This option is expected to perform much faster compared to OpenAMP and with much lower latency. To be honest, this sounds like a no-brainer to use for me in most cases, except in case that you just need to exchange very few control commands. I mean it makes sense for the last case, because you need OpenAMP even in the indirect buffer mode, because you use that as a control interface for the shared buffer anyway.

## Creating a Yocto image

In order to use or test any of the above things you need to build and flash a distro for the board. Here I can complain about the non-existence documentation on how to do this. In my case, that was not really an issue, but I guess many devs will eventually struggle with this. For that reason, I've created a BSP base layer for the STM32MP157C-DK2 board. This post though is not focused on how to deal with the Yocto distro, so I'll explain those things quite fast so I can proceed further.

To build the distro I've used, you need this repo here:

  - [https://bitbucket.org/dimtass/meta-stm32mp1-bsp-base/src/master/](https://bitbucket.org/dimtass/meta-stm32mp1-bsp-base/src/master/)  
  - [https://github.com/dimtass/meta-stm32mp1-bsp-base](https://github.com/dimtass/meta-stm32mp1-bsp-base)  
  - [https://gitlab.com/dimtass/meta-stm32mp1-bsp-base](https://gitlab.com/dimtass/meta-stm32mp1-bsp-base)

The README file in the repo is quite thorough. So, in order to build the image you need to create a folder and run this command:

```sh
cd stm32mp1-yocto
repo init -u https://bitbucket.org/dimtass/meta-stm32mp1-bsp-base/src/master/default.xml
repo sync
```

This will fetch all the needed repos and place them in the `sources/` folder. Then in order to build the image you need to run these commands:

```sh
ln -s sources/meta-stm32mp1-bsp-base/scripts/setup-environment.sh .
MACHINE=stm32mp1-discotest DISTRO=openstlinux-eglfs source ./setup-environment.sh build
bitbake stm32mp1-qt-eglfs-image
```

Your host needs to have all the needed dependencies in order to build the image. If this is the first time you do this, then better use a docker image instead like this one [here](https://hub.docker.com/repository/docker/dimtass/yocto-docker-image). I've made this docker image to build the meta-allwinner-hx repo, but you can use the same for this repo, like this:

```sh
docker build --build-arg userid=$(id -u) --build-arg groupid=$(id -g) -t allwinner-yocto-image .
docker run -it --name allwinner-builder -v $(pwd):/docker -w /docker allwinner-yocto-image bash
MACHINE=stm32mp1-discotest DISTRO=openstlinux-eglfs source ./setup-environment.sh build
bitbake stm32mp1-qt-eglfs-image
```

If you want to build the SDK to use it for compiling other code then run this:

```sh
bitbake -c populate_sdk stm32mp1-qt-eglfs-image
```

Then you can install the produced SDK to your /opt folder and then source it to build any code you might want to test.

## Benchmark tool code

Assuming that you have the above image built, then you can flash it in the target and run the test. There is a brief explanation how to flash the image to the dev kit in the meta-stm32mp1-bsp-base repo README.md file. So, after the image is flashed the firmware for the CM4 is located in `/lib/firmware/stm32mp157c-rpmsg-test.elf`. Also there is a script and an executable in `/home/root`. The recipes that install those files are located in `meta-stm32mp1-bsp-base/recipes-extended/stm32mp1-rpmsg-test`.

The code is located in this repo:

  - [https://bitbucket.org/dimtass/stm32mp1-rpmsg-test/src/master/](https://bitbucket.org/dimtass/stm32mp1-rpmsg-test/src/master/)
  - [https://github.com/dimtass/stm32mp1-rpmsg-test](https://github.com/dimtass/stm32mp1-rpmsg-test)
  - [https://gitlab.com/dimtass/stm32mp1-rpmsg-test](https://gitlab.com/dimtass/stm32mp1-rpmsg-test)

This repo contains both the CM4 firmare and the CA7 linux userspace tool. The userspace tool is using the `/dev/ttyRPMSG0` tty port to send blocks of data. As you can see [here](https://github.com/dimtass/stm32mp1-rpmsg-test/blob/master/CA-source/main.cpp#L22), I'm creating some tests on the runtime with several block sizes and I'm sending those blocks a number of times. For example, see the following:

```c
tester.add_test(512, 1);
tester.add_test(512, 2);
tester.add_test(512, 4);
tester.add_test(512, 8);
```

The first line sends a block of 512 bytes one time. The second sends the 512 block two times, e.t.c. In the code, you'll see that there are some code lines that are commented out. The reason for that is that I've found that I couldn't send more than 5-6KB per run and it seems that OpenAMP is hanging on the kernel side and I need to open/close the tty port to send more data. As I've mentioned the buffer size in OpenAMP is hardcoded and it's 512 bytes, therefore I assume that the ringbuffer is overflowing at some point and the execution hangs, but I don't know the real reason. Therefore, I wasn't able to test more that 5KB.

The code for interfacing the com port is in [here](https://github.com/dimtass/stm32mp1-rpmsg-test/blob/master/CA-source/serial_linux.cpp). I guess this class would be very useful to you if you want to interface with the ttyRPMSG in your code, as I've used it many times and it seems robust. Also it's simple to use and integrate it to your code.

Finally, the test class is [here](https://github.com/dimtass/stm32mp1-rpmsg-test/blob/master/CA-source/tty_tester.cpp) and I'm using a simple protocol with a header that contains a preamble and the length of the packet data. This simplifies the CM4 firmware as it knows how much data to wait for and then acknowledge when the whole packet is received. Be aware then when you sent a 512 bytes block, then those data doesn't arrive at once on the CM4 on a single callback, but OpenAMP may trigger more that one interrupts for the whole block, therefore knowing the length of the data in the start of transaction is important.

On the CM4 side, the firmware is located in [here](https://github.com/dimtass/stm32mp1-rpmsg-test/tree/master/source/src_hal). The interesting code is in the main.c file and actually the most important function is the tty callback in [here](https://github.com/dimtass/stm32mp1-rpmsg-test/blob/master/source/src_hal/main.c#L347), so I'll also list the code here.

```c
void VIRT_UART0_RxCpltCallback(VIRT_UART_HandleTypeDef *huart)
{

  /* copy received msg in a variable to sent it back to master processor in main infinite loop*/
  uint16_t recv_size = huart->RxXferSize < MAX_BUFFER_SIZE? huart->RxXferSize : MAX_BUFFER_SIZE-1;

  struct packet* in = (struct packet*) &huart->pRxBuffPtr[0];
  if (in->preamble == PREAMBLE) {
    in->preamble = 0;
    virt_uart0_expected_nbytes = in->length;
    log_info("length: %d\n", virt_uart0_expected_nbytes);                        
  }

  virt_uart0.rx_size += recv_size;
  log_info("UART0: %d/%d\n", virt_uart0.rx_size, virt_uart0_expected_nbytes);
  if (virt_uart0.rx_size >= virt_uart0_expected_nbytes) {
    virt_uart0.rx_size = 0;
    virt_uart0.tx_buffer[0] = virt_uart0_expected_nbytes & 0xff;
    virt_uart0.tx_buffer[1] = (virt_uart0_expected_nbytes >> 8) & 0xff;
    log_info("UART0 resp: %d\n", virt_uart0_expected_nbytes);
    virt_uart0_expected_nbytes = 0;
    virt_uart0.tx_size = 2;
    virt_uart0.tx_status = SET;
    // huart->RxXferSize = 0;
  }
}
```

As you can see in this callback the code looks for the preamble and if it's found then it copies the expected bytes length. Then the interrupt may triggered multiple times and when all bytes arrive, then the CM4 sends back a response that includes the bytes number and then the userspace application verifies that all bytes where sent. It's as simple as that.

## Benchmark results

To run the test you need to cd to the /home/root directory and then run this script.

```sh
./fw_cortex_m4.sh start
```

This will load the firmware that is stored in `/lib/firmware` to the CM4 and execute it. When this happend you should see this in your serial console:

```
fw_cortex_m4.sh: fmw_name=stm32mp1-rpmsg-test.elf
[  162.549297] remoteproc remoteproc0: powering up m4
[  162.588367] remoteproc remoteproc0: Booting fw image stm32mp1-rpmsg-test.elf, size 704924
[  162.596199]  mlahb:m4@10000000#vdev0buffer: assigned reserved memory node vdev0buffer@10042000
[  162.607353] virtio_rpmsg_bus virtio0: rpmsg host is online
[  162.615159]  mlahb:m4@10000000#vdev0buffer: registered virtio0 (type 7)
[  162.620334] virtio_rpmsg_bus virtio0: creating channel rpmsg-tty-channel addr 0x0
[  162.622155] rpmsg_tty virtio0.rpmsg-tty-channel.-1.0: new channel: 0x400 -> 0x0 : ttyRPMSG0
[  162.633298] remoteproc remoteproc0: remote processor m4 is now up
[  162.648221] virtio_rpmsg_bus virtio0: creating channel rpmsg-tty-channel addr 0x1
[  162.671119] rpmsg_tty virtio0.rpmsg-tty-channel.-1.1: new channel: 0x401 -> 0x1 : ttyRPMSG1
```

This means that the kernel module is loaded, the two ttyRPMSG devices are created in /dev, firmware is loaded on the CM4 and the firmware code is executed. In order to verify that the firmware is working you can use a USB to UART module and connect the Rx pin to the D0 and the Tx pin to the D1 (UART7) of the Arduino compatible header in the bottom on the board. When the firmware is booted you should see this:

```sh
[00000.008][INFO ]Cortex-M4 boot successful with STM32Cube FW version: v1.2.0 
[00000.016][INFO ]MAX_BUFFER_SIZE: 32768
[00000.019][INFO ]Virtual UART0 OpenAMP-rpmsg channel creation
[00000.025][INFO ]Virtual UART1 OpenAMP-rpmsg channel creation
```

Now you can execute the benchmark tool on the userspace by running this command in the console:

```sh
./tty-test-client /dev/ttyRPMSG0
```

Then the benchmark is executed and you'll see the results on both consoles (CM4 and CA7). The CA7 output will be something like this:

```
- 15:43:54.953 INFO: Application started
- 15:43:54.954 INFO: Connected to /dev/ttyRPMSG0
- 15:43:54.962 INFO: Initialized buffer with CRC16: 0x1818
- 15:43:54.962 INFO: ---- Creating tests ----
- 15:43:54.962 INFO: -> Add test: block=512, blocks: 1
- 15:43:54.962 INFO: -> Add test: block=512, blocks: 2
- 15:43:54.962 INFO: -> Add test: block=512, blocks: 4
- 15:43:54.963 INFO: -> Add test: block=512, blocks: 8
- 15:43:54.963 INFO: -> Add test: block=1024, blocks: 1
- 15:43:54.964 INFO: -> Add test: block=1024, blocks: 2
- 15:43:54.964 INFO: -> Add test: block=1024, blocks: 4
- 15:43:54.964 INFO: -> Add test: block=1024, blocks: 5
- 15:43:54.964 INFO: -> Add test: block=2048, blocks: 1
- 15:43:54.964 INFO: -> Add test: block=2048, blocks: 2
- 15:43:54.964 INFO: -> Add test: block=4096, blocks: 1
- 15:43:54.964 INFO: ---- Starting tests ----
- 15:43:54.977 INFO: -> b: 512, n:1, nsec: 11970765, bytes sent: 512
- 15:43:54.996 INFO: -> b: 512, n:2, nsec: 18770380, bytes sent: 1024
- 15:43:55.027 INFO: -> b: 512, n:4, nsec: 31022063, bytes sent: 2048
- 15:43:55.083 INFO: -> b: 512, n:8, nsec: 56251848, bytes sent: 4096
- 15:43:55.099 INFO: -> b: 1024, n:1, nsec: 15322572, bytes sent: 1024
- 15:43:55.124 INFO: -> b: 1024, n:2, nsec: 24824116, bytes sent: 2048
- 15:43:55.168 INFO: -> b: 1024, n:4, nsec: 43830248, bytes sent: 4096
- 15:43:55.221 INFO: -> b: 1024, n:5, nsec: 53327292, bytes sent: 5120
- 15:43:55.243 INFO: -> b: 2048, n:1, nsec: 21742144, bytes sent: 2048
- 15:43:55.281 INFO: -> b: 2048, n:2, nsec: 37633885, bytes sent: 4096
- 15:43:55.318 INFO: -> b: 4096, n:1, nsec: 37649011, bytes sent: 4096
```

The results are starting after the `Starting tests` string and b is the block size, n is the number of blocks and nsec is the number of nanoseconds that the whole transaction lasted. I've used the linux precision timers, which they're not very precise compared to the CM4 timers, but it's enough for this test since the times are in the range of milliseconds. I'm also listing the results in the next table.


Block size	| # of blocks	| msec
512	| 1 |	11.97
512	| 2 |	18.77
512	| 4 |	31.02
512	| 8 |	56.25
1024 |	1	| 15.32
1024 |	2	| 24.82
1024 |	4	| 43.83
1024 |	5	| 53.32
2048 |	1	| 21.74
2048 |	2	| 37.63
4096 |	1	| 37.64

The results are interesting enough. As you can see, size matters! So, the larger the block size the faster the transfer rate. Therefore sending 4KB of data from the CA7 to the CM4 in 8x 512 blocks needs 56.25 ms and in case of 1x 4096 takes 37.64, which is 40% faster with the bigger block size.

Also another interesting result is that in the best case the transfer rate is 4096 bytes in 37.64 msec, or 106 KB/sec. That's too slow!

To sum up the results, you can see that in case you want to use the direct buffer exchange mode (OpenAMP tty) then you're limited at ~106KB/sec and in order to achieve this speed you need the largest possible block size.

## Conclusions

In this post I've provided a simple BSP base Yocto layer that it might be helpful for you to start a new STM32MP1 project. I've used this Yocto image to build a benchmark tool and test the direct buffer exchange mode and the firmware and the userspace tool is are included in recipes in the BSP base repo.

The results are a bit disappointing when it comes to performance and I've found out that the larger the block size, then the transfer speed gets better. That means that you use this mode when sending a small amount of data (e.g. control commands) or if you want to port an application in STM32MP1m that it was running on a separate CPU and MCU before. If you need better performance then the indirect mode seems to be better, but I'll verify this on a future post.

In the next post I'll be using again the direct mode, but this time I'll write a small kernel driver module using netlink and test if there's any better performance. I don't expect much out of this, but I want to do this anyways because I find using a tty interface to a modern program a bit cumbersome to handle and netlink is a more elegant solution.

In the conclusions section I would also like to list some pros/cons of the STM32MP157C-DK2 board (and MP1 SoC).

**Pros:**
  - Very good Yocto support
  - Great documentation and datasheets
  - Many examples and code for the CM4
  - Support for OP-TEE secure RTOS
  - Very good power management (supported in both CM4 and CA7)
  - GbE
  - WiFi & BT 4.1
  - Arduino V3 connector
  - The CM4 firmware can be uploaded during boot (in u-boot) or in Linux
  - DSI display with touch
  - Direct and indirect buffer sharing mode
  - Provides an AI acceleration API (supports also TF-Lite)
  - Great and mature development tools

**Cons:**
  - The CA7 has a low clock (which tbh doesn’t mean that this is bad, for many cases this is a good thing).
  - You can’t use DSI and HDMI at the same time.
  - IPC is not that fast (in direct mode only)
  - The 40-pin expansion connector is under the LCD and it’s hard to reach and fit the cables. It would be better if it had a 90 degree angle connector.
  - Generally because the LCD takes the whole one side of the board this makes it difficult to use also the Arduino connector. Therefore, you need to put the board on the LCD side and use the HDMI. Well, they couldn’t done much for this, but…
  - The packaging box could be done in a way that can be used as a leveled base that make the Arduino connector accessible. Something like the nVidia nano packaging box.
  - Yocto documentation is lacking and it will be difficult for non experienced developers to get started with (but that’s also a generic issue with Yocto as the documentation is also not complete and also some important features are not documented).
  - No CMake support in the examples. Generally, I prefer CMake for many reasons and I like for example the NXP provides their SDK with CMake instead of Makefiles (personal preference I guess, but CMake is also widely used in most of the projects I’ve worked with).

Overall, this is a great and complicated board and it takes some effort to setup and optimize everything. Even more it's quite complicated to do a design from the scratch in a small team, therefore if you decline from the default design you might need more time to configure everything properly and bring up your custom board. Although, I would be able to handle a full custom design with this board, I know it would take a lot of time to finalize it. Therefore, if you don't use one of the many available ready solutions with the STM32MP1 SoC, then have in mind that it will take some effort to do your custom solution. It's up to you to decide the development cost of a full custom design or use one of the many available SoCs that can help you start in no time.

I would definitely take this SoC into account for applications that need good real-time performance (using the CM4 core) and use the CA7 core for the GUI and business logic. If you wonder what's the difference with a multi-core ARM CPU that runs multiple cores in high frequency, then you can take as granted that -depending your use-case- even a PREEMPT-RT kernel on a 8-core running at 2GHz, can't beat the real-time performance of a 200MHz CM4.

Have fun!