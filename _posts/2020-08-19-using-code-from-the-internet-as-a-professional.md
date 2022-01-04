---
title: Using code from the internet as a professional
date: 2020-08-19T10:10:08+00:00
author: dimtass
layout: post
categories: ["Opinion"]
tags: ["Opinion"]
img_src: "/images"
img_width: 580
img_extras: ".shadow"
---
## Intro

One of the most popular and misunderstood beliefs in engineering and especially in programming is that professional engineers shouldn't use code from the internet. At least I've heard and read about this many times. Furthermore, using code from the internet automatically means that those who do it are bad engineers. Is there any truth to this statement, though? Is it right or wrong?

In this post I will try to give my 2 Euro-cents on this matter and try to explain that there's not only black and white in programming or engineering, but there are many shades in between.

## Be sure it's not illegal

OK, so first things first. If and when you're using code from the internet you need to first make sure that you comply with the source code licence. It's illegal and furthermore not ethical to use any source code in a way that is against its licence.

One thing about licences is that there are many people that use licences without really knowing what they mean. That's pretty much expected, because licences tend to be a very complicated document with many legal terms and sometimes not clear indications how it can be used. Also the number of open source licences are too many. It's easy to get lost.

Because of that, sometimes the authors are using licences that are not really meet their vision (or criteria) of how they would like to share their code. Because of that, if you find a source code that you really want to use, but the licence seems to be a restriction, then it's just fine to contact the source code owner and ask about the licence and explain how you would like to use the code and get permission.

This is actually the reason that I'm using MIT almost exclusively, so it's clear to people that can grab the code and do whatever they like with it. Therefore, always check the licence and don't be afraid to ask the author if you want to use the source code in a way that it may not meet the current licence.

## Reasons to use code from the internet

So, let's start with this. Why use random source code from the internet? Well, there are many reasons, but I'll try to list a few of them

  - You don't know how to do it yourself
  - You're too bored to write it yourself
  - It takes too much time and effort to write everything by yourself
  - You don't have the time to read all the involved APIs and functions, so you use a shortcut
  - You think that someone else did it better than you can (= you're not confident about yourself)
  - You want to do a proof of concept and then re-write parts all of the code to adapt it to your needs
  - The code you found seems more elegant than your coding
  - This will save you time from your work so you can slack
  - You get too much pressure from your manager or the project and you want to just finish ASAP

All the above seem to be valid reasons and trust me all of them are full of... traps. So, no matter the reason, there is always a trap in there and you need to able to deal with it. If you don't know how to do it, then just using random code will may lead you in a much worse position later and further down in the path, because you won't be able to debug the code or solve problems. Therefore, if you don't know how to do it, it's only OK to use a code if you spend time to understand the code and feel comfortable with it.

If you're too bored to write it yourself, then you really have to be very confident about your skills and be sure that you can deal with issues later. Well, being bored in this job is also not something that will give you any joy in your work-life, so just be careful about it. I understand that not everyone enjoys their jobs and it's also normal, but this creates also problems to the other people that may have to deal with it.

If it takes too much time to write the code and you need a shortcut, then be sure that you fully understand the code. If you don't then it's a trap. The same goes for unknown APIs. It's OK to use functions that you don't really understand in depth, but again you need to be sure about your skills or at least have a brief overview of the API and if there is a documentation then try to find important information or warnings.

If you think that someone else did it better than you, then that's fine. You can't be an expert in everything, but still you need to be able to understand the code and read it and try to figure out how it's working. Most of the times, if you see a very complicated code, then probably there's something wrong with the code and it doesn't necessarily mean that this code is advanced or better than your code. Most of the times, code should be simple and clean. The same goes if you find a source code that seems more elegant that yours. Syntactic sugar and beautified code, doesn't really mean `better` code.

If you want to use source code from the internet so you can slack, then you need to consider to find another job. Really. It's not good for your mental health. Also, you might just need a break, engineering is a tough job no matter what other people think.

If you're getting too much pressure and the only way to deal with the project pressure is to use code from the internet, then that's also wrong for various reasons. In the end, you'll probably have to do it anyways, even if you don't like it, but still that's a problem and it goes beyond yourself as it's also bad for the project. Again, try to understand the code as much as possible.

## Reasons not to use code from the internet

I guess for people that already have enough experience in the domain it's clear that most projects are full of crap code. By definition all code is crap, because it's nearly impossible to get it perfectly right from the specifications and design to implementation. If you're lucky and really good then the code it won't suck that much, but still it won't be that good or perfect.

Nevertheless, it's really common to see bad code in projects and the reason is not only that many engineers use code from the internet, but when they do they use it without understand it and without making proper modifications. Another reason is that many times the proof-of-concept code ends up to be a production code, which is a huge mistake. The reason for that is that most of the times there's pressure from the upper management that if it works don't fix it, but they don't understand that this is just a PoC. You can't do much about this and if there's pressure then you need to just go along with it, knowing that the shitstorm may come to you in the future.

Most of the times, the reason that engineers quit is that they realize that the code base is unmanageable and they abandon the ship before it wrecks. Even that needs experience to do it at the right timing...

Now do you see what are the impacts of having really crappy and unmanageable code? It's a disaster for everyone. For the current project developers, for the newcomers, for the product itself and for the company. It's a disaster for everyone. Nobody likes to deal with that mess and nobody likes to be responsible for it.

But does that really has to do with just using code from the internet? Well, only partially. The main reason for such a disaster is the lack of experience, planning and good management. And it happens again and again all around the world, even in huge companies and projects.

Therefore, most of the times it seems that the problem is that developers are using code from the internet and that ends up to an unmanageable code blob. Yes, it's true. But, it's not entirely true. The problem is not the small or large pieces of code from the internet, the problem is that people don't understand the code or they don't care about it or they get too much pressure. So, the code that is coming from the internet is not the real cause of the problem. The problem is the people and the circumstances under the code was used.

## Conclusions

Personally, I like reading code and I'm using other's code often and I believe there's nothing wrong with that. That doesn't make me feel less professional and it doesn't hurt my work or my projects at all. But at the same time, I strongly believe that you should never use any code from the internet if you don't really understand it, because this will probably end up badly at some point later.

Also, nowadays there are so many APIs and frameworks and it's impossible to be expert on everything. For that reason nobody should expect from you to be expert in everything. If they do, then try to avoid those jobs. The only thing that you really must be an expert is to understand in depth what you're doing, the reasons of doing something and also be able to foresee the future and the consequences of what you're doing. This comes with experience, though.

If you still lack the experience then before you use a random code from the internet, try hard to understand it. Spend time on it. Try it, test it, use it, change it, play with it and do your own experiments. This will give you the experience you need. By getting more and more experienced you'll eventually find that pretty much everything is the same; it's just another code or another API and you'll feel comfortable with that code and be able to understand it in no time. But if you don't do this, then you'll never be able to understand the code even if you use it many times on different projects and this is really bad and eventually it will bring you in trouble.

Also be aware that the internet is full of crap code. Finding something that just works doesn't mean is good for using it. I've so much bad code that just works for the presented case, but it should never be used in a production code. Sometimes, also code may be working for the author but that doesn't mean that it will work for you as even differences in the toolchains, the build and the runtime environment can have great impact in the code functionality. You always need to be really cautious about the code you find and be sure that you use it properly.

Therefore, I believe it's totally fine to use code from the internet as long it's legal, you -really- understand it and also you adapt it to your own needs and not just copy-paste and push it in to the production.

If you think that's wrong then I'm interested to hear your opinion on the matter.

Have fun!

