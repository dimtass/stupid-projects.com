---
title: Machine Learning on Embedded (Part 2)
date: 2019-06-27T12:40:00+00:00
author: dimtass
layout: post
categories: ["Post series"]
tags: ["Machine Learning", "Embedded", "TensorFlow", "Arduino", "STM32", "Teensy", "ESP8266"]
img_src: "/images"
img_width: 580
img_extras: ".shadow"
---
## Intro

**Note:** This post is the part 2 in the series. Here you can find
[part 1]({% post_url 2019-06-27-machine-learning-on-embedded-part-1 %}),
[part 3]({% post_url 2019-06-27-machine-learning-on-embedded-part-3 %}),
[part 4]({% post_url 2019-07-26-machine-learning-on-embedded-part-4 %}) and
[part 5]({% post_url 2019-07-29-machine-learning-on-embedded-part-5 %}).

In the first part ([part 1]({% post_url 2019-06-27-machine-learning-on-embedded-part-1 %})) we've designed, trained and evaluated a very simple NN with 3-inputs and 1-output. It will make more sense if you have a look at the first post before continuing with this.

So, in this post we will design a bit more complex (but again simple) NN and we'll do the same procedure like the first part. Design, train and evaluate. For consistency and make it easier to compare, we'll use the same inputs and training set.

## Components

The MCUs that we're going to use are the same one with the [previous post]({% post_url 2019-06-27-machine-learning-on-embedded-part-1 %}).

## Another simple NN

Everything that is related to this project for all the article parts are in this bitbucket repo:

