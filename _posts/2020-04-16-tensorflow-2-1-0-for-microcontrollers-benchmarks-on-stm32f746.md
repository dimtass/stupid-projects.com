---
title: Tensorflow 2.1.0 for microcontrollers benchmarks on STM32F746
date: 2020-04-16T19:36:03+00:00
author: dimtass
layout: post
categories: ["Microcontrollers", "STM32"]
tags: ["STM32", "STM32F746", "TensorFlow", "Machine Learning", "Benchmarks"]
img_src: "/images"
img_width: 580
img_extras: ".shadow"
---
## Intro

Over 8 months ago I've started writing the Machine Learning for Embedded post series, which starts [here]({% post_url 2019-06-27-machine-learning-on-embedded-part-1 %}). The 3rd post in this series [(here)]({% post_url 2019-06-27-machine-learning-on-embedded-part-3 %}) was about using the tensorflow lite for microcontrollers on the STM32746NGH6U (STM32F746-disco board). At that post I've did some benchmarks and in the next [post]({% post_url 2019-07-26-machine-learning-on-embedded-part-4 %}), I've compared the performance with the `X-CUBE-AI` framework from ST.

At that time the latest TF version was 1.14.0 and the tflite-micro was still in experimental state. The performance was quite bad compared to _X-CUBE-AI_. `CMSIS-DSP` and `CMSIS-NN` was not supported and also optimized or compressed models weren't supported, too. When I tried to use an optimized model then I was getting an error that INT8 is not supported in the framework.

So, after almost a year TF is now in version 2.1.0, 2.2.0 is around the corner and also the tflite-micro is no longer experimental. Also, _CMSIS-DSP/NN_ is now supported for many kernels as also optimized models. Therefore, I felt like it make sense to give another try.

For those tests I'm using the default Keras MNIST dataset and a quite large model with many weights. So, let's see what has changed.

## Source code

I've updated the repo I've used in post 3 and added two new tags. The previous version has the v1.14.0 tag and the new version has the v2.1.0 tag. The repo is located here:

