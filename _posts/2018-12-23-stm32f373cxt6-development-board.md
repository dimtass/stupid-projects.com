---
title: STM32F373CxT6 development board
date: 2018-12-23T00:15:55+00:00
author: dimtass
layout: post
categories: ["Microcontrollers", "STM32"]
tags: ["STM32", "STM32F373", "Kicad", "Electronics"]
img_src: "/images"
img_width: 580
img_extras: ".shadow"
---
## Intro

Probably most of you people that browsing places like this, you already know the famous _blue pill_ board that is based on the stm32f103c8t6 mcu. Actually, you can find a few projects here that are based on this mcu. It's my favorite one, fast, nice peripherals, overclockable and dirt cheap. The whole PCB dev board costs around 1.7 EUR... I mean, look at this.

![]({{page.img_src}}/ebay-stm32f103c8t6.png){: width="{{page.img_width}}" {{page.img_extras}}}

If you try to buy the components to build one and also order the PCBs from one the known cheap makers, that would cost more than 10 EUR per unit for a small quantity. But...

## There's a new player in town

Don't get me wrong, the stm32f103 is still an excellent board and capable to do most of the things I can image for small stupid projects. But there are also a few things that can't do. And this is the gap that this new mcu comes to fill in. I'm talking about the stm32f373, of course. The _STM32F373CxT6_ (I'll refer to it as f373 from now on) is pin to pin compatible with the _STM32F103C8T6_, but some pins are different and also is like its buffed brother. The new f373 also comes in a _LQFP48_ package, but there are significant differences, which I've summed in the following table.

 | STM32F373C8 | STM32F103C8
 -|-|-
Core | Arm Cortex-M4 | Arm Cortex-M3
RAM Size (kB)	| 16 | 20
Timers (typ) (16 bit)	| 12 | 4
Timers (typ) (32 bit)	| 2	| –
A/D Converters (12-bit channels) | 9 | 10
A/D Converters (16-bit channels) | 8 | –
D/A Converters (typ) (12 bit)	| 3	| –
Comparator | 2 | –
SPI (typ)	| 3	| 2
I2S (typ)	| 3	| –

So, you get a faster core, with DSP, FPU and MPU, DACs, 16-bit ADCs, I2S and more SPI channels, in the same package... This MCU is mind-blowing. I love it. But, of course is more expensive. Mostly I like the DACs because you can do a lot of stupid stuff with these and then the 16-bit ADC, because more bits means less noise, especially if you use proper software filters. The frequency is the same, so I don't expect much difference in terms of raw speed, but I'll test it at some point.

Also it's great that ST already released a standard peripheral library for the mcu, so you don't have to use this HAL crap bloatware. There's a link for that [here](https://www.st.com/en/embedded-software/stsw-stm32115.html). The _StdPeriphLib_ supports, now makes this part my favorite one, except that fact that... I haven't tested it yet.

## Where's my pill?

For the f103 we have the _blue pill_. But where's my f373 pill? There's nothing out there yet. Only a very expensive dev board that costs around $250. See [here](https://www.st.com/en/evaluation-tools/stm32373c-eval.html). That's almost 140 _blue pills_... Damn. Therefore, I had to design a board that is similar to the _blue pill_ but uses the f373. Well, some of you already thought of why not remove the f103 from the _blue pill_ and solder the f373 instead and there you are, you have the board. Well, that's true... You can do that, some pins might need some special handling of course, but where's the fun in this? We need to build a board and do a stupid project!

Well, in case you want to replace the f103 on the _blue pill_ with the f373, then this is the list with the differences in the pin out.

PIN	| F103 | F373
 -|-|-
21	| B10	| E8
22	| B11	| E9
25	| B12	| VREFSD+
26	| B13	| B14
27	| B14	| B15
28	| B15	| D8
35	| VSS_2 |	F7
36	| VDD_2 |	F6

So the problematic pins are mainly the 35 & 36 and that's because in case of the f373 the F7 is connected straight to ground and the F6 to 3V3 and that makes them unusable. According to the manual the F7 pin has these functionalities:I2C2_SDA, USART2_CK and the F6 these:SPI1_MOSI/I2S1_SD, USART3_RTS, TIM4_CH4, I2C2_SCL. That doesn't mean that you can't use the I2C2 as theI2C2_SDA is also available to pin 31 (PA10) and also the SPI1_MOSI is available to pin 41 (PB5) and I2C2_SCL to pin 30 (PA9). So no much harm, except the fact that those alternative pins overlap other functionalities, you might not be able to use.

Therefore, just change the f103 on the _blue pill_ with the f373, if you like; but don't fool yourself, this won't be stupid enough, so it's better to build a board from the scratch.

## The board

I've designed copied the schematics of the _blue pill_ and create a similar board with a few differences though. First, the components like resistors and capacitors are 0805 with larger pads, instead of 0603 on the original _blue pill_. The reason for that is to help older people like me with bad vision and shaky hands to solder these little things on the board. I'm planning to create a branch though with 0603 parts for the younger people. Soon...

I've used my favorite KiCAD for that as it's free, opensource and every open-hardware (and not only) project should use that, too. I think that after the version 5, more and more people are joining the boat, finally.

This is the repo with the KiCAD files:

[https://bitbucket.org/dimtass/stm32f373cb_board/src/master/](https://bitbucket.org/dimtass/stm32f373cb_board/src/master/)

And this is the 3D render of the board:

![](https://bytebucket.org/dimtass/stm32f373cb_board/raw/6c1c3021b4c7eaaee5b5372601d75bb4a1f3c9e8/stm32f373cxt6.png) 

## Conclusion

You can replace the f103 on the _blue pill_ with the f373, but that's lame. Don't do that. Always go with the hardest, more time consuming and more expensive solution and people will always love you. I don't know why, it just works. So, instead of replace the IC, build a much more expensive board from the scratch, order the PCBs and the components, wait for the shipment and then solder everything by yourself. Then you have a great stupid project and I'll be proud of you.

Have fun!