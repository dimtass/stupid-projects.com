---
title: Benchmarking TensorFlow Lite for microcontrollers on Linux SBCs
date: 2019-08-05T07:30:22+00:00
author: dimtass
layout: post
categories: ["Embedded"]
tags: ["Embedded Linux", "TensorFlow", "Benchmarks", "Machine Learning"]
img_src: "/images"
img_width: 580
img_extras: ".shadow"
---
## Intro

(**06.08.2019 Edit**: _I've added an extra section with more benchmarks for the nanopi-neo4_)

(**07.08.2019 Edit**: _I've added 3 more results that Shaw Tan posted in the comments_)

In this post, I'll show you the results of benchmarking the TensorFlow Lite for microcontrollers (tflite-micro) API not on various MCUs this time, but on various Linux SBCs (Single-Board Computers). For this purpose I've used a code which I've originally written to test and compare the tflite-micro API which is written in C++ and the tflite python API. This is the repo:

[https://bitbucket.org/dimtass/tflite-micro-python-comparison](https://bitbucket.org/dimtass/tflite-micro-python-comparison)

Then, I thought why not test the tflite-micro API on various _SBCs_ that I have around.

For those who don't know what an SBC is, then it's just a small computer with an application CPU like the Raspberry Pi (RPi). Probably everyone knows RPi but there are more than a 100 SBCs in the market in all forms and sizes (e.g. RPi has currently released 13 different models).

## Components

Although I have plenty of those boards around, I didn't used all of them. That would be very time consuming. I've selected quite a few though. Before I list the devices and their specs, here is a photo of the testing bench. A couple of SBCs have missed the photo-shooting and joined the party later.

![]({{page.img_src}}/tflite-micro-bench-sbcs.jpg){: width="{{page.img_width}}" {{page.img_extras}}}

**Top row, from left to right:**

  * [AML-S905X-CC (Le Potato)](https://libre.computer/products/boards/aml-s905x-cc/): Amlogic S905X SoC, Quad Cortex-A53 @ 1.512GHz, 2GB DDR3
  * [Raspberry Pi 3 B+](https://www.raspberrypi.org/products/raspberry-pi-3-model-b-plus/): Broadcom BCM2837B0, Quad Cortex-A53 @ 1.4GHz, 1GB LPDDR2
  * [Beaglebone Black](https://beagleboard.org/black/): Texas Instruments AM335x, Cortex-A8 @ 1GHz, 512MB DDR3
  * [Jetson nano](https://www.nvidia.com/en-us/autonomous-machines/embedded-systems/jetson-nano/): Nvidia t210, Quad Cortex-A57 @ 1.4GHz, 4GB LPDDR4

**Bottom row, from left to right:**

  * [Nanopi Neo 4](http://wiki.friendlyarm.com/wiki/index.php/NanoPi_NEO4): Rockchip RK3399, Dual Cortex-A72 @ 1.8GHz + Quad Cortex-A53 @ 1.5GHz
  * [Nanopi K1 Plus](http://wiki.friendlyarm.com/wiki/index.php/NanoPi_K1_Plus): Allwinner H5, Quad Cortex-A53 @ 1.3GHz, 3GB DDR3
  * [Nanopi Neo2](http://wiki.friendlyarm.com/wiki/index.php/NanoPi_NEO2): Allwinner H5, Quad Cortex A53 @ 900MHz, 512MB DDR3
  * [Orangepi Prime](http://www.orangepi.org/OrangePiPrime/): Allwinner H5, Quad Cortex-A53 @ 1.3 GHz, 2GB DDR3

**Missing from the photo:**

  * [Nanopi neo](http://wiki.friendlyarm.com/wiki/index.php/NanoPi_NEO): Allwinner H3, Quad Cortex-A7 @ 1.2GHz, 512MB DDR3
  * [Nanopi duo](http://wiki.friendlyarm.com/wiki/index.php/NanoPi_Duo): Allwinner H2+, QuadCortex-A7 @ 1GHz, 512MB DDR3

I've tried to use the same distribution packages for each SBC, so in the majority of the boards the rootfs and packages are from Ubuntu 18.04, but the kernels are different versions. It's impossible to have the exact same kernel version as not every SoC has a mainline support. Also, even if the SoC has a mainline support, like H5 and RK3399, the SBC itself probably doesn't. Therefore, each board needs a device-tree and several patches for a specific kernel version to be able to boot properly. There are build systems like [Armbian](https://www.armbian.com/), which make things easier, but it supports only a fragment of the available SBCs. The SoC and SBC support in the mainline kernel is an important issue for a long time now, but let's continue.

In this table I've listed the image I've used for each board. These are the boards that I've benchmarked myself


SBC	| Image |	Kernel
AML-S905X-CC	|	Ubuntu 18.04 	|Headless	4.19.55
Raspberry Pi 3 B+	Ubuntu 18.04 Server	4.4.0-1102
Jetson nano	| Ubuntu 18.04	|	4.9
Nanopi Duo	| Armbian 5.93	|	4.19.63
Nanopi Neo	| Armbian 5.93	|	4.19.63
Nanopi Neo2	| Armbian 5.93	|	4.19.63
Nanopi Neo 4	|	Armbian 5.93	|	4.4.179
Nanopi Neo 4 (2)	|	Yocto build	|	4.4.176
Nanopi K1 Plus	|	Armbian 5.93	|	4.19.63
Orangepi Prime	|	Armbian 5.93	|	4.19.63
Beaglebone Black	|	Debian 9.5	|	-

This table is from other SBCs that `Shaw Tan` benchmarked and posted the results in the comments

SBC	| Image	|	Kernel
Google Coral Dev Board	|	Debian Stretch aarch64	|	4.9.51-imx
Rock Pi 4B	|	Debian Stretch aarch64	|	4.4.154
Raspberry Pi 4	|	Rasbian	|	4.19.59-v8

Got another result from `RemoteC` in the comments

SBC	|	Image	|	Kernel
Odroid MC1	|	Linux odroid	|	4.14.141-169
Odroid N2	|	Linux odroid	|	4.9.216-71

## But why use tflite-micro?

That's a good question. Why use the tflite-micro API on a Linux SBC? The tflite-micro is meant to be used with small microcontrollers and there is the tflite C++ API for Linux, which is more powerful and complete. Let's see what are the pros and cons of the C++ tflite API.

**pros:**

  * Supports more Ops
  * Supports also Python (that doesn't have to do with C++ but is a plus for the API)
  * Can scale to multi-core CPUs
  * GPU, TPU and NCS2 support
  * Can load flatbuffer models from the file system
  * Small binary (~300KB)

**cons:**

  * It's hard to build
  * A lot of dependencies
  * The whole API is integrated in the git repo and it's very difficult to get only the needed files to create your custom build via Make or CMake
  * Not available pre-build binaries for architectures other than x86_64

I've tried to build the API in a couple of SBCs and that failed for several different reasons. For now only RPi seems to be supported, but again it's quite difficult to re-use the library, it seems like you need to develop your application inside the tensorflow repo and it's difficult to extract the headers. Maybe there is somewhere a documentation on how to do this, but I couldn't find it. I've also seen other people having the same issue (see [here](https://stackoverflow.com/questions/33620794/how-to-build-and-use-google-tensorflow-c-api#33622489)), but none of the suggestions worked for me (except in my x86_64 workstation). At some point I was tired to keep trying, so I quit. Also the build was taking hours just to see it fail.

Then I though, why not use the tflite-micro API which [worked fine on the STM32F7 before](https://www.stupid-projects.com/machine-learning-on-embedded-part-3/) and since it's a simple library that builds on MCUs and the only dependency is flatbuffers, then it should build everywhere else (including Linux for those SBCs). So I've tried this and it worked just fine. Then I though to run some benchmarks on various SBCs I have around to see how it performs and if it's something usable.

## tflite model

Before I present the results, let's have a quick look at the tflite model. The model is the same I've used in the tests I've done in the `ML for embedded` series [here]({% post_url 2019-06-27-machine-learning-on-embedded-part-3 %}), [here]({% post_url 2019-07-26-machine-learning-on-embedded-part-4 %}) and [here]({% post_url 2019-07-29-machine-learning-on-embedded-part-5 %}). The complexity (MACC) of this model is measured in [multiply-and-accumulate](https://en.wikipedia.org/wiki/Multiply%E2%80%93accumulate_operation) (MAC) operations, which is the fundamental operation in ML.

For the specific mnist model I've used, the MACC is 2,852,598. That means that to get the output from any random input the CPU executes 2.8 million MAC operations. That's I guess a medium size model for a NN, but definitely not a small one.

Because now we're using the tflite-micro API, the model is not a file which is loaded from the file system, but it's embedded in the executable binary, as the flatbuffer model is just a byte array in a header file.

## Build the benchmark

If you want to test on any other SBC, you just need g++ and cmake. If your distro supports apt, then run this:

```sh
sudo apt install cmake g++
```

Then you just need to clone the repo, build the benchmark and run it. Just be aware that the output filename is changing depending on the CPU architecture. So for an aarch64 CPU run those commands:

```sh
git clone https://dimtass@bitbucket.org/dimtass/tflite-micro-python-comparison.git
cd tflite-micro-python-comparison/
./build.sh
./build-aarch64/src/mnist-tflite-micro-aarch64
```

And you'll get the results.

_(For a cortex-a7, the executable name will be mnist-tflite-micro-armv7l)_

## Results

**Note:** _I haven't done any custom optimization for any of the SBCs or the compiler flags for each architecture. The compiler is let to automatically detect the best options depending the system. Also, I'm running the stock images, without even change the performance governor, which is set `ondemand` for all the SBCs. Finally, I haven't applied any overclocking for any of the SBCs, therefore the CPU frequencies are whatever those images have set for the ondemand governor._

Ok, so now let's see the results I got on those SBCs. I've created a table with the average time of 1000 inferences for each test. In this list I've also added the results from my workstation and also in the end the results of the exact same code with the exact same tflite model running on the STM32F746, which is an MCU and baremetal firmware.

SBC	| Average for 1000 runs  (ms)
-|-
Ryzen 2700X (this is not SBC)	|	2.19
AML-S905X-CC	|	15.54
Raspberry Pi 3 B+		|13.47
Jetson nano	|	9.34
Nanopi Duo	|	36.76
Nanopi Neo	|	16
Nanopi Neo2	|	22.83
Nanopi-Neo4	|	5.82
Nanopi-Ne4 (2	|	5.21
Nanopi K1 Plu	|	14.32
Orangepi Prim	|	18.40
Beaglebone Black	|	97.03
STM32F746 @ 216MHz	|	76.75
STM32F746 @ 288 MHz	|	57.95

The next table has results that `Shaw Tan`, `RemoteC` and Huynh posted in the comments section:

SBC |	Average for 1000 runs  (ms)
-|-
Google Coral Dev Board |	12.40
Rock Pi 4B |	6.33
Raspberry Pi 4 |	8.35
Odroid MC1 – core 0 |	7.82
Odroid MC1 – core 1 |	15.32
Odroid N2 – core 1 |	9.90
Odroid N2 – core 5 |	6.35
imx6ull @ 900MHz |	31

There are many interesting results on this table.

First, the RK3399 cpu (nanopi-neo4) outperforms the Jetson nano and it's only 2.6 times slower that my Ryzen 2700X cpu. Amazing, right? This boards costs [only $50](https://www.friendlyarm.com/index.php?route=product/product&product_id=241). Excellent performance on this specific test.

Then the Jetson nano needs 9.34 ms. Be aware that this is a single CPU thread time! If you remember, [here]({% post_url 2019-07-29-machine-learning-on-embedded-part-5 %})) the tflite python API scored 0.98 ms in MAXN mode and 2.42 in 5W mode. The tflite python API supported the GPU though and used CUDA acceleration. So, for this board, when using the GPU and the tflite you get 9.5x (MAXN mode) and 3.8x (5W mode) better performance. Nevertheless, 9.34 ms doesn't sound that bad compared to the 5W mode.

Beaglebone black is the worst performer. It's even slower than the STM32F7, which is quite expected as BBB is a single core running @ 1GHz and the code is running on top of Linux. So the OS has a huge impact in performance, compared to baremetal. This raises an interesting question...

What would happened if the tflite-micro was running baremetal on those application CPUs? Without OS? Interesting question, maybe I get to it at another post some time in the future.

Then, the rest SBCs lie somewhere in the middle.

Finally, it worth noting that the nanopi neo is an SBC that [costs only $9.99](https://www.friendlyarm.com/index.php?route=product/product&product_id=132)! That's an amazing price/performance ratio for running the tflite-micro API. This board amazed me with those results (given its price). Also it's supposed to be an LTS board, which means that it will be in stock for some time, though it's not clear for how long.

## Additional benchmarks on the nanopi-neo4 (RK3399)

Since the nanopi-neo4 performed better than the other SBCs, I've build an image using Yocto. Since I'm the owner and maintainer of this layer, I need to say that this is actually a mix of the armbian u-boot and kernel versions and patches and also I've used some parts from meta-sunxi, but I've done more integrations to like supporting the GPU and some other things.

Initially, I've tried the armbian build because it's easy for everyone to reproduce, but then I though to test also my Yocto layer. Therefore I've used this repo here:

[https://bitbucket.org/dimtass/meta-nanopi-neo4](https://bitbucket.org/dimtass/meta-nanopi-neo4)

There are details how to use the layer and build in the README file of this repo, but this is the command I've used to build the image I've tested (after setting up the repo as described in the readme).

```sh
MACHINE=nanopi-neo4 DISTRO=rk-none source ./setup-environment.sh build
```

Then in the `build/conf/local.conf file` I've added this line in the end of the file
```sh
IMAGE_INSTALL += " cmake "
```

And finally I've build with this command:
```sh
bitbake rk-image-testing
```

Then I've flashed the image on an SD card:

```sh
# change sdX with your SD card
sudo umount /dev/sdX*
sudo dd if=build/tmp/deploy/images/nanopi-neo4/rk-image-testing-nanopi-neo4.wic.bz2 of=/dev/sdX status=progress
sudo eject /dev/sdX
```

This distro gave me a bit better results. I've also tried to benchmark each core separately by running the script like this:

```sh
taskset --cpu-list 0 ./build-aarch64/src/mnist-tflite-micro-aarch64
```

Two test all cores you need to replace in the above script the 0 with the number of cores from 0 to 5. Cores [0-3] are the Cortex-A53 and [4-5] are the Cortex-A72, which are faster. Without using taskset the OS will always run the script on the A72. These are the results:

Core number	| Results (ms)
-|-
0	| 12.39
1	| 12.40
2	| 12.39
3	| 12.93
4	| 5.21
5	| 5.21

Therefore, compare to the armbian distro there's a slight better performance of 0.61 ms, but this might be on the different kernel version, I don't know, but it the difference seems to be constant on every inference run I've tested.

## Conclusions

From the above results I've come to some conclusions, which I'll list in a pros/cons list of using the tflite-micro API on a SBC running a Linux OS.

**pros:**

  * Very simple to build and use
  * Minimal dependencies
  * Easy to extract the proper source and header files from the Tensorflow repo (compared to tflite)
  * Performance is not that bad (that's a personal opinion though)
  * Portability. You can compile the exact same code on any CPU or MCU and also on Linux or baremetal (maybe also in Windows with MinGW, I haven't tested).

**cons:**

  * No multi-threading. The tflite-micro only supports 1 thread.
  * The model is embedded in the executable as a byte array, therefore if you want to be able to load tflite models from the file system, then you need to implement your own parser, which just loads the tflite model file from the filesystem to a dynamically allocated byte array.
  * It's slower compared to tflite C++ API

From the above points (I may missed few, so I'll update if somethings comes to my mind), it's clear that the performance using the tflite-micro API on a multi-core CPU and in Linux, will be worse compared to the tflite API. I only have numbers to do a comparison between tflite and tflite-micro for my Ryzen 2700x and the Jetson nano, but not for the other boards. See the table:

CPU	| tflite-micro/tflite speed ratio
-|-
Ryzen 2700X | 10.63x
Jetson nano (5W) |	9.46x
Jetson nano (MAXN) |	3.86x

The above table shows that the tflite API is 10.63x faster than tflite-micro on the 2700x and 9.46x and 3.86x faster on the Jetson nano (depending the mode). This a great difference, of course.

What I would keep from this benchmark is that the tflite-micro is easy to build and use on any architecture, but there's a performance impact. This impact is much larger if the SoC is multi-core, has a GPU or any other accelerator which can't be used from the tflite API.

It's up to you to decide, if the performance of the tflite-micro is enough for your model (depending the MACC). If it is, then you can just use tflite-micro instead. Of course, don't expect to run inferences on real-time video but for real-time audio it should be probably enough.

Anyway, with tflite-micro it's very easy to test and evaluate for your model on your SBC.

Have fun!