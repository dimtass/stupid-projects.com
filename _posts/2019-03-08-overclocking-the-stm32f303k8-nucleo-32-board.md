---
title: Overclocking the stm32f303k8 (Nucleo-32 board)
date: 2019-03-08T13:03:20+00:00
author: dimtass
layout: post
categories: ["Microcontrollers", "STM32"]
tags: ["STM32", "STM32F303"]
img_src: "/images"
img_width: 580
img_extras: ".shadow"
---
## Intro

> **Note**: because I had to recover the db and there wasn't a backup of this post, the oscilloscope screenshots and the comments were lost 🙁

Few weeks ago I’ve done a stupid project[here](https://www.stupid-projects.com/stm32f373cxt6-development-board/)in which I’ve designed a small deb board that is similar to the _blue pill_ board (which uses the stm32f103c8t6). The difference is that I’ve used the stm32f373c8t6. In the meantime, I’ve delayed the PCB order; because I wanted to do some changes, like use 0603 components and remove the extra pad areas for hand-soldering. And before do those changes, then one day **BOOM**! I’ve seen this[NUCLEO-F303K8](https://www.st.com/en/evaluation-tools/nucleo-f303k8.html)board, that looks like the blue-pill and said, ok, lets order this and screw the custom board, who cares. Therefore, as a proper engineer, I’ve order two boards (one is never enough) without even read the details and after a couple of days these boards arrived.

![]({{page.img_src}}/stm32f303k8.jpg){: width="{{page.img_width}}" {{page.img_extras}}}

Double win; I thought. It shipped faster and I don’t have to do any soldering. So, I got home and opened the packaging and**BOOM**! WTF is this?!? Why does it have 2 mcus? Where is the connector with the SWDIO and SWCLK pins to flash it with my st-link? Why there’s also an stm32f103c8t6 on the back side of the PCB? What’s going on here?

Oh, wait… Oh, nooo… And then I’ve realized all the reasons why you should always read the text around the pictures before you buy something. Of course, I’ve spontaneously forgiven myself, so I can repeat the same mistake the next time. After reading the manual (always RTFM), I’ve realized that the USB port is not connected on the stm32f303 and the stm32f103 was the on board st-link and I’ve also realized the reason that the board was a bit more expensive than I expected (though Arrow had a lower price compared to others). I’ve also realized that the stm32f303 was the small brother of the family, so no USB anyways, no much RAM and several other things. But, it still has all the other goodies like 2x DACs, opamp, ADCs, I2C, SPI e.t.c. Enough goodies for my happiness meter not to drop that much.

## Project

After the initial sock, I said to myself, ok let’s do something simple and stupid at least, just to see that it works. I’ve plugged the USB cable, the leds were flickering, cool. Then I’ve seen this _ARM mbed enabled_ thing on the case and although I was sure that it would be something silly, I wanted to try it. So, after spending ~30mins I found out that I’m not the only one that does stupid things. ARM elevates that domain to a very high standard, which is difficult to compete. I’ve tried mbed before, but that was a lot of years ago when it started and it was meh, but I didn’t expect it to be still so much.. meh. I mean, who the heck is going to develop on an online IDE and compiler and do development on libs that can’t have access to fix bugs or hack? What a mess. Sorry ARM, but I really can’t understand who’s using this thing. This is not a _professional_ tool and Hobbyists have much better tools like the various Whateverduinos. So after loosing 30 mins from my life, I’ve decided to make one of my standard cmake templates. Simple. But… I needed also to do something stupid on top, so I’ve decided to add in my template a way to overclock the stm32f303. Neat.

And yes… In this project you’ll get an stm32f303k8 overclocked up to 128MHz (if you’re lucky). And it seems that is working just fine, at least both of my boards worked fine with the overclock.

## Source

You can download the source code from here:

[https://bitbucket.org/dimtass/stm32f303k8_template/src/master/](https://bitbucket.org/dimtass/stm32f303k8_template/src/master/)

This template is quite simple, just a blinking LED and a USART port @115200 baud-rate. You can use this as a cmake template to build your own stuff on top of it. So, let’s have a look in the `main()` function to explain what is going on there.

```c
int main(void)
{
    /* Initialize clock, enable safe clocks */
    sysclk_init(SYSCLK_SOURCE_INTERNAL, SYSCLK_72MHz, 1);
    RCC_ClocksTypeDef clocks;
    RCC_GetClocksFreq(&clocks);
    /* Get system frequency */
    SystemCoreClock = clocks.SYSCLK_Frequency;
    if (SysTick_Config(SystemCoreClock / 1000)) {
        /* Capture error */
        while (1);
    }
#ifdef BENCHMARK_MODE
    setup_dgb_pin();
#endif
    /* setup uart port */
    dev_uart_add(&dbg_uart);
    /* set callback for uart rx */
    dbg_uart.fp_dev_uart_cb = uart_rx_parser;
    dev_timer_add((void*) &dbg_uart, 5, (void*) &dev_uart_update, &dev_timer_list);
    /* Initialize led module */
    dev_led_module_init(&led_module);
    /* Attach led module to a timer */
    dev_timer_add((void*) &led_module, led_module.tick_ms, (void*) &dev_led_update, &dev_timer_list);
    /* Add a new led to the led module */
    dev_led_init(&led_status);
    dev_led_set_pattern(&led_status, 0b00001111);
    set_trace_level(
            0
            | TRACE_LEVEL_DEFAULT
            ,1);
    printf("Program started\n");
    printf("Freq: %lu\n", clocks.SYSCLK_Frequency);
    print_clocks(&clocks);
    while(1) {
#ifdef BENCHMARK_MODE
        GPIOB->ODR ^= GPIO_Pin_4;
#else
        main_loop();
#endif
    }
}
```

The first function is the one that sets the system clock. The board doesn’t have an external XTAL, so the internal oscillator is used. The default frequency is 72MHz, which is the maximum `official` frequency. In order to overclock to 128MHz, you need to call the same function with the `SYSCLK_128MHz` parameter. Also, the first parameter of the function is selecting the clock source (I’ve only tested the internal as there’s no XTAL on this board) and the last parameter for using safe clocks for the other peripheral buses when using frequencies more that 64MHz. Therefore, when overclocking to 128MHz (or even 72MHz) if you want to be sure that you don’t exceed the official maximum frequencies for the PCLK1 and PCLK2 then set this flag to 1. Otherwise, everything will be overclocked. I live dangerously, so I’m always leaving this to 0. If that mcu had a USB device controller then when oveclocking it can’t succeed the frequency that is needed for the USB, so you need to stay at 72MHz max (only if you have a USB device, but the 303 doesn’t have anyways).

After the clock setting, you need to update the `SystemCoreClock` value with the new one and you can call the `print_clocks(&clocks)` function to display all the new clock values and verify that are correct. For example, in my case with the sys clock set to 128MHz I get this output from the com port:

```
Freq: 128000000
Clocks:
  HCLK: 128000000
  SYSCLK: 128000000
  PCLK1: 64000000
  PCLK2: 128000000
  HRTIM1CLK: 128000000
  ADC12CLK: 128000000
  ADC34CLK: 128000000
  USART1CLK: 64000000
  USART2CLK: 64000000
  USART3CLK: 64000000
  UART4CLK: 64000000
  UART5CLK: 64000000
  I2C1CLK: 8000000
  I2C2CLK: 8000000
  I2C3CLK: 8000000
  TIM1CLK: 128000000
  TIM2CLK: 0
  TIM3CLK: 0
  TIM8CLK: 128000000
  TIM15CLK: 128000000
  TIM16CLK: 128000000
  TIM17CLK: 536873712
  TIM20CLK: 128000000
```

I’m using the [CuteCom](https://gitlab.com/cutecom/cutecom)for the serial port terminal, not only because I’m a contributor, but also these macros plugin I’ve added is very useful for doing development with mcus and UARTs.

On the above output, don’t mind the `TIM17CLK` value, there’s no such timer anyways.

To do some benchmarks with the different speeds, then you need to uncomment the`#define BENCHMARK_MODE` line in the `main.c` file. By doing this the D12 pin (PB.4) will just toggle inside the main loop. So… it’s not really a benchmark, but still is something that is affected a lot by the system clock frequency.

The rest of the lines in the `main()` are just for setting up the LED and the UART module. I’ve developed those modules initially for the stm32f103, but it was easy to port them for the stm32f303.

One very important note though! In order to make the clock speeds to work properly, I had to make a change inside the official standard peripheral library. More specific in the `source/libs/StdPeriph_Driver/src/stm32f30x_rcc.c` file in line 876, I had to do this:

```c
/* HSI oscillator clock divided by 2 selected as PLL clock entry */
//        pllclk = (HSI_VALUE >> 1) * pllmull;
        pllclk = HSI_VALUE * pllmull;
```

You see, by default the library divides the `HSI_VALUE` by 2 (shifts 1 right), which is wrong (?). They probably do this because they enforce that way the /2 division of the HSI and do all the clock calculations depending on that. Therefore, if you overclock ,then all the calculated clock values for the other peripherals will be wrong because they are based on the assumption that the HSI value is always divided by 2. But that’s not true. Therefore, the baud rate of the USART will be wrong and although you set it to 115200bps, actually it will be 230400bps. If you want to use the PLL with the HSI as an input clock then you need a way to do fix this. Therefore, I’ve changed this line in the standard peripher library, so have that in mind in case you’re porting code to other projects. Also, have a look in the `README.md` file in the repo for additional info.

## Benchmarks

Finally! Let’s see some numbers. Again, this benchmark is stupid, just a toggling pin and measuring how the toggling frequency is affected from the system clock frequency. I’m adding all the images on the same collection so you can click on them and scroll.

**Note**:_The code is build with the`-O3` optimization flag._

![]({{page.img_src}}/stm32f303k8_template_16mhz.png){: width="{{page.img_width}}" {{page.img_extras}}}
![]({{page.img_src}}/stm32f303k8_template_32mhz.png){: width="{{page.img_width}}" {{page.img_extras}}}
![]({{page.img_src}}/stm32f303k8_template_64mhz.png){: width="{{page.img_width}}" {{page.img_extras}}}
![]({{page.img_src}}/stm32f303k8_template_72mhz.png){: width="{{page.img_width}}" {{page.img_extras}}}
![]({{page.img_src}}/stm32f303k8_template_128mhz.png){: width="{{page.img_width}}" {{page.img_extras}}}


So, in the above images you can see the frequency of the toggling pin for each system clock, but let’s add them on this table, too.


System clock (MHz) | Toggling speed (MHz)
16	| 1.33
32	| 2.66
64	| 3.55
72	| 3.98
128	| 7.09

Indeed the toggling frequency scales with the system clock, which is expected. Isn’t it? Therefore, at the maximum system clock of 128MHz the bit-banging speed goes up to 7.09MHz, which is_ok’ish_and definitely not impressive at all. But anyway it is what it is. At least it scales properly with the frequency.

And if you think that this is slow, then you should think that most of the people develop with the debug flags enabled in order to use the debugger and sometimes they forget that they shouldn’t use it for development unless is really needed or there’s a specific problem that you need to figure out and you can’t by adding traces in you code. So let’s see the toggling speed at 125MHz with the debug flags on.

![]({{page.img_src}}/stm32f303k8_template_128MHz_debug.png){: width="{{page.img_width}}" {{page.img_extras}}}

Ouch! Do you see that? 2.45MHz @ 125MHz system clock. That’s a huge impact in the speed; therefore, try not using debuggers when they are not essential to solve problems. From my experience, I’ve used a debugger maybe 5-6 times the last 15 years. My debugger was always a toggling pin and a trace with the uart port. Yeah, I know, that might take more time to debug something, but usually it’s not something that you do a lot. This time, I had to use it though, because in the standard peripheral library for this mcu, they’ve changed the interrupt names and because of that the UART interrupts were sending the code to the `LoopForever` asm in the source/libs/startup/startup_stm32.s. By using the debugger I’ve just seen that the interrupt was sending the code in there and then in the same file I’ve seen that the interrupt names for the USART1 and 2, were different compared to the stm32f103. That happened because I’ve ported my `dev_uart` library from the stm32f103 to the stm32f303.

## Conclusion

Before you buy something, always RTFM! That will save you some time and money. Nevertheless, I’m not completely disappointed for ordering this module. I’m more disappointed that I’ve seen that mbed is what it is. That’s sad. I think the time that some brilliant guys spend for this and I can’t really understand why. Anyway...

On the other hand, those mcus seem to be behave just fine at 125MHz. I’ve tried both modules and both were working fine. I guess I’ll do something with them in the near future. The on-board st-link is also (I guess) a cool feature, because you have everything you need on one module, but I would prefer if I just had the SW pins to use an external st-link and buy more modules in the half price (or even less). If anyone is thinking buying one of those, then they seem to be ok’ish.

Have fun!