[https://bitbucket.org/dimtass/machine-learning-for-embedded/src/master/](https://bitbucket.org/dimtass/machine-learning-for-embedded/src/master/)

In the previous post we had a very simple NN with 3-inputs and 1-output. In this post we'll have a NN with 3-inputs, a hidden layer with 32 nodes and 1-output. You can see that in the following picture:


![]({{page.img_src}}/nn_simple_2.png){: width="{{page.img_width}}" {{page.img_extras}}}

You see that not all 32 nodes are displayed in the picture, but only h(0), h(1), h(2) and h(31). Also I haven't added all the weights because there wasn't enough space, but its easy to guess that they are similar with the ones from a(0).

To write the mathematical equation for this NN is a bit more complex (only because it takes a lot of lines), but the logic behind it it's the same. It's just the dot product of the inputs and the weights between the inputs and the hidden layer and then the dot product of the hidden layer and the weights between the layer and the output. Anyway, math doesn't really matter for now.

As the inputs are the same, the same table with all possible 8 input sets stands as before.

## Training the model

To train this model is a bit more complicated than before. You can open the `Simple python NN (1 hidden).ipynb` notepad from the cloned repo in your Jupyter browser or you can just view it [here](https://bitbucket.org/dimtass/machine-learning-for-embedded/src/master/jupyter_notebook/Simple%20python%20NN%20(1%20hidden).ipynb?viewer=nbviewer). The python code seems almost the same but in this case I've made some changes to support the hidden layer and the additional weights between each layer.

In step 2. in the notebook you can see that now the weights are a `[3][32]` array. That means 32 weights for each of the 3 inputs. That's 96 weights only for the first two layers, plus another 32 weights for the next, which is total 128 weights! So you can imagine that this will need a lot more processing time to calculate and also that this number can grow really fast the more hidden layers or nodes/layer you add.

After we train the model we see some interesting results. I'm copying them here:

```py
[0 0 0] = [0.28424671]
[0 0 1] = [0.00297735]
[0 1 0] = [0.21864649]
[0 1 1] = [0.00229043]
[1 0 0] = [0.99992042]
[1 0 1] = [0.99799112]
[1 1 0] = [0.99988018]
[1 1 1] = [0.99720236]
```

Let's see again the results from the previous post.

```py
# Simple 1

[0 0 0] = [0.5]
[0 0 1] = [0.009664]
[0 1 0] = [0.44822538]
[0 1 1] = [0.00786466]
[1 0 0] = [0.99993704]
[1 0 1] = [0.99358931]
[1 1 0] = [0.9999225]
[1 1 1] = [0.99211997]
```

Do you see what just happened? In the previous NN with no hidden layer the prediction for `[0 0 0]` was 50% and for
`[0 1 0]` was 44%. With the new NN that has the hidden layer the prediction is much more clear now and the NN predicts 
that those values must probably be 0. Therefore, by using the same inputs and same output the new more complex NN 
makes more accurate predictions.

It's not always necessary that the more complex a NN is will make better predictions. Actually, it might be the 
opposite. If you want to dig deeper you can have a look about NN over-fitting. Most probably even in this second case 
with the 32-node hidden layer, the model is over-fitting and maybe 8 nodes are more than enough, but I prefer to test 
this 32-node hidden layer in order to stress the MCUs with more load and get some insight how these little boards will 
cope up with that load.

## Evaluate on the MCUs

Now that we designed, trained and evaluated our model on the Jupyter notepad we're going to test the NN on different 
MCUs.

What is important here is not if the evaluation really works on the MCUs. I mean that's just code and of course it 
will work the same way and you'll get similar results. You results may just differ a bit between different MCUs, 
because as we're using doubles and the accuracy may vary.

## C code

Regarding the NN prediction implementation in the C code, just have a look at the `test_neural_network2()` and 
`benchmark_neural_network2()` functions in the code. The rest is the same as I've described in the [part 1]({% post_url 2019-06-27-machine-learning-on-embedded-part-1 %}).

## Supported serial commands

Again, please refer to the [part 1]({% post_url 2019-06-27-machine-learning-on-embedded-part-1 %}).

For this post the `START=2` command was used in order to execute the benchmark with the second simple NN. In the previous post the benchmark results were obtained with the `START=1` command. Keep in mind that if you want to switch from one mode to another you need first to send the `STOP` command.

## Benchmarks

You can find all the oscilloscope screenshots for the prediction benchmarks in the screenshots folder. The captures are the ones that have the `simple2` in their filename. In the following table I've gathered all the results for the prediction execution time for each board. As the second NN takes more time you can ignore the toggle time as it's insignificant. Here are the results:

MCU	| Prediction time (μsec)
-|-
stm32f103 @ 72MHz	| 700
stm32f103 @ 128MHz	| 385
Arduino Uno @ 8MHz	| 5600
Ard. Leonardo @ 16MHz	| Oops!
Arduino DUE @ 84MHz	| 686
ESP8266-12E @ 160MHz	| 392
Teensy 3.2 @ 120MHz	| 504
Teensy 3.5 @ 168MHz	| 363
stm32f746 @ 216MHz	| 127
stm32f746 @ 295MHz	| 92.8

As you can see from the above table I've lost the results for the Arduino Leonardo. But who cares. I mean it's boringly slow anyway. I may try to re-run the test and update.

Now let's think about a real-time application. As you can see the prediction time now has increased significantly. It's interesting to see how much that time has increased. Let's see the ratio between the NN in the first post and this.

MCU |	Prediction time ratio
stm32f103 @ 72MHz	| 41.42
stm32f103 @ 128MHz	| 41.04
Arduino Uno @ 8MHz	| 48.95
Ard. Leonardo @ 16MHz	| –
Arduino DUE @ 84MHz	| 36.29
ESP8266-12E @ 160MHz	| 25.06
Teensy 3.2 @ 120MHz	| 42.857
Teensy 3.5 @ 168MHz	| 41.06
stm32f746 @ 216MHz	| 26.13
stm32f746 @ 295MHz	| 25.92

Let's explain what this ratio is. This number show how much slower the second NN execution is compared to the first NN 
for the specific CPU. So for the stm32f103 the second NN needs 41 times the time that the first NN needed to predict 
the output. Therefore, the bigger the number the worst effect the second NN had on the MCU. On those terms, the 
stm3f103 seems to scale much more worse than the stm32f746 and the esp8266. The stm32f746 and esp8266 really shine and 
scale much better that any other MCU. The reason I guess, is the hardware FPU that those two have, which can explain 
the ratio difference as the NN is actually just calculating dot products on doubles.

Therefore, here we have a good hint. If you want to run a NN on a MCU, first find one with a hard FPU, like Cortex-M4/7 or esp8266. From those two, the stm32f746 of course is a much better option (but that depends also the use case, so 
if you need wifi connection then esp8266 is also a good option). So, coming back to real-time applications we need to 
think that the second NN is also a simple one as we only have 3 inputs. If we had more inputs then we would need more 
time to get a prediction. Also the closer we get to the millisecond area that already excludes most of the MCUs from 
any real-time application that needs to make fast decisions. Of course, once again it always depends on the project! 
If for example you had a NN that the inputs were the axis of a 3D-accelerometer and you had a trained model that 
needed to predict a value according to the inputs, then maybe 700 μsec or even 500 μsec are ok. But they may not! So 
it really depends on the problem you need to solve.

## Conclusions

After finishing those tests I had mixed feelings. That's because I've managed to design, train and evaluate two simple NN models and be able to test them successfully on all the MCUs. That was awesome. Of course, the performance is different and depends on the MCU. So, although I see some potentials here, at the same time it seems that the performance drops quite much as the model complexity increases. But as I've said it depends in the real use case you may have. You might be able to use an MCU to run the predict function, you might not. It all depends on the real-time requirements and the model complexity.

Let's keep the fact that the tools are out there. There are many different MCUs, with different processing power and accelerators that might fit your use case. New Cortex-M cpus are now coming with NN accelerators. I believe it's a good time now to start diving into the ML and the ways that it can be used with the various MCUs in the low embedded domain. Also there are many other HW platforms available in the market, like FPGAs with integrated application CPUs that can be used for ML. The market is growing a lot and now it's a good time to get involved.

**Update**: next part is [part 3]({% post_url 2019-06-27-machine-learning-on-embedded-part-3 %}).

Until then have fun!