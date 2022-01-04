---
title: Tensorflow 2.1.0 for microcontrollers benchmarks on Teensy 4.0
date: 2020-05-30T08:42:42+00:00
author: dimtass
layout: post
categories: ["Microcontrollers", "Teensy"]
tags: ["Teensy", "TensorFlow", "Machine Learning", "Benchmarks"]
img_src: "/images"
img_width: 580
img_extras: ".shadow"
---
## Intro

It's being some time that I haven't update the blog, but I was too busy with other stuff. I've updated a couple of times the [meta-allwinner-hx](https://gitlab.com/dimtass/meta-allwinner-hx) layer and the last major update was to move the layer to the latest dunfell 3.1 version. Also, I've ordered an Artillery Genius 3D printer (I felt connected with it's name, lol). I wanted to buy into 3D printing for many years now, but never really had the time. Not that I do have time now, but as I have realized with many things in life, if you don't just do it you'll never find the time for it.

On other news, I've also received an STM32MP157C-DK2 from ST to evaluate and I would like to focus my next couple posts to this SBC. I've already got somehow deep into the documentation and also pushed some PRs to the public git Yocto meta layer. Next thing is to start writing a couple of posts to test some interesting aspects of this SBC and list its cons and pros.

But before getting deep to the STM32MP1 I wanted to do something else first and this was to test my TensorFlow Lite for microcontrollers template on the i.MX RT1062 MCU, which is used on the Teensy 4.0 and it's supposed to be one of the fastest MCUs.

So, is it really that fast? How does it perform compared to STM32F746 I've used in the last post [here]({% post_url 2020-04-16-tensorflow-2-1-0-for-microcontrollers-benchmarks-on-stm32f746 %})?

## About Teensy 4.0

Well, regarding Teensy 4.0, I really like this board and definitely I love it's ecosystem and congrats to Paul Stoffregen for what he created. He also seems extremely active in every aspect, like supporting the forums, the released boards, the middleware and the customers and at the same time also find time to design and release new boards fast.

In one of my [latest posts]({% post_url 2020-02-29-using-nxp-sdk-with-teensy-4-0 %}) I've figured out that the Teensy 4.0 (actually the imxrt1062) doesn't have an onboard flash; it happens to me often because I don't spend time to read and understand all the specs of the boards I'm buying for evaluation. Therefore, the firmware is written in an external SPI NOR. Also there is a custom bootloader and a host flashing tool that uploads the firmware. Gladly, I've also found out that this bootloader doesn't do any other advanced things like preparing the runtime environment and using custom libs that the firmware has dependency on, therefore you can just compile your code using the NXP SDK and CMSIS and then upload it to the SPI NOR, avoiding to use the arduino framework.

This works great and I've also created a cmake template, but I haven't found time to finish it properly and pack it in a state that can be published. Nevertheless, I've used this unpublished template to build the TF-Lite micro code with the Keras model I'm using in all the [Machine Learning for Embedded]({% post_url 2019-06-27-machine-learning-on-embedded-part-1 %}) posts. So, in this post I will present you the results and give you access to the source code to try it yourself.

If you've read so far and you've also read the previous post, then pause for a moment and think. What results do you expect? Especially compared to STM32F746 which is a 216MHz MCU when knowing that iMX RT1060 is running on 600MHz and it's a beast in terms of clock speed. How much performance difference you would expect?

## Source code

Since I've explained most part of the useful code in the previous post [here]({% post_url 2020-04-16-tensorflow-2-1-0-for-microcontrollers-benchmarks-on-stm32f746 %}), I won't go again into the details. You can find the source code for the Teensy 4.0 here:

- [https://bitbucket.org/dimtass/imxrt1062-tflite-micro-mnist/src/master/](https://bitbucket.org/dimtass/imxrt1062-tflite-micro-mnist/src/master/)  
- [https://gitlab.com/dimtass/imxrt1062-tflite-micro-mnist](https://gitlab.com/dimtass/imxrt1062-tflite-micro-mnist)  
- [https://github.com/dimtass/imxrt1062-tflite-micro-mnist](https://github.com/dimtass/imxrt1062-tflite-micro-mnist)

In the repo's README there's a thorough explanation on how to build the firmware and how to flash it, so I'll skip some details here. Therefore, to build the code you can run this command:

```sh
./docker-build.sh "./build.sh"
```

This will build the code with the default options. With the default options the uncompressed model is used and also the tflite doesn't use the cmsis-nn acceleration library. To run the above command you need to have Docker installed to your system and it's the preferred method to build with this code, so you get the same results with me. After running this command you should see this in your console:

```
...
[ 99%] Linking CXX executable flexspi_nor_release/imxrt1062-tflite-micro-mnist.elf
Print sizes: imxrt1062-tflite-micro-mnist.hex
   text	   data	    bss	    dec	    hex	filename
 642300	    484	  95376	 738160	  b4370	flexspi_nor_release/imxrt1062-tflite-micro-mnist.elf
[ 99%] Built target imxrt1062-tflite-micro-mnist.elf
Scanning dependencies of target imxrt1062-tflite-micro-mnist.hex
[100%] Generating imxrt1062-tflite-micro-mnist.hex
[100%] Built target imxrt1062-tflite-micro-mnist.hex
```

This means that the code is built without error and the size of the code is 642300 bytes. Also the cmake will create a HEX file from the elf which is needed by the teensy cli flashing tool.

If you want to build the code with the compressed model and the cmsis-nn acceleration library then you need to run this command:

```sh
./docker-build.sh "USE_COMP_MODEL=ON USE_CMSIS_NN=ON ./build.sh"
```

After this command you should see this output:

```
[ 99%] Linking CXX executable flexspi_nor_release/imxrt1062-tflite-micro-mnist.elf
Print sizes: imxrt1062-tflite-micro-mnist.hex
   text	   data	    bss	    dec	    hex	filename
 387108	    708	 108152	 495968	  79160	flexspi_nor_release/imxrt1062-tflite-micro-mnist.elf
[ 99%] Built target imxrt1062-tflite-micro-mnist.elf
[100%] Generating imxrt1062-tflite-micro-mnist.hex
[100%] Built target imxrt1062-tflite-micro-mnist.hex
```

As you can see now, the size of the firmware is much smaller as the compressed model is used.

To flash any of those firmwares you need to install the `teensy_loader_cli` tools which is located in this repo [here](https://github.com/PaulStoffregen/teensy_loader_cli).

## Connections

In order to see the debug output you need to connect a USB-to-UART module on the Teensy, as I'm not using any VCP interface in this case for simplicity in the code. In this case I'm using the UART2 and the pinmux for the Tx and Rx pins is as follows:

FUNCTION | Teensy pin
-|-
Tx	| 14
Rx	| 15

Then you need to open a terminal on your host (I'm using CuteCom) and then send either `1` or `2` in the serial port. You can either just send the character or add a newline in the end, it doesn't matter. The function of those two commands are:

Command	| Description
-|-
1	| Execute the ViewModel() function to output the details of the model
2	| Run the inference using a predefined digit (handwritten number 8)

## Benchmarks

Now the interesting part. I've build the code using 4 different cases.

Case	| Description
-|-
1	| Uncompressed model, without CMSIS-NN @ 600MHz
2	| Compressed model, without CMSIS-NN @ 600MHz
3	| Uncompressed model, with CMSIS-NN @ 600MHz
4	| Compressed model, with CMSIS-NN @ 600MHz


The results are listed in the following table (all numbers are milliseconds):

Layer	| [1]	|	[2]	|	[3]	|	[4]
-|-|-|-|-
DEPTHWISE_CONV_2D	|	6.30	|	6.31	|	6.04	|	6.05
MAX_POOL_2D	|	0.863	|	0.858	|	0.826	|	0.828
CONV_2D	|	171.40	|	165.73	|	156.84	|	150.84
MAX_POOL_2D	|	0.246	|	0.247	|	0.256	|	0.257
CONV_2D	|	26.40	|	25.58	|	26.60	|	26.35
FULLY_CONNECTED		| 3.00	| 0.759	|	3.02	|	1.81
FULLY_CONNECTED		| 0.066	| 0.090	|	0.081	|	0.098
SOFTMAX	|	0.035	|	0.037	|	0.033	|	0.035
Total time:	|	208.4	|	199.62	|	193.72	|	186.29


What do you think about these results? Hm... OK, let me take the best case scenario for those results and compare them with the best results I got with the STM32F746 in the previous [post](https://www.stupid-projects.com/tensorflow-2-1-0-for-microcontrollers-benchmarks-on-stm32f746/).

Layer	| i.MXRT1062 @ 600MHz (msec) |	STM32F746 @ 288MHz (msec)
-|-|-
DEPTHWISE_CONV_2D	|	6.05	|	18.68
MAX_POOL_2D	|	0.828	|	2.45
CONV_2D	|	150.84	|	124.54
MAX_POOL_2D	|	0.257	|	0.72
CONV_2D	|	26.35	|	17.49
FULLY_CONNECTED	|	1.81	|	1.11
FULLY_CONNECTED	|	0.098	|	0.02
SOFTMAX	|	0.035	|	0.01
Total time:	|	186.29	|	165.02

## Results

The above results are so confusing to me, that I'm start thinking that I may doing something wrong here. I've double checked all the compiler optimizations and flags so they are the same with the STM32F7 and also checked that the imxrt1062 clock frequency is correct. Everything seems to be fine, yet I get those low results with the exact same version of TensorFlow.

When I get to such cases and I find that is difficult to debug further, then I either try to make logical assumptions for the problem, or I'm trying to reach for some help (e.g. RTFM). In this case, I will only make assumptions, because I don't really have the time to read the whole MCU user manual to try to figure out if there's a specific flag in the MCU that may give some better results.

The first thing that comes to my mind is of course the storage from which the code is running. In case of STM32F746 there is a fast onboard flash with prefetch, which means that the CPU waits for a small amount of time for the next commands to end up in the execution pipeline. But in case of the imxrt1062 the code is stored in an external SPI NOR. This means that each command needs first to be read via SPI to end up in the execution pipeline and this needs more time compared to the onboard flash. Hence, this is my theory why the imxrt1062 has worse inference performance, although it's core clock is 2x faster compared to the overclocked STM32746 @ 288.

So, what do you think? Does that make sense to you? Do you have another suggestion?

## Conclusions

To be honest, I was expecting much better results from the Teensy 4.0 (I mean the imxrt1062). I didn't expect to be 2x faster, but I expected ~1.5x factor, but I was wrong in my assumption. My assumption is that the lower performance is due to the fact that the SPI NOR has a great performance hit in this case. I also assume that another MCU with the same imxrt core and a fast internal flash would perform much better than that.

So, is Teensy 4.0 or the imxrt1062 crap? No! Not at all. I see a lot of performance gain in computation demanding applications where the data are already stored in the RAM. Also the linker script for the imxrt1062 is written in a convenient way that you can easily mount specific functions and data in the `m_data` and `m_data2` areas (see source/MIMXRT1062xxxxx_flexspi_nor.ld in the repo). Also, in GCC you can use the compiler's section attribute to this, for example:

```c
__attribute__((section(".m_data2")))
void function(void)
{
...
}
```

Anyway, for this case the imxrt1062 doesn't seem to perform well and actually is even slower compared to the STM32F746, which runs in much slower clock.

There is a chance, of course, that I may do something wrong in my tests, so if I have any update then I'll post it here.

Have fun!