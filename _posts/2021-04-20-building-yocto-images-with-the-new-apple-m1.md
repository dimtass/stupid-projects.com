---
title: Building Yocto images with the new Apple M1
date: 2021-04-20T15:55:29+00:00
author: dimtass
layout: post
categories: ["Yocto"]
tags: ["Benchmarks", "Embedded Linux", "Yocto", "Apple M1"]
img_src: "/images"
img_width: 580
img_extras: ".shadow"
---
## Intro

Hello fellow Yocto engineers 🙂

I guess, you already know that this new Apple M1 SoC has shaken the IT world. Well, this is not another post for praising Apple for its new SoC. There was already a lot of praising in the media and especially from consumers that after having ARM processors to their mobiles, tablets, routers and TV boxes, now they will get them also to their laptops and their desktops.

The M1 is great and blah, blah, blah... but can it run Crisis? Eh.. I mean, Yocto?

Let's find out...

## The challengers

I've done my tests in two systems. On the blue corner is my main Linux workstation that I'm using for almost everything and its specs are:

  * Ryzen 7 2700X with 8C/16T @ 4GHz (overclocked)
  * 32GB DDR4 - 3200MHz
  * 1TB EVO 960 nvme
  * NVidia RTX2060 Super
  * Ubuntu 20.04.2 LTS

On the red corner is a 13 " Apple MacBook Air (**MBA**) with the following specs:

  * M1, 2020 SoC with 8 cores @ 3.2GHz
  * 16GB RAM
  * 1TB SSD
  * macOS Big Sur 11.2.3

## How to Yocto with the M1?

Well, for the Linux box there's no much things to say. I'm just using either a docker image or Ubuntu itself to build images. I haven't seen any difference in using those two different options, so the speed is almost exactly the same which is expected as docker in Linux is running native without any hypervisor in between.

But, how can the MBA build a Yocto image? That's easy. Using virtualization, of course. And specifically using [Parallels](https://www.parallels.com/products/desktop/). Probably some of you already nod with disappointment, but wait for the results.

In case of parallels, there are a few images that you can use for free and Ubuntu 20.04 is one of them. Therefore, in just a few minutes I had a VM running and ready to build Yocto images. After doing all the needed updated I've compared the two Ubuntu versions and these are the results.

|         | Ryzen Ubuntu	| Parallels Ubuntu  |
|---------|---------------|-------------------|
| Version	| 20.04.2 LTS	  | 20.04.2 LTS       |
| Kernel	| 5.9.10-050910	| 5.4.0-66-generic  |

As you can see both Ubuntu versions are the same, but I'm using a newer kernel on my workstation. I've tried to build the same kernel for Parallels but although I succeeded, when I've tried to boot from that kernel it failed. I guess it needs some customization in order to boot with Parallels. Didn't spend more time on it.

## Benchmark setup

