---
title: STM32 cmake template (with more cool stuff)
date: 2019-04-15T20:40:25+00:00
author: dimtass
layout: post
categories: ["Microcontrollers", "STM32"]
tags: ["STM32", "STM32F103", "CMAKE", "libopencm3"]
img_src: "/images"
img_width: 580
img_extras: ".shadow"
---
## Intro

While I'm still waiting for some parts for my next stupid project, I was a bit bored and decided to clean up my STM32 cmake template that I'm usually using for my _bluepill_ projects. I mean, I was pretty happy with it since now and it was working fine, but there's no better wasted time than doing the same thing again to get the same result and have the illusion that this time is better. So, this deserves a post  
to the stupid-projects.

Anyway, while I was about to waste my time on that, I've though it would be a nice thing to make it support a few
different libraries. Cmake, is something that you either love or hate. I do both. The good thing is that you can
achieve the sameresult by following a number of different ways. This is a nice thing, but also can be a trouble.
The reason is that, if there was only a single valid solution or a way to do create a cmake build then it would be
difficult to make errors. You would make a lot of mistakes until make it work, but when it worked, that would be
the only right way. On the other hand, if there are many different ways to achieve the same result, then there are
good and bad ways. And for some unknown universal law, the chance to choose the worst way is much higher that
selecting every other way, good or bad.

Therefore, cmake gets both love and hate from my side. In the end, it's all about experience. If you do something
very often, then after some time you learn to choose the better ways. But if you create a cmake project 1-2 times
per year, then then next time you deal with your own `CMakeList.txt` files and you have to re-learn everything you've
done, then you realise how many things you've done wrong or you could do them better. Also the cmake documentation
reminds me a law textbook. There are tons of information in there, but written in a way that stupid people like me
can't understand the documentation and need to read a cmake cookbook or see examples in the internet. Then everything
gets clear.

## Project

I'm using a lot the standard peripheral library from ST. In general, I hate the monstrous HAL API and the use of C++ when it's not _really_ needed, but I like CubeMX, because it's nice to calculate clocks and play around with the pinout. Also, when I'm using the USB on the stm32f103c8t6 (blue-pill), I'm always using the ST's USB FS Device Driver that is compatible with the standard peripheral library. That combination is beautiful. I've found a couple bugs, which I've fixed and everything is great. I can say that I couldn't need anything else than that.

