---
title: Adding armbian supported boards to meta-sunxi Yocto (updated)
date: 2018-07-29T20:17:19+00:00
author: dimtass
layout: post
categories: ["Yocto"]
tags: ["meta-allwinner", "Yocto", "Embedded Linux"]
img_src: "/images"
img_width: 580
img_extras: ".shadow"
---
## Intro

Yocto is the necessary evil. Well, this post is quite different from the others, because it's more related with stuff I do for living, rather fun. Still, sometimes they can be fun, too; especially if you do something other than support new BSPs. Therefore, this post is not much about Yocto. If you don't know what Yocto is, then you need to find another resource as this is not a tutorial. On the other hand if you're here because the title made you smile then go on.

Probably you're already know about the allwinner meta layer, [meta-sunxi](https://github.com/linux-sunxi/meta-sunxi). Although sunxi is great and they've done a great job the supported boards are quite limited. On the other hand, [armbian](https://www.armbian.com/download/) supports so many boards! But if you're a Yocto-man then you know that this doesn't help much. Therefore, I thought why not `port `the `u-boot` and `kernel` patches to the `meta-sunxi` layer and build images that support the same `allwinner` boards as `armbian`?

And the result was this repo that does exactly that. Though it's still a work in progress.

[https://bitbucket.org/dimtass/meta-allwinner-hx/](https://bitbucket.org/dimtass/meta-allwinner-hx/)

This repo is actually a mix of the `meta-sunxi` and `armbian` and only supports H2, H3 and H5 boards from nanopi and orange-pi. The `README.md` is quite detailed, so you don't really need to read the rest post to bring it up and build your images.

## More details please?

Yes, sure. Let's see some more details. Well, most of the hard work is already done on armbian and meta-sunxi. In the armbian build, they have implemented a script to automatically patch the u-boot and the kernel and also all the patches are compatible with their patch system. Generally, the trick with armbian is that actually deletes most of the files that it touches and apply new ones, instead of patching each file separately. Therefore, the patches sizes are larger but on the other hand is much easier to maintain. It's a neat trick.

The script that is used in armbian to apply the patches is in `lib/compilation.sh`. There you'll find two functions, `advanced_patch()` and `process_patch_files()` and these are the ones that we would like to port to the `meta-sunxi` layer. Other than that, armbian uses the files in `config/boards/*.conf` to apply the proper patches (e.g. default, next, dev). Those are refer to the`patch/kernel`. There, for example, you'll find that sunxi has the `sunxi-dev`, `sunx-next` and `sunxi-next-old` folders and inside each folder there are some patches. If you build u-boot and and kernel for a sunxi-supported board, then you'll find in the `output/debug/output.log` and `output/debug/patching.log` which patches are used for each board.

Therefore, I've just took the u-boot and kernel patches from armbian and implemented the patching system in the meta layer. To keep things simple I've added the patch functions in both u-boot and kernel, instead of implement a bbclass that could handle both. Yeah, I know, Yocto has a lot of nice automations, but some time it doesn't worth the trouble... So in my branch you'll find the `do_patch.sh` script in both `recipes-bsp/u-boot/do_patches.sh` and `recipes-kernel/linux/linux-stable/do_patch.sh`. Both script share the same code, which is the code that is used also from armbian. The patches for u-boot and the kernel are in a folder called `patches` in the same path with the scripts.

Last but not least, I've also to add the option to create `.wic.bz2` and `.bmap`images. Please use them. If you want lightning-fast speed when you flash images to SD card or eMMC.

## Conclusion

If you want to use Yocto to build custom destributions/images for allwinner H2, H3 and H5, then you can use this meta layer. This is just a mix of the `meta-sunxi` layer and the patch system from armbian, which offers a much more wider board support. For now I've ported most of the nano-pi boards that use H2, H3 and H5 cpus and soon I'll do the same for the orange-pi board (update: done). For the rest boards (A10 etc) you can still use the same layer.

Also support for wic images and bmap-tools is a good to have, so use it wherever you can.

Have fun!