My benchmark will be my [allwinner yocto BSP repo](https://gitlab.com/dimtass/meta-allwinner-hx), because I know the ins and outs of this build and I've built it dozens of times. For the desktop I'll build the repo using 8 and 16 threads and in case of MBA I'll use 8 threads which is the maximum number of cores.

This is the parallels configuration in the MBA:

![]({{page.img_src}}/mba-parallels-configuration.png){: width="{{page.img_width}}" {{page.img_extras}}}

As you can see I've used all 8 cores and only 8GB of RAM. The reason I didn't use the whole RAM is to get so get a bit similar results with the much cheaper basic version of MBA with 8GB RAM and 256GB SSD.

At this point I need to mention that I'm using the free 14-days trial version of Parallels, which means that I can use all the 8 cores, but after the trial expires only the 4 cores can be used in the standard version and only the pro version can utilize all cores. I'll explain those things later in more detail, though.

The commands I've used for all tests are the following:

```sh
mkdir allwinner
cd allwinner
mkdir sources
cd sources
git clone https://gitlab.com/dimtass/meta-allwinner-hx.git
git clone --depth 1 -b dunfell https://git.yoctoproject.org/git/poky
git clone --depth 1 -b dunfell https://github.com/openembedded/meta-openembedded.git
cd ..
DISTRO=allwinner-distro-console MACHINE=nanopi-k1-plus source ./setup-environment.sh build
time bitbake allwinner-console-image
```

Actually, I've build the image twice and I've only benchmarked the second build. The reason I did that is because I wanted the first run to download all the needed packages. Then I've deleted the build folder which also includes the sstate-cache and then re-build the image having the packages already in the download folder.

In case of MBA I've ran three builds, one while it was connected to the mains power and working at the same time while having 2 chrome instances with 24 tabs opened in total, MS Teams, an email client, VS Code, iterm2 with 3 ssh sessions and slack. All at the same time. The second time while it was connected to mains power and without any additional workload and the third time while it was running on battery without any additional workload.

Finally, in case of the Ryzen workstation to change the number of threads I've edited the build/conf/local.conf file before the build. I've also made sure that all 8 cores are used in MBA as you can see here:

![]({{page.img_src}}/mba-parallels-cpu-utilization_2.png){: width="{{page.img_width}}" {{page.img_extras}}}

## Results

First I'll add the screenshots of the results and then I'll list them in a table. These are the screenshots (click on them to enlarge):

![]({{page.img_src}}/yocto-ryzen-16c.png){: width="{{page.img_width}}" {{page.img_extras}}}
![]({{page.img_src}}/yocto-ryzen-8c.png){: width="{{page.img_width}}" {{page.img_extras}}}
![]({{page.img_src}}/mba-parallels-results-battery.png){: width="{{page.img_width}}" {{page.img_extras}}}
![]({{page.img_src}}/mba-parallels-results-mains_1.png){: width="{{page.img_width}}" {{page.img_extras}}}


System	| Time
-|-
Ryzen 7 w/ 16 threads	| 55m4,071s
Ryzen 7 w/ 8 threads	| 53m9,905s
Macbook Air w/ 8 threads on mains	| TBD
Macbook Air w/ 8 threads on battery	| 62m12.737
Macbook Air w/ 8 threads (w/ extra load)	| 69m3.161s

I don't know what you expected, but of course the MBA is slower compared my workstation. Well, it's slower, but for how much, though?

I mean look at the figures! Personally, I'm amazed that the MBA managed to build the Yocto image in 62 mins while on battery, which is a bit more that one hour. And in that time the battery only dropped to 71%! Click the following image to enlarge.

![]({{page.img_src}}/mba-parallels-after-battery-build.png){: width="{{page.img_width}}" {{page.img_extras}}}

Have in mind that my allwinner build is a bit a heavy build, so even my workstation needs almost an hour. Also the difference with the 8 thread builds is 9 minutes. Yes, 9 minutes are quite a lot. But, we're talking about a fanless laptop running dead silent.

So, yes. I'm amazed. I also have a 4C/8T Ryzen 5 2500U Lenovo laptop with 16GB of RAM, which I didn't even dare to add in the comparison as I already know that it needs much much more time to build the image and also it can't do it only running on battery as the BIOS underclocks the CPU at 400MHz when it gets hot or the battery is under 50%. Stupid laptop.

## Conclusions

My conclusion is that the new M1 SoC is what everyone claims. It begins a new era, which to my mind it reminds me pretty much is what happened when the first Pentium CPU was released in the 90's. I already expected that from the other reviews, but personally I was amazed when I've did the Yocto benchmark myself. I believe it probably outperforms any laptop out there when used to build Yocto images, but that's not all.

What is also important to me is that after 62 minutes of intensive workload and all the cores running at maximum capacity the battery just dropped to 71%! I mean wow. Although during the build the laptop became a bit warm, it was completely silent as there's no fan or any moving part in the MBA.

I guess from the other generic reviews I've seen, the Macbook Pro will be a bit faster and also its battery lasts quite a lot more compared to the Macbook Air, which means that I expect that after the same build the battery will only drop to 80-85%.

One thing to mention here is that Parallels is not a free software. You need to buy a licence to use all those nice things. I don't have a license and I don't see any reason to buy one as I'm using my workstation for pretty much everything. Therefore, you need to calculate an extra cost of $99 per year for the pro license in case you need updates. Of course, for professional use this cost is just negligible, but in my case -since I don't do embedded professionally anymore- it's an extra measurable cost.

It's sad that my free version expires soon, so I can't do further tests that I had in my mind. Hopefully this post is useful for people that are interested to get the new M1 SoC and be able to use it for embedded like building Yocto images with Parallels.

If you use the M1 for Yocto, then please write your experience in the comments and any issues that you may have with the new M1. For example, one issue I've found is that if you're using a USB-to-UART module for console with SBCs, then currently only Silabs SIL2012 modules are working without any drivers, but those can't usually go up to 1Mbps which is the standard bitrate for SoCs like Rockchip. The faster FTDI modules that work at 1Mbps are not supported yet on the Big Sur OS.

Have fun!