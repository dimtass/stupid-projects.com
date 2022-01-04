---
title: Benchmarking the STM32MP1 IPC between the MCU and CPU (part 2)
date: 2020-08-04T10:34:42+00:00
author: dimtass
layout: post
categories: ["Post series"]
tags: ["STM32", "STM32MP1", "Embedded Linux", "Benchmarks", "SBC"]
img_src: "/images"
img_width: 580
img_extras: ".shadow"
---
### Intro

In this post series I'm benchmarking the IPC between the Cortex-A7 (CA7) and the Cortex-M4 (CM4) of the STM32MP1 SoC. In the previous post [here]({% post_url 2020-07-13-benchmarking-the-stm32mp1-ipc-between-the-mcu-and-cpu %}), I've tested the default OpenAMP TTY driver. This IPC method is the direct buffer sharing mode, because the OpenAMP is used as the buffer transfer API. After my tests I've verified that this option is very slow for large data transfers. Also, a TTY interface is not really an ideal interface to add into your code, for several reasons. For me dealing with old interfaces and APIs with new code is not the best option as there are also other ways to do this.

After seeing the results, my next idea was to replace the TTY interface with a Netlink socket. In order to do that though, I needed to write a custom kernel module, a raw OpenAMP firmware and also the userspace client that sends data to the Netlink socket. In this post I'll briefly explain those things and also present the benchmark results and compare them with the TTY interface.

### Test Yocto image

