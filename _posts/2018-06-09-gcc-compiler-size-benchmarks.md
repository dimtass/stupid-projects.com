---
title: GCC compiler size benchmarks
date: 2018-06-09T22:23:18+00:00
author: dimtass
layout: post
categories: ["Embedded"]
tags: ["Compilers"]
img_src: "/images"
img_width: 580
img_extras: ".shadow"
---
## Intro

Compilers, compiliers, compilers...

The black magic behind producing executable binaries for different kind of processors. All programmers use them, but most of them don't care about the internals and their differences. Anyway, this post is not about the compiler's internals though, but how the different versions perform regarding the size that is produced.

I've made another benchmark few months ago [here](http://www.stupid-projects.com/compile-benchmarks-with-gcc-musl-and-clang/), but that was using different compilers (GCC and clang) and different C libraries. Now I'm using only GCC, but different versions.

## Size doesn't matter!

Well, don't get me wrong here, but sometimes it does. Typical scenario is when you have a small microcontroller with a small flash size and your firmware is getting bigger and bigger. Another scenario is that you need to sacrifice some flash space for the DFU bootloader and then you realize that 4-12K are gone without writting any line of code for you actual app.

Therefore, __size does matter__.

## Compiler Flags

Compililers come with different optimisation flags for example the `-Os` flag configures the compiler to optimize specifically for size.

_"OK, so the binary size matters only when you the -Os!"_

No, no, no. The binary size matters whatever optimisation flag you use. For example your main need may be to optimise for performance. An example is if you're using a fast toggle gpio, e.g. implementing a custom bit-banging bus to program and interface an FPGA (like the Xilinx's selectmap). In this case you may need the `-O1/2/3` optimisation more than `-Os`, but still the size matters because you're limited in flash space. So, two different compiler versions may have even 1KB difference for the same optimization level and that 1KB may be critical someday to one of your projects!

And don't forget about the `-flto`! This is an important flag if you need size optimisation; therefore, all the benchmarks are done with and without this flag also.

## Benchmarking

I've benchmarked the following 9 different GCC compiler versions:

- gcc-arm-none-eabi-4_8-2013q4
- gcc-arm-none-eabi-4_9-2014q4
- gcc-arm-none-eabi-5_3-2016q1
- gcc-arm-none-eabi-5_4-2016q2
- gcc-arm-none-eabi-5_4-2016q3
- gcc-arm-none-eabi-6_2-2016q4
- gcc-arm-none-eabi-6-2017-q1-update
- gcc-arm-none-eabi-6-2017-q2-update
- gcc-arm-none-eabi-7-2017-q4-major

It turned out that all the GCC6 compilers performed exactly the same; therefore, without reading the release notes I assume that the changes have to do with fixes rather optimisations.

The code I've used for the benchmards is here:  
[https://bitbucket.org/dimtass/stm32f103-usb-periph-expander](https://bitbucket.org/dimtass/stm32f103-usb-periph-expander)

This is my next stupid project and it's not completed yet, but still it compiles and without optimisations creates a ~50KB binary. To use your toolchain, just change the toolchain path in the `TOOLCHAIN_DIR` variable in the `cmake/TOOLCHAIN_arm_none_eabi_cortex_m3.cmake` file and run `./build.bash`on Linux or `build.cmd`on Windows.

## Results

These are the results from compiling the code with different compilers and optimisation flags.

#### gcc-arm-none-eabi-4_8-2013q4

flag | size in bytes	| size in bytes (-flto)
-|-|-
-O0	| 51908	| –
-O1	| 32656	| –
-O2	| 31612	| –
-O3	| 39360	| –
-Os	| 27704	| –

#### gcc-arm-none-eabi-4_9-2014q4

flag | size in bytes	| size in bytes (-flto)
-|-|-
-O0	| 52216	| 56940
-O1	| 32692	| 23984
-O2	| 31496	| 22988
-O3	| 39672	| 31268
-Os	| 27563	| 19748

#### gcc-arm-none-eabi-5_3-2016q1

flag | size in bytes	| size in bytes (-flto)
-|-|-
-O0	| 51696	| 55684
-O1	| 32656	| 24032
-O2	| 31124	| 23272
-O3	| 39732	| 30956
-Os	| 27260	| 19684

#### gcc-arm-none-eabi-5_4-2016q2

flag | size in bytes	| size in bytes (-flto)
-|-|-
-O0	| 51736	| 55724
-O1	| 32672	| 24060
-O2	| 31144	| 23292
-O3	| 39744	| 30932
-Os	| 27292	| 19692

#### gcc-arm-none-eabi-5_4-2016q3

flag | size in bytes	| size in bytes (-flto)
-|-|-
-O0	| 51920	| 55888
-O1	| 32684	| 24060
-O2	| 31144	| 23300
-O3	| 39740	| 30948
-Os	| 27292	| 19692

#### gcc-arm-none-eabi-6_2-2016q4,gcc-arm-none-eabi-6-2017-q1-update,gcc-arm-none-eabi-6-2017-q2-update

flag | size in bytes	| size in bytes (-flto)
-|-|-
-O0	| 51632	| 55596
-O1	| 32712	| 24284
-O2	| 31056	| 22868
-O3	| 40140	| 30488
-Os	| 27128	| 19468

#### gcc-arm-none-eabi-7-2017-q4-major

flag | size in bytes	| size in bytes (-flto)
-|-|-
-O0	| 51500	| 55420
-O1	| 32488	| 24016
-O2	| 30672	| 22080
-O3	| 40648	| 29544
-Os	| 26744	| 18920

## Conclusion

From the results it's pretty obvious that the `-flto`flag makes a huge difference in all versions except GCC4.8 where the code failed to compile at all with this flag enabled.

Also it seems that when no optimisations are applied with `-O0`then the `-flto`instead of doing size optimisation, actually created a larger binary. I have no explain for that, but anyways it doesn'y really matter, because there's no point in using `-flto`at all in such cases.

OK, so now let's get to the point. Is there any difference between GCC versions? Yes, there is, but you need to see that in different angles. So, for the `-Os`flag it seems that the `GCC7-2017-q4-major`produces a binary which is ~380 bytes smaller without `-flto`and ~550 bytes with `-flto`from the second better GCC version (GCC6). That means that GCC7 will save you from changing part to another one with a bigger flash, only if your firmware exceeds the size by those sizes with GCC6. But, what are the changes, right? We're not talking about 8051 here...

But wait... let's see what happens with the `-O3`though. In this case using the `-flto`flag GCC7 creates a binary which is 1KB smaller compared to the GCC6 version. That's big enough and that may save you from changing to a larger part! Therefore, the size matters also for other optimisation levels like the `-O3.` This also means that if your code size getting larger and you need the max performance optimisation, then the compiler version may be significant.

_"So, why not use always the latest GCC version?"_

That's a good question. Well, if you're writing your software from the scratch now, then probably you should. But if you have an old project which is compiling with an old GCC version, then this doesn't mean that it will also compile with `-Wall`in the newer version. That's because between those two versions there might be some new warnings and errors that doesn't allow the build. Hence, you need to edit your code and correct all the warnings and errors. If the code is not that big, then the effort may not be that much; but if the code is large then it means that you may need to spend much time on it. It's even worse if you're porting code that is not yours.

Therefore, the compiler version does matter for the binary size for all the available optimisation flags and depending your code size and processor you might need to choose between those versions depending your needs.

Have fun!