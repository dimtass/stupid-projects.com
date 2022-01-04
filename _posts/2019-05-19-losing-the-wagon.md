---
title: Losing the wagon
date: 2019-05-19T13:18:04+00:00
author: dimtass
layout: post
categories: ["Opinion"]
tags: ["Opinion"]
img_src: "/images"
img_width: 580
img_extras: ".shadow"
---
## Intro

This post is not about a stupid-project, but it's a bit more philosophical and it's about losing the wagon. Well, life has many wagons, but let's narrow it to the technological and engineering wagon. This is an engineering blog after all.

The last couple of days I was exploring what's the current state of the home automation domain and specifically for
the `KNX`. I've started developing for the KNX bus back in 2007. The trigger was a friend of mine, who's an electrical
engineer and started talking about this fancy new KNX bus around in 2006-2007 (if I remember correctly) and which
derived from the Instabus. He got my attention as he already have made some KNX installations and soon I got
involved into it. I was fascinated with it and I wanted to start build stuff around it.

The `KNX` standard is supposed to be an open standard at the time, but it wasn't really. Back then there were only few
information around it and you needed to buy the specifications (which were expensive). So, I had to do a lot of stuff
by my self. The only thing that was available it was the [BCUSDK](https://sourceforge.net/projects/bcusdk/files/bcusdk/). This project started in 2005, but it was all that I needed. From this code I've managed to extract and understand
the protocol and most things around it. The details weren't obvious, of course, because the code wasn't documented but
having some KNX devices to experiment with and the code it was enough to do everything I wanted. Also a friend of mine 
(also an engineer) got fascinated with it and soon we got our KNX certification and in no time we've developed a whole 
platform around it. This included APIs, GUI interfaces and gateways to many standard protocols used at the time (IP, 
RS232, RS485) and gateways to GSM modules, GPS, Alarm systems and several other stuff.

Well, it was brilliant at the time and there wasn't anything like that back in 2007. We could beat any competition. 
And then... for some reasons we just stopped. I don't even remember the excuse at the time to be honest. But I know 
the real reason now. That was around in 2008-2009.

Now, I've checked again and the KNX automation domain has completely transformed to a huge market and code-base. 
Several different APIs for several programming languages exist. Python, C/C++, even a `KNX` module for Qt. I've wrote a 
KNX module in Qt in 2008 by myself and now I've seen that last year there was a new module in Qt for that. After 10 
years!

So, I was 10 years ahead than the market. I've seen the wagon of this train more that 10 years ago and all its potentials. I've developed a whole system around it and I let it die, thus losing the wagon and the train. Now you can find almost everything and many stuff are open source, which is great. There is even a Yocto layer with all those tools included. It's the [meta-calaos](http://layers.openembedded.org/layerindex/branch/master/layer/meta-calaos/).

Trust me, it may seem a bit disappointing to realize that you've lost the wagon and see how the market has ended today; and knowing that you were there 10 years ago and just did nothing. But, is it really? So, when this happens the most reasonable thing you need to do is ask yourself, why? Actually, not only a single `why` but several `whys` and then when you find the reasons and make some decisions for yourself, even knowing yourself better.

And this is what this post is all about.

## Some thoughts

I guess I'm not the only one that had this situation. Some of you know exactly what I'm talking about and already being there at least once. Well, also for me this was not the first time. I had that more that once, but the above case hit me harder as I was pioneer and 10 years earlier than the rest of the market. Well, in my case I know why I've failed. The reason is that I'm a _lazy_ engineer. I'll come back to this phrase later.

I've seen many engineers in my life. Mostly _not-really-good_ engineers, for my standards. Although, in my professional career I've been told that I'm a good engineer and I know that I'm capable to do stuff, at the same time, I don't consider myself a -good- engineer. What is -good- engineer after all? No one should consider himself a -good- engineer. If you do that, then it's over. Of course, when it comes to the professional aspect then you need to present yourself as a good engineer and it's easier to do that if others already believe it. But in the end I just consider myself just an engineer. And this is a good and a bad thing at the same time.

Being an engineer is only a part of what you are in your professional career. You're not only an engineer. You are also a salesman, a manager, a director and a CEO. You're everything at the same time. At least you become those things after a few years in your domain, it's the natural evolution which is called experience. But it's the proportion of these analogies that you have and that makes and drives your professional career. Some people are better managers than engineers. Other might have more _CEO-like_ qualities than the rest. So, you can't have all the qualities in a high level at the same time. You may have one or two, but it's extremely rare that you have everything. But, is that really a problem?

For example, I'm a _lazy_ engineer. _Lazy_, doesn't mean that I'm really lazy to do something. Actually it's the opposite. I can drive myself to finish a project and complete it in the best and most optimal way. But then I need to do something else. I can't stay on that for a long time. I can't devote myself to a single project or domain and stay there forever. If I try to do that, then it makes me lazy in the end. I'm getting bored and I start hate what I do. And thus, I'm a _lazy_ engineer. Well, at least until now I haven't find a project or domain that I would like to stay forever.

But being a _lazy_ engineer had its flaws. For example, in this case I was 10 years in advance compared to the market and then I got bored. So, I got lazy. Therefore, I had to just drop everything and go to the next challenge. Otherwise, I would doom myself in a situation that I would hate what I'm doing. Maybe some of you can understand this, maybe others don't. It's not necessary that every engineer is the same. We have different qualities and proportions of them and that's fine!

I've met engineers that they are not so skilled, but they devoted themselves to an idea and a project and they succeeded to make it their main source of income. Many of those projects and ideas for me were so easy to develop and implement and even boring to even start doing them. They were just too simple for me, from the engineering aspect. But, they were profitable! And some engineers struggled to do something which for me seemed so easy and they made a profit out of it. Others didn't, though. I believe those who did, were also a bit lucky, but all of them they were devoted and better salesman than engineers. Being able to sale something is more important that be able to build it in the best possible engineering way. The product may have it's flaws, it may need several iterations until it gets released, it may even released and be a crap from the engineering aspect. But does this matter in the end? If it you make a profit and a business case out of it then it's successful in mainstream market terms.

You don't have to be an expert in something to do stuff. I've programmed in more than 10 programming languages as a professional. I may be an expert only on 2-3 of them, but it doesn't really matter. You don't need to be an expert in any programming language to make something that works and be profitable. Writing code is the most easy thing to do. Does it matter if it's the best code? If you do it the pythonic, or yoctonic or C++17 way? All the code you ever written in the end is just crap. It's a mess, unless it's just a few lines that do a very specific thing. You might though you've written the best code 5 years ago and if you see that code today you'll hate yourself for writing that crap. But, it doesn't matter. Really. You become an expert in something, more as a _professional skill_ that it will make it easier for you to find a better job; but if you want to realize your own ideas and make that a product, then it doesn't matter if you're an expert. It never mattered.

Therefore, who's the successful engineer in the end? The one that managed to devote himself in a product and release it in the market and make a profit, or the one that one that didn't? The one that is expert in 1-2 things or the one who's capable in 10+? The one that delivers fast or the one that delivers something robust and well-engineered? The one that sees 10 steps further or the one that can focus on the current step? Don't try to answer this question too fast.

I think that the success is to be satisfied in what you do and be happy with what you achieved in the end of your work. This sentence is a bit vague though, because what makes you happy now it doesn't mean that it will make you happy in the future. But do you really know the future? No. So, what is left is what makes you a happy engineer now. And if you're happy then it probably means that you're also successful in what you do.

Therefore, making your own best-selling project and profit from your awesome idea is not necessary what will make you happy and a successful engineer. So, first you need to focus and find what makes you happy as an engineer and even more if engineering actually is making you happy at all. Because you might be a very good engineer and not be happy being an engineer. You need to know your assets and your values and what to expect from yourself.

Sure, it would be a great thing to become a successful engineer that will have a profitable idea and make a product out of it. But it's not really necessary. Is it? It might happen, it might not. Maybe you even say it loud to yourself sometimes, but in the back of your head you don't really want it or believe it. Because in the end everything comes with a price and you already know it. So, if your idea becomes successful, then you need to devote to it. You need to stop being an engineer and be a salesman, a CEO and whatever comes with it. But certainly not an engineer anymore. You will spend more time in managing things and do stuff unrelated to the engineering domain and you will fade as an engineer. That depends if it's good or bad. If you like manage things and prefer it more than being an engineer then it's great! But you also need to be capable with managing things, not just like it. Therefore, you need to know what you want to be and you need to know if you have the proper skills for that and if you don't try to develop them.

If you know what makes you happy, then do it, but first consider all the consequences and be certain that you can judge yourself and skills right.

For me, being an engineer is not really a job. It's just a hobby and it's fun to explore new things and have different challenges. In my job I may don't have the freedom to do exactly what I want every time, but I'm also doing a lot of stuff in my free time, without a profit. And I'm happy. It's more like a lifestyle. What you do in your life, should be fun. And I feel lucky that it's still fun for me. So, I don't really have regrets about missing opportunities, because all the missing (or not) opportunities brought me to this point today. In the end, the only thing that matters is to know what makes you happy. You don't have to be the best in something or find the best idea and make a huge profit. All you have to be is happy with what you do.

If you're lucky enough to be happy with what you do, then you are a successful engineer and no matter what wagons you've lost or losing down the path, you're always on your happiness wagon and do the things that you like. And that's the best wagon you can ever be in your professional career.

Have fun!