I've added the recipes with all the code in the BSP base layer here:

  - [https://bitbucket.org/dimtass/meta-stm32mp1-bsp-base/src/master/](https://bitbucket.org/dimtass/meta-stm32mp1-bsp-base/src/master/)
  - [https://github.com/dimtass/meta-stm32mp1-bsp-base](https://github.com/dimtass/meta-stm32mp1-bsp-base)
  - [https://gitlab.com/dimtass/meta-stm32mp1-bsp-base](https://gitlab.com/dimtass/meta-stm32mp1-bsp-base)

This is the same repo as the previous post, but I've now added 3 more recipes, which are the following:

   - [stm32mp1-rpmsg-netlink-kernel-module.bb](https://github.com/dimtass/meta-stm32mp1-bsp-base/blob/master/recipes-kernel/stm32mp1-rpmsg-netlink-kernel-module/stm32mp1-rpmsg-netlink-kernel-module.bb), adds the kernel module.
   - [stm32mp1-rpmsg-netlink-stm32_git.bb](https://github.com/dimtass/meta-stm32mp1-bsp-base/blob/master/recipes-extended/stm32mp1-rpmsg-netlink/stm32mp1-rpmsg-netlink-stm32_git.bb), adds the CM4 firmware in the image
   - [stm32mp1-rpmsg-netlink-linux_git.bb](https://github.com/dimtass/meta-stm32mp1-bsp-base/blob/master/recipes-extended/stm32mp1-rpmsg-netlink/stm32mp1-rpmsg-netlink-linux_git.bb), adds the linux netlink client

To build the image using this BSP base layer, then read the README.md file in the repo or the previous post. The README files is more than enough, though.

The repo of the actual code is here:

[https://bitbucket.org/dimtass/stm32mp1-rpmsg-netlink-example/src/master/](https://bitbucket.org/dimtass/stm32mp1-rpmsg-netlink-example/src/master/)
[https://github.com/dimtass/stm32mp1-rpmsg-netlink-example](https://github.com/dimtass/stm32mp1-rpmsg-netlink-example)
[https://gitlab.com/dimtass/stm32mp1-rpmsg-netlink-example](https://gitlab.com/dimtass/stm32mp1-rpmsg-netlink-example)

### Kernel driver code

The kernel driver module code is this one [here](https://github.com/dimtass/stm32mp1-rpmsg-netlink-example/blob/master/CA7-Source/kernel-driver/rpmsg_netlink.c). As you can see this is a quite simple driver, so no interrupts, DAM or anything fancy. In the init function I just register a new rpmsg driver.

```c
ret = register_rpmsg_driver(&rpmsg_netlink_drv);
```

This line just registers the driver, but the driver will be probed only when a new service requests for this specific driver's id name, which is this one here

```c
static struct rpmsg_device_id rpmsg_netlink_driver_id_table[] = {
    { .name	= "rpmsg-netlink" },
    { },
};
```

Therefore, when a new device (or service) that is added requests for this name, then the probe function will be executed. I'll show you later, how the driver is actually triggered.

Then regarding the probe function, when it's triggered then a new Netlink kernel is created and a callback function is added in the `cfg` Netlink kernel configuration struct.

```c
nl_sk = netlink_kernel_create(&init_net, NETLINK_USER, &cfg);
if(!nl_sk) {
    dev_err(dev, "Error creating socket.\n");
    return -10;
}
```

The callback for the Netlink kernel is this function

```c
static void netlink_recv_cbk(struct sk_buff *skb)
```

This callback is triggered when new data are received in this socket. It's important to select a unit id which is not used by other Netlink kernel drivers. In this case I'm using this id

```c
#define NETLINK_USER 31
```

Inside the Netlink callback, the received data are parsed and then are sent to the CM4 using the rpmsg (OpenAMP) API. As you can see from the code [here](https://github.com/dimtass/stm32mp1-rpmsg-netlink-example/blob/master/CA7-Source/kernel-driver/rpmsg_netlink.c#L39), the driver doesn't send all the received buffer, but it splits the data into blocks as the rpmsg has a hard-coded buffer limited to 512 bytes. Therefore, the limitation that we had in the previous post still remains, of course. The point, as I've mentioned is to simplify the userspace client code and not use TTY.

Finally, the `rpmsg_drv_cb()` is the callback function of the OpenAMP and you can see the code [here](https://github.com/dimtass/stm32mp1-rpmsg-netlink-example/blob/master/CA7-Source/kernel-driver/rpmsg_netlink.c#L75). This callback is triggered when the CM4 firmware sends data to the CA7 via rpmsg. In this case, the CM4 firmware will send the number of bytes that were received from the CA7 kernel driver (from the Netlink callback). Then the callback will send this uint16_t back to the usespace application using Netlink.

Therefore, the userspace app sends/receives data to/from the kernel using Netlink and the kernel sends/receives data to/from the CM4 firmware using rpmsg. Note, that all these stages are copying buffers! So, no zero-copy here, but multiple memcpys, so we already expect some latency, but we'll how much later.

### CM4 firmware

The CM4 firmware code is [here](https://github.com/dimtass/stm32mp1-rpmsg-netlink-example/tree/master/CM4-Source/source/src_hal). This code is more complex that the kernel driver, but the interesting code is in the main.c file. The most important lines are

```c
#define RPMSG_SERVICE_NAME "rpmsg-netlink"
```

and
```c
OPENAMP_create_endpoint(&resmgr_ept, RPMSG_SERVICE_NAME, RPMSG_ADDR_ANY, rx_callback, NULL);
```

As you may have guessed the RPMSG\_SERVICE\_NAME is the same with the kernel driver id name. This means that those two names need to match, otherwise the kernel driver won't get probed.

The `rx_callback()` function is the interrupt function of the rpmsg on the firmware side. This will only copy the buffer (more memcpys in the pipeline) and then the handling will be done in the main() in this code

```c
if (rx_dev.rx_status == SET)
{
  /* Message received: send back a message anwser */
  rx_dev.rx_status = RESET;

  struct packet* in = (struct packet*) &rx_dev.rx_buffer[0];
  if (in-&gt;preamble == PREAMBLE) {
    in-&gt;preamble = 0;
    rpmsg_expected_nbytes = in-&gt;length;
    log_info("Expected length: %d\n", rpmsg_expected_nbytes);                        
  }

  log_info("RPMSG: %d/%d\n", rx_dev.rx_size, rpmsg_expected_nbytes);
  if (rx_dev.rx_size &gt;= rpmsg_expected_nbytes) {
    rx_dev.rx_size = 0;
    rpmsg_reply[0] = rpmsg_expected_nbytes & 0xff;
    rpmsg_reply[1] = (rpmsg_expected_nbytes &gt;&gt; 8) & 0xff;
    log_info("RPMSG resp: %d\n", rpmsg_expected_nbytes);
    rpmsg_expected_nbytes = 0;

    if (OPENAMP_send(&resmgr_ept, rpmsg_reply, 2) &lt; 0) {
      log_err("Failed to send message\r\n");
      Error_Handler();
    }
  }
}
```
As you can see from the above code, the buffer is parsed and if there is a valid packet in there, then it extracts the length of the expected data and when those data are received, then it sends back the number or bytes using the OpenAMP API. Those data will be received then by the kernel and then send to userspace using Netlink.

### User-space application

The userspace application code is [here](https://github.com/dimtass/stm32mp1-rpmsg-netlink-example/tree/master/CA7-Source/userspace). If you browse the code you'll find out that is very similar to the previous post's tty client and I've only made a few changes like removing the tty and adding the Netlink socket class. Like in the previous post, a number of tests are added when the program starts like this

```c
tester.add_test(512);
tester.add_test(1024);
tester.add_test(2048);
tester.add_test(4096);
tester.add_test(8192);
tester.add_test(16384);
tester.add_test(32768);
```

Then the tests are executed. What you may find interesting is the Netlink class code and especially the part that sends/ receives the to/from the kernel, which is this code [here](https://github.com/dimtass/stm32mp1-rpmsg-netlink-example/blob/master/CA7-Source/userspace/netlink_client.cpp#L37). Have in this code:

```c
do {
    int n_tx = buffer_len &lt; MAX_BLOCK_SIZE ?  buffer_len : MAX_BLOCK_SIZE;
    buffer_len -= n_tx;

    memset(&kernel, 0, sizeof(kernel));
    kernel.nl_family = AF_NETLINK;
    kernel.nl_groups = 0;

    memset(&iov, 0, sizeof(iov));
    iov.iov_base = (void *)m_nlh;
    iov.iov_len = n_tx;
    
    std::memset(m_nlh, 0, NLMSG_SPACE(n_tx));
    m_nlh-&gt;nlmsg_len = NLMSG_SPACE(n_tx);
    m_nlh-&gt;nlmsg_pid = getpid();
    m_nlh-&gt;nlmsg_flags = 0;

    std::memcpy(NLMSG_DATA(m_nlh), buffer, n_tx);

    memset(&msg, 0, sizeof(msg));
    msg.msg_name = &kernel;
    msg.msg_namelen = sizeof(kernel);
    msg.msg_iov = &iov;
    msg.msg_iovlen = 1;

    L_(ldebug) &lt;&lt; "Sending " &lt;&lt; n_tx &lt;&lt; "/" &lt;&lt; buffer_len;
    int err = sendmsg(m_sock_fd, &msg, 0);
    if (err &lt; 0) {
        L_(lerror) &lt;&lt; "Failed to send netlink message: " &lt;&lt;  err;
        return(0);
    }

} while(buffer_len);
```

As you can see, the data are not sent a single buffer in the kernel driver via the Netlink socket. The reason is that the kernel socket can only assign a buffer equal to the page size, therefore if you try to send more that 4KB then the kernel will crash. Therefore, we need to split the data in to smaller blocks and send them via Netlink. There are some ways to increase this size, but a change like this would be global to all the kernel and this would mean that all drivers would allocated larger buffers even if they don't need them and that's a waste of memory.

### Benchmark results

To execute the test I've built the Yocto image using my BSP base layer, which includes all the recipes and installs everything by default in the image. What is important is that the module is already loaded in the kernel when it boots, so it's not needed to modprobe the module. Given this, it's only needed to upload the firmware in the CM4 and then execute the application. n this image, all the commands need to be executed in the `/home/root` path.

First load the firmware like this:

```sh
./fw_cortex_m4_netlink.sh start
```

When running this, the kernel will print those messages (you can use `dmesg -w` to read those).

```
[ 3997.439653] remoteproc remoteproc0: powering up m4
[ 3997.444869] remoteproc remoteproc0: Booting fw image stm32mp157c-rpmsg-netlink.elf, size 198364
[ 3997.452743]  mlahb:m4@10000000#vdev0buffer: assigned reserved memory node vdev0buffer@10042000
[ 3997.461387] virtio_rpmsg_bus virtio0: rpmsg host is online
[ 3997.467937]  mlahb:m4@10000000#vdev0buffer: registered virtio0 (type 7)
[ 3997.472245] virtio_rpmsg_bus virtio0: creating channel rpmsg-netlink addr 0x0
[ 3997.473121] remoteproc remoteproc0: remote processor m4 is now up
[ 3997.492511] rpmsg_netlink virtio0.rpmsg-netlink.-1.0: rpmsg-netlink created netlink socket
```

The last line, is actually printed by our kernel driver module. This means that when the firmware loaded then the driver's probe function was triggered, because it was matched by the `RPMSG_SERVICE_NAME` in the firmware. Next, run the application like this:

```sh
./rpmsg-netlink-client
```

This will execute all the tests. This is a sample output on my board.

```
- 21:27:31.237 INFO: Application started
- 21:27:31.238 INFO: Initialized netlink client.
- 21:27:31.245 INFO: Initialized buffer with CRC16: 0x1818
- 21:27:31.245 INFO: ---- Creating tests ----
- 21:27:31.245 INFO: -&gt; Add test: size=512
- 21:27:31.245 INFO: -&gt; Add test: size=1024
- 21:27:31.245 INFO: -&gt; Add test: size=2048
- 21:27:31.246 INFO: -&gt; Add test: size=4096
- 21:27:31.246 INFO: -&gt; Add test: size=8192
- 21:27:31.246 INFO: -&gt; Add test: size=16384
- 21:27:31.246 INFO: -&gt; Add test: size=32768
- 21:27:31.246 INFO: ---- Starting tests ----
- 21:27:31.268 INFO: -&gt; b: 512, nsec: 21384671, bytes sent: 20
- 21:27:31.296 INFO: -&gt; b: 1024, nsec: 27190729, bytes sent: 20
- 21:27:31.324 INFO: -&gt; b: 2048, nsec: 27436772, bytes sent: 20
- 21:27:31.361 INFO: -&gt; b: 4096, nsec: 31332686, bytes sent: 20
- 21:27:31.419 INFO: -&gt; b: 8192, nsec: 55592343, bytes sent: 20
- 21:27:31.511 INFO: -&gt; b: 16384, nsec: 88094875, bytes sent: 20
- 21:27:31.681 INFO: -&gt; b: 32768, nsec: 162541198, bytes sent: 20
```

The results are starting after the “Starting tests” string and b is the block size and nsec is the number of nanoseconds that the whole transaction lasted. Ignore the `bytes sent` size as it's not correct and to fix this would be a lot of hassle, as it would need a static counter in the kernel driver, which doesn't really worth the trouble. I’ve used the Linux precision timers, which they’re not very precise compared to the CM4 timers, but it’s enough for this test since the times are in the range of milliseconds. I’m also listing the results in the next table.


| # of bytes (block)	| msec
-|-
512	  | 21.38
1024	| 27.19
2048	| 27.43
4096	| 31.33
8192	| 55.59
16384	| 88.09
32768	| 162.54

Now let's compare those number with the previous tests in the following table


| # of bytes	| TTY (msec)	| Netlink (msec)	| diff (msec)
-|-|-|-
512	| 11.97	|	21.38	|	9.41
1024	|	15.32	|	27.19	|	11.87
2048	|	21.74	|	27.43	|	5.69
4096	|	37.64	|	31.33	|	-6.31
8192	|	-	| 55.59 |	-
16384	| -	| 88.09	 | -
32768	| -	| 162.54 | -

These are interesting numbers. As you can see up to 2KB of data, the TTY implementation is faster, but at >=4KB the Netlink driver has better performance. Also it's important that the Netlink implementation doesn't have the issue with the limited block size, so you can sent more data using the netlink client API I've written. Well, the truth is that it does the have a limited block size hard-coded in OpenAMP, but in this case without the TTY interface the ringbuffer seems to empty properly. That's something that it would need further investigation, but I don't think I'll have time for this.

From this table in case of the 32KB block we see that the transfer rate is 201.6 KB/sec, which almost the double compared to the TTY implementation. This is much better performance, but again it's far slower than the indirect buffer sharing mode, which I'll test in the next post.

### Conclusions

In this post I've implemented a kernel driver that uses OpenAMP to exchange data with the CM4 and a netlink socket to exchange data with the userspace. In this scenario the performance is worse compared to the default TTY implementation (`/dev/ttyRPMSGx`) for blocks smaller than 4KB, but it's faster for >=4KB. Also my tests shown that if the block is 32KB then this implementation it's twice as fast than the TTY.

Although the results are better than the previous post, still this implementation can not be considered as a good option if you need to transfer large amounts of data and fast. Nevertheless, personally I would consider this as a good option for smaller data sizes, because now the interface from the userspace is much more convenient as it's based on a netlink socket. Therefore, you don't need to interface with a TTY port anymore and that is an advantage.

So, I'm quite happy with the results. I would definitely prefer to use this option rather the TTY interface for data blocks more than 2KB, because netlink is more friendly API, at least to me. Maybe you have a difference preference, but overall those two solutions are only good for smaller block sizes.

In the next post, I'll benchmark the indirect buffer sharing.

Have fun!