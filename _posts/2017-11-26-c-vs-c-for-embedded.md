---
title: C++ vs C for embedded
date: 2017-11-26T15:23:14+00:00
author: dimtass
layout: post
categories: ["Embedded"]
tags: ["Embedded"]
img_src: "/images"
img_width: 580
img_extras: ".shadow"
---
## Intro

Hi all! Well... I won't write about a stupid project this time. I'll write just my opinion about this endless debate between embedded engineers (usually old and new ones). The reason to debate usually is:

> Which language is better for embedded?

And then the flame begins to end up to a battle with endless references and assembly code outputs.

## Conclusion

I'll answer this for you straight away. Use whatever language you like and you're really good at when you do your own personal projects; and when working as a professional use the language of your company's codebase. See? Simple! Why debate at all?

## Details

Now, lets cut a few things in to pieces and get into more details. First things first, we need definitions. Without definitions there is no reason to even bother chat about. Therefore, the first definition is:

> What is embedded?

Well, that's a tough one. Embedded could be described much easier 10-20+ years ago. You had a 8 or 16-bit microcontroller (if you were lucky) and you had to write either assembly or C to make it do something meaningful. Then microprocessors became more powerful, dirt chip and they could easily run Linux. Now, you can by a Orange Pi Zero or RPi Zero for less than $7.

So now, embedded has a much more wider meaning, because now you can develop applications for an embedded board that can use a much larger code base written in C++, have threads and all the goodies that the Linux kernel can provide. Therefore, it's important to distinguish the level of an embedded project to the discussion.

It's much easier to give an answer to the main question when talking about high level embedded. At high level embedded design that runs Linux, to develop a user space app you can use C, C++ and a dozen more languages, you name them. In this case use whatever you like, but use your tools smart. Does it really matter if you use a bash script or python or write you own code in C/C++ or whatever language to access SPI or I2C? Well, not really... If for example you need to just update the configuration for the PLLs in an I2C clock chip, then it really doesn't matter. I would use Python there. Open a jedec file, parse it and then configure the chip in 20 lines of code. To do the same in C/C++ for example it would take dozens of code lines. Is execution speed an important factor here? Nah.. So, don't be dogmatic about your tools and use your tools smart. Therefore, especially for high level embedded stuff, you need to check you specs, weight your solutions and then pick up the easiest solution that does the job and doesn't affect other processes. Also using STL and libs like Boost, may be much faster to implement your app instead of using C. So, why bother using C there?

The lower embedded answer is easy, too; but it also might be a bit complicated in some occasions. In the lower embedded domain I include every microprocessor that doesn't have enough horsepower to run a full blown Linux kernel with enough storage for a rootfs. So, let's say it's every MCU from Cortex-M7 and lower. You might find a few projects with M4 and M7 running some micro-Linux distros, which are slow, though; so still I classify these cores as low embedded MCUs. Enough with definitions.

Therefore, in the lower embedded domain there are many things that need considering, like the supported tools, the existing code base, your fluency in a language and the vendor support.

Does your MCU tools really support C++? If you're using GCC then the answer is yes, but that's not always the case. There are still vendors that they don't have C++ compilers for their MCUs or these C++ compilers are not ones to trust. In this case you need to go with C. Also, the vendor may supply libraries only for C then in this case go with C.

Some times, the vendor may support both C and C++ and have libraries for both languages but one of them might be bad written, obscure or buggy. For example, the HAL framework for the STM32 belongs to that category, so in this case if you're limited with C++ choose another MCU or find alternative 3rd party C++ libs (if they exist) or if you're not limited with C++ then go with StdPeriph and C.

What is your existing code base? If you're working for a company (or even if you have a personal code base, which is usual after a few years) then go with your code base. It's almost impossible, dangerous and time/money consuming to convert all you code base from C to C++ or the opposite. Why do that? Don't! Use the language that your code base uses. That way you'll use a well tested code, probably free of bugs and you'll only need to use fragments and snippets that you already have. I've tried to convert projects from C to C++. Of course, it's fun in the beginning and then when you proceed to more complex code, you may realize that you're too bored to do this and you've already spend much time on it. This sucks, but tbh you need to try this at least once, for a small project. Therefore, go with your code base!

In which language you're really good at? I mean, really really good! Feel like a pro. If you feel this for a specific language then go with it, at least for a professional project. Yes, of course learning new languages is cool and you should do that anyways, but when it comes to a project with deadlines don't choose the language you're fancy with, but your best weapon. Do I really need to elaborate on this? It should be crystal clear. You don't want to come near a deadline and realise that you don't know your tools well enough to overcome issues. Oh, no. That would be a nightmare. I think the experience on a language is not how to write the syntax and standard functional procedures, but all the little minor bits under the hood that you'll only need once in a single project and if you don't have the experience, it will hit you back. Hard. So, are you fluent in C++ and not in C, then go with C++.

## Do you need to learn C++ for embedded?

Right now, C is enough to do everything on almost any embedded platform. So, do you really need to learn C++? Well, it wouldn't hurt! Actually, you should do it, at some point. It's not necessary, but it's a plus for your skills. Also, you need to do it for the right reasons. For example, I've heard from other engineers that C++11 is nice because it has auto and lambas. So, what? That's not a reason to learn C++11 just because of that. Besides there's no difference for a good compiler like GCC if you use a normal function or a lambda. Also, some people don't like the readability or obscure layer that an auto variable adds to the code while they reading a program; which is fair. Learn C++ to complement your skills not to go with the hype or substitute C on any embedded development. If you're not using STL at all, then maybe just learn C++ for future use or for fun, otherwise you probably don't need it.

As I see the embedded development world right now, it's good to know both. You can develop high embedded Linux apps that use STL using C++ and use C for the kernel, u-boot and whatever other use you like. Also, for Linux user space given that you have enough horsepower use whatever language you like; but always try to be moderate. I find using Python or bash scripts to be an effective way to do difficult tasks in less time, especially in cases that the process speed is not trivial. But I don't like to see resources like CPU cycles and RAM to be spent carelessly without optimisations and well thought decisions.

I'll close this post with the following quote:

> Use your tools smart, use whatever does the job right and always be moderate.

Have fun!