[https://bitbucket.org/dimtass/stm32f746-tflite-micro-mnist](https://bitbucket.org/dimtass/stm32f746-tflite-micro-mnist)
[https://github.com/dimtass/stm32f746-tflite-micro-mnist](https://github.com/dimtass/stm32f746-tflite-micro-mnist)
[https://gitlab.com/dimtass/stm32f746-tflite-micro-mnist](https://gitlab.com/dimtass/stm32f746-tflite-micro-mnist)

Besides the TF version upgrade I've also made some minor changes in the code. The most important is that I'm now using a much more precise timer to benchmark each layer of the model. For that I'm using the Data Watchpoint and Trace unit (DWT) that is available on all Cortex-M MCUs. This provides a very accurate counter and the code for this in the repo is located in `source/src/inc/dwt_tools.h`. In order to use it properly I had to do some small modifications in the tflite-micro and specifically to the file `source/libs/tensorflow/tensorflow/lite/micro/micro_interpreter.cc`.

In this unit the Invoke() function of the interpreter is called that runs the inference and to do that it executes each layer of the model. Therefore, I'm using DWT to time the execution of each independent layer and then I'm adding the time to a separate variable. This is the code:

```cpp
TfLiteStatus MicroInterpreter::Invoke() {
  if (initialization_status_ != kTfLiteOk) {
    TF_LITE_REPORT_ERROR(error_reporter_,
                         "Invoke() called after initialization failed\n");
    return kTfLiteError;
  }

  // Ensure tensors are allocated before the interpreter is invoked to avoid
  // difficult to debug segfaults.
  if (!tensors_allocated_) {
    TF_LITE_ENSURE_OK(&context_, AllocateTensors());
  }

  for (size_t i = 0; i < operators_->size(); ++i) {
    auto* node = &(node_and_registrations_[i].node);
    auto* registration = node_and_registrations_[i].registration;

    /* reset dwt */
    dwt_init();
    dwt_reset();
    if (registration->invoke) {
      TfLiteStatus invoke_status = registration->invoke(&context_, node);
      if (invoke_status == kTfLiteError) {
        TF_LITE_REPORT_ERROR(
            error_reporter_,
            "Node %s (number %d) failed to invoke with status %d",
            OpNameFromRegistration(registration), i, invoke_status);
        return kTfLiteError;
      } else if (invoke_status != kTfLiteOk) {
        return invoke_status;
      }
    }
    float time_ms = dwt_cycles_to_float_ms( dwt_get_cycles() );
    glb_inference_time_ms += time_ms;
    printf("%s: %f msec\n", OpNameFromRegistration(registration), time_ms);
  }
  return kTfLiteOk;
}
```

As you can see the `dwt_init()` initializes DWT and then `dwt_reset()` is reseting the counter. This is done inside the for loop that runs each layer. After the layer is executed `dwt_get_cycles()` returns the clock cycles that the MCU spent and then those are converted in msec and it's printed to the UART. Finally, all msecs are added in the `glb_inference_time_ms` variable which is printed in the `main.c` after the inference execution is done.

Pretty much, everything else is the same, except that I've also updated the CMSIS-DSP version from 1.6.0 to 1.7.0, but I wasn't expecting any serious performance gain from this change.

**Update:** _I've updated the 1.14.0 version and now it's using the exact same versions for all the external libraries. Also v1.14.0 has now it's own branch if you want to test it._

Because of these changes I had to add two additional cmake options which are the following:

  - `USE_CMSIS_NN`: this enables/disables the usage of the cmsis-nn enabled cores which are located in `source/libs/tensorflow/tensorflow/lite/micro/kernels/cmsis-nn`. By default this option is `OFF`, therefore you need to explicitly enable it in the build script call as I'll show later.
  - `USE_COMP_MODEL`: this selects which model is going to be used. Currently there are two models with compressed and un-compressed weights. The default option is set to `OFF` so the uncompressed model is used, which is 2.1MB thus making it only able to be used from MCUs that have so much FLASH area.

Both models are just byte arrays which are the serialized flatbuffer of the model structure including the model configuration (settings and layers) and the weights. This blob is then expanded in real time from tflite-micro API to call the inference. The uncompressed model is located in the `source/src/inc/model_data_uncompressed.h` header and the compressed in `source/src/inc/model_data_compressed.h`.

Finally, there's a hard-coded digit in the flash which is the number 2. The digit is in file `source/src/inc/digit.h`. Of course, it doesn't really matter if we use an actual digit or random tensor in the input in order to benchmark the inference, but since the digit is there, I'll use that.

## Connections

This firmware supports two UART ports, one for debugging and the other to be used with the Jupyter notebook in `jupyter_notebook/MNIST-TensorFlow.ipynb`. UART6 is used for printing debug messages and also send commands via the terminal. UART7 is used for communicating with the jupyter notebook and send/receive flatbuffers. For this post I won't use UART7, so I'll just trigger the inference of the pre-defined digit, which is already in the FLASH, by sending a command via UART6. The STM32F7-discovery board has an Arduino-like header arrangement, therefore the pinout is the folowing:


Function |	Arduino connector |	Actual pin
-|-|-
UART6 TX |	D0 |	PC7
UART6 RX |	D1 |	PC6

The baudrate for this port is 115200 bps and there are only supported commands, which are the following:

Command	| Description
-|-
CMD=1 |	Prints the model input and output (tensor size)
CMD=2 |	Executes the inference for the default digit.

When the program starts it prints a line similar to this in the UART:

```sh
Program started @ 216000000...
```

As you can see the frequency is displayed when the firmware boots, so it's easier to verify the clock.

## Build the code

To build the code you just need a toolchain and cmake, but to make it easier I've added a script in the repo that uses the CDE image I've created in the [DevOps for Embedded]({% post_url 2019-11-26-devops-for-embedded-part-1 %}) post series. I'm using the same CDE docker image to build all my repos in circleci and gitlab, so you can expect that you'll get the same results with me.

To use the docker-build script you just need to run it like this:

```sh
./docker-build.sh "CLEANBUILD=true USE_OVERCLOCK=OFF USE_CMSIS_NN=OFF USE_COMP_MODEL=OFF ./build.sh"
```

This command will build the uncompressed model, without cmsis-nn support and overclock and the next command will build the firmware with overclocking the MCU to 288MHz and the cmsis-nn kernels:

```sh
./docker-build.sh "CLEANBUILD=true USE_OVERCLOCK=ON USE_CMSIS_NN=ON USE_COMP_MODEL=OFF ./build.sh"
```

`CLEANBUILD` and `USE_COMP_MODEL` are not really necessary for the above commands, but I've added them for completeness. If you like you can have a look in the circleci builds [here](https://circleci.com/gh/dimtass/stm32f303-ccmram-test).

## Benchmarks

Finally, the best part. I've run 4 different test which are the following:

Case	| Description
-|-
1	| Default kernels @ 216MHz
2	| CMSIS-NN kernels @ 216MHz
3	| Default kernels @ 288MHz
4	| CMSIS-NN kernels @ 288MHz

The results I got are the following (all times are in msec):

Layer	| [1]	| [2]	| [3]	| [4]
-|-|-|-|-
DEPTHWISE_CONV_2D	| 25.19	| 24.9	| 18.89	| 18.68
MAX_POOL_2D	| 3.25 |	3.27 |	2.44 |	2.45
CONV_2D |	166.25 |	166.29 |	124.58 |	124.54
MAX_POOL_2D	| 0.956 |	0.96 |	0.71 |	0.72
CONV_2D	| 23.327 |	23.32 |	17.489 |	17.49
FULLY_CONNECTED	| 1.48 |	1.48 |	1.11 |	1.11
FULLY_CONNECTED	| 0.03 |	0.03 |	0.02 |	0.02
SOFTMAX	| 0.02	| 0.02	| 0.017	| 0.01
Total time:	| 220.503	| 220.27	| 165.256 |	165.02

**Note:** In the next tables I don't specify if the benchmark is run on the compressed or the uncompressed model, because the performance is identical.

So, now let's do a comparison between the 1.14.0 version I've used a few months ago and the new 2.1.0 version. This is the table with the results:

<center><b>Default kernels @ 216MHz [1]</b></center>

Layer	| 1.14.0 |	2.1.0	| diff (msec)
-|-|-|-
DEPTHWISE_CONV_2D	|	18.77		|25.19	|	6.42
MAX_POOL_2D	|	1.99	|	3.25	|	1.26
CONV_2D	|	90.94	|	166.25	|	75.31
MAX_POOL_2D	|	0.56	|	0.956	|	0.396
CONV_2D	|	12.49	|	23.327	|	10.837
FULLY_CONNECTED	|	1.48	|	1.48	|	0
FULLY_CONNECTED	|	0.03	|	0.03	|	0
SOFTMAX	|	0.01	|	0.02	|	0.01
TOTAL TIME=	|	126.27	|	220.503	|	94.233

<center><b>CMSIS-NN kernels @ 216MHz [2]</b></center>

Layer	| 1.14.0 |	2.1.0	| diff (msec)
-|-|-|-
DEPTHWISE_CONV_2D	|	18.7	|	24.9	|	6.2
MAX_POOL_2D	|	1.99	|	3.27	|	1.28
CONV_2D	|	91.08	|	166.29	|	75.21
MAX_POOL_2D	|	0.56	|	0.96	|	0.4
CONV_2D	|	12.51	|	23.32	|	10.81
FULLY_CONNECTED	|	1.48	|	1.48	|	0
FULLY_CONNECTED	|	0.03	|	0.03	|	0
SOFTMAX	| 0.01	|	0.02	|	0.01
TOTAL TIME=	|	126.36	|	220.27	|	93.91

<center><b>Default kernels @ 288MHz [3]</b></center>

Layer	| 1.14.0 |	2.1.0	| diff (msec)
-|-|-|-
DEPTHWISE_CONV_2D	|	18.77	|	25.19	|	6.42
MAX_POOL_2D	|	1.99	|	3.25	|	1.26
CONV_2D	|	90.94	|	166.25	|	75.31
MAX_POOL_2D	|	0.56	|	0.956	|	0.396
CONV_2D	|	12.49	|	23.327	|	10.837
FULLY_CONNECTED	|	1.48	|	1.48	|	0
FULLY_CONNECTED	|	0.03	|	0.03	|	0
SOFTMAX	|	0.01	|	0.02	|	0.01
TOTAL TIME=	|	126.27	|	220.503	|	94.233

<center><b>CMSIS-NN kernels @ 288MHz [4]</b></center>

Layer	| 1.14.0 |	2.1.0	| diff (msec)
-|-|-|-
DEPTHWISE_CONV_2D	|	52	|	55.05	|	-3.05
MAX_POOL_2D	|	5	|	5.2	|	-0.2
CONV_2D	|	550	|	576.54	|	-26.54
MAX_POOL_2D	|	2	|	1.53	|	0.47
CONV_2D	|	81	|	84.78	|	-3.78
FULLY_CONNECTED	|	2	| 2.27	|	-0.27
FULLY_CONNECTED	|	0	|	0.04	|	-0.04
SOFTMAX	|	0	|	0.02	|	-0.02
TOTAL TIME=	|	692	|	725.43	|	-33.43

## Results

As you can image I'm really struggling with those results, as it seems that the performance in 2.1.0 version is slightly worse, even in case that now more layers support cmsis-nn.

In version 1.14.0, only the depthwise_conv_2d was implemented with cmsis-nn as you can see [here](https://bitbucket.org/dimtass/stm32f746-tflite-micro-mnist/src/v1.14.0/source/libs/tensorflow/lite/experimental/micro/kernels/cmsis-nn/). But in the new 2.1.0 stable version more kernels are implemented as you can see [here](https://bitbucket.org/dimtass/stm32f746-tflite-micro-mnist/src/master/source/libs/tensorflow/tensorflow/lite/micro/kernels/cmsis-nn/). Therefore, now conv_2d and fully connected are supported. Nevertheless, the performance seems to be worse...

Initially I thought that I was doing something terribly wrong, therefore, I've deliberately was introducing compiler errors in those files and specifically in the parts that the cmsis-nn functions are used and the compiler actually was complaining, therefore I was sure that at least the compilation was right.

I don't really have strong opinion why this is happening yet and I'm going to report this just to verify that I'm not doing something wrong. My assumption is that I might have to enable an extra flag for the compiler or the code and because I don't know which one that might be then the inference uses the default non-optimized kernels.

I've also checked that the sensor type in the compressed model is the correct one. I did that by printing the `tensor_type` in the `ConvertTensorType()` function in `source/libs/tensorflow/tensorflow/lite/core/api/flatbuffer_conversions.cc`. When the compressed model is loaded I get `kTfLiteFloat16` and `TensorType_INT8` as a result, which means that the weights are indeed compressed. Therefore, I can't really say why the performance is such slow...

I've also tried with different option for the `mfp16-format` in the compiler. I've tried with these two in the `source/CMakeLists.txt`.

```sh
-mfp16-format=ieee
-mfp16-format=alternative
```

But none of those make any difference whatsoever.

Another issue I'm seeing is that the compressed model doesn't return valid results. For example, when I'm using the uncompressed model I'm getting this result:

```sh
Out[0]: 0.000000
Out[1]: 0.000000
Out[2]: 1.000000
Out[3]: 0.000000
Out[4]: 0.000000
Out[5]: 0.000000
Out[6]: 0.000000
Out[7]: 0.000000
Out[8]: 0.000000
Out[9]: 0.000000
```

This means that the inference returns a certainty of 100% for the correct digit. But when I'm using the compressed model with the same input I'm getting this output:

```sh
Out[0]: 0.093871
Out[1]: 0.100892
Out[2]: 0.099631
Out[3]: 0.106597
Out[4]: 0.099124
Out[5]: 0.096398
Out[6]: 0.099573
Out[7]: 0.101923
Out[8]: 0.103691
Out[9]: 0.098299
```

Which means that the inference cannot be trusted as there's no definite result.

## Conclusions

There's something going on here... It's either me missing some implementation details and I need to add an extra build flag or actually there's no any performance gain in the last tflite-micro version.

I really hope that I'm doing something wrong, because as I've mentioned in previous posts, I really like the tflite-micro API as it can be universal for all ARM MCUs that have a DSP unit. This means that you can write a portable code that can be re-used in different MCUs from different vendors. For now it seems that X-CUBE-AI from ST performs far better compared to tflite-micro and it's one way solution.

Let's see, I've posted it in the [previous issue](https://github.com/tensorflow/tensorflow/issues/30953) I got from the other post and I'll try to figure this out and if there's any update I'll post it here.

Have fun!