I know that there are plenty people that like the HAL API and using C++ with the STM32 and that's fine. If you like using that, then keep doing it. For my perspective, is that the HAL API is something that doesn't provide anything more that the stdperiph library and also there are so many layers of software between the actual API and the CMSIS level, that it doesn't make sense. For me it's too much complicated and when it breaks it's not just open the mcu datasheet and find the error, but you also need to debug all that software layer in between. Sorry, no time for this. Regarding the C++, I've wrote a post before [here](https://www.stupid-projects.com/c-vs-c-for-embedded/). Generally, there's no right or wrong. But personally I prefer to write C++ when I'm developing a Qt app or when I really need some things that the language can make my code cleaner, more portable and faster. If it can't do that, then I see no reason to use it. Also, the libraries are C libraries with C++ wrappers in the headers. That means something. Therefore, I need to be convinced that C++ will actually be better than C for the specific project, otherwise I'll go with C.

There is also another project that supports the stm32 and plenty of other mcus and it deserves more love. This is the [libopencm3](https://github.com/libopencm3/libopencm3) project. That is actually a library that replaces the standard peripheral library from ST. This is a very nice library. It's low level library and based on CMSIS. It gets updated much more often that the stdperiph and the project is active. For example, I see now that the last update was a few hours ago (that doesn't mean that it was for stm32f1) and at the same time the last version of the stdperiph was in 2012, so 7 years ago. Also another neat thing with libopencm3 is that everyone can join the project and send commits to add functionality or fix bugs. I'm thinking to commit the stm31f1 overclocking patch I have to clock the stm at 128MHz, but I guess this won't be accepted as it's out of specs, but anyway I'll try, he he. So, yeah libopencm3 deserves more love and I think that sometimes you may also create smaller code.

So I've decided to add support to the cmake template also for the libopencm3.

Finally, let's go to FreeRTOS. I guess, everyone knows what that is and I guess there are a lot of people that love it. Well, I respect rtos. I mean most of my work is done on embedded Linux, so I know about rtos. But still until today, I never, never had to really use an rtos on a small embedded mcu. Until today there was nothing that I couldn't do using state machines. I've also written a very nice and neat lib for state machines and I think I should open-source it at some point. Anyway, I never had to use an rtos on an stm32 or other small mcu, but I guess there are needs that other people have. From my perspective it seems that simplifies things and produces less code and complexity, but on the other hand you loose more important things like full control of the runtime and also there's a hit in performance. But anyway, it's fun to have it as an option for prototyping and write small apps while you don't want to mess with timers and interrupts.

Hence, in this cmake template you get all the above in the same project and you are able to select which libraries to enable by selecting the proper options in the cmake. But let's have a look. This is the repo here:

[https://bitbucket.org/dimtass/stm32f103-cmake-template/src/master/](https://bitbucket.org/dimtass/stm32f103-cmake-template/src/master/)

After you clone the repo, there is a very interesting README.md file that you should read. It's supposed to written in a way that is easier to understand, compared to the cmake documentation. Also, another important file is the `build.sh` script that it handles all the details and runs cmake with the proper options.

So let's see what those options are. The only thing you need to build the examples is to run the `build.sh`script with the proper parameters. Inside the build script you'll find all the supported parameters, but not all of them are needed to be set everytime.

- `TOOLCHAIN_DIR`: This points should point to your toolchain path
- `CMAKE_TOOLCHAIN`: This points to your cmake toolchain file. This file actually sets up the toolchain to be used. When working with the blue-pill, you wouldn't need to change that.
- `CLEANBUILD`: This parameter is either <code>true</code> or <code>false</code>. When it's true then the build script will delete the build folder and that means that you'll get a clean build. Very useful, especially if you're making changes to your cmake files, in order to remove the cmake cache. By default is <code>false</code>.
- `ECLIPSE_IDE`: This is either `true` or `false`. If that's `true` then the cmake will also create Eclipse project files so you can import the project in Eclipse and use it as an IDE to develop. That's a handy option because of intellisense. By default is `fault` because I usually prefer the VS Code.
- `USE_STDPERIPH_DRIVER`: This option can be `ON` or `OFF` and enables or disables the ST's standard peripheral driver and the CMSIS lib. By default is set to `OFF` so you need to explicitly set it to `ON` during build.
- `USE_STM32_USB_FS_LIB`:This option can be `ON` or `OFF` and enables or disables the ST's USB FS Device Driver.By default is set to `OFF` so you need to explicitly set it to `ON` during build.
- `USE_LIBOPENCM3`:This option can be `ON` or `OFF` and enables or disables the `libopencm3` library. By default is set to `OFF` so you need to explicitly set it to `ON` during build. You can't have this set to `ON` at the same time with the `USE_STDPERIPH_DRIVER`
- `USE_FREERTOS`: This option can be `ON` or `OFF` and enables or disables the `FreeRTOS` library. By default is set to `OFF` so you need to explicitly set it to `ON` during build.
- `SRC`: With this option you can specify the source folder. You may have different source folders with different projects in the `source/` folder. For example in this template there are two folders the `source/src_stdperiph` and the `source/src_freertos` so you can select which one you want to build, as they have completely different projects and need different libraries.

The two example projects, as you can guess from the names, are for testing the stdperiph and the freertos/libopencm3 libs. To build those two projects you can run these commands:

```sh
# stdperiph
CLEANBUILD=true USE_STDPERIPH_DRIVER=ON SRC=src_stdperiph ./build.sh

# FreeRTOS & LibopenCM3
CLEANBUILD=true USE_LIBOPENCM3=ON USE_FREERTOS=ON SRC=src_freertos ./build.sh

# Create Eclipse projects files
CLEANBUILD=true USE_STDPERIPH_DRIVER=ON ECLIPSE_IDE=true SRC=src_stdperiph ./build.sh
CLEANBUILD=true USE_LIBOPENCM3=ON USE_FREERTOS=ON ECLIPSE_IDE=true SRC=src_freertos ./build.sh
```

So, yeah, pretty much that's it. Easy and handy.

## Conclusion

This was a re-write of my cmake template and as cherry on top I've decided to add the support for the FreeRTOS and LibopenCM3. I'll probably use more often the libopencm3 in the future, ot at least evaluate it enough to see how it performs and regarding the FreeRTOS, I think it's a nice addition for prototyping and use tasks instead of writing code.

Finally, one note here. Be careful when you use the `-flto` flag in the GCC optimisations, because this completely brakes the FreeRTOS. For example you can build the freertos example and flash it on the stm and you get a 500ms toggling LED, but it you add the `-flto` flag in the `COMPILER_OPTIMISATION` parameter in the main CMakeLists.txt file then you'll find out that the `vTaskDelay` breaks and the pin toggling very fast.

Have fun!