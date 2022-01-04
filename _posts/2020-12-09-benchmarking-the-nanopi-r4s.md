---
title: Benchmarking the NanoPi R4S
date: 2020-12-09T20:33:47+00:00
author: dimtass
layout: post
categories: ["Embedded"]
tags: ["Benchmarks", "Embedded Linux", "SBC"]
img_src: "/images"
img_width: 580
img_extras: ".shadow"
---
## Intro

**Note**: _I've wrote a complementary post on how to do some networking optimizations [here]({% post_url 2020-12-17-nanopi-r4s-benchmarks-with-networking-optimizations %})._

This week I've received the new [NanoPi R4S](https://wiki.friendlyarm.com/wiki/index.php/NanoPi_R4S) from FriendlyElec for evaluation purposes.

My original plan was to create a Yocto BSP layer for the board as I've also did with the NanoPi R2S in a recent post [here]({% post_url 2020-08-22-a-yocto-bsp-layer-for-nanopi-neo3-and-nanopi-r2s %}). The way I usually create a Yocto BSP layers for those SBCs is that I use parts of the Armbian build tool and integrate them in bitbake recipes and then add them in a layer. The problem this time is that Armbian hasn't released yet support for this board, therefore I thought it's a good chance to benchmark the board itself.

Let's first see the specs of the board.

## NanoPi R4S specs

The board is based on the Rockchip RK3399 and the specs of the specific board I've received are:

  * Rockchip RK3399 SoC 
      * 2x Cortex-A72 @1.8GHz
      * 4x Cortex-A53 @1.4GHz
      * Mali-T864 GPU
      * VPU capable of 4K VP9 and 4K 10bits H265/H264 60fps decoding
  * 4GB LPDDR4 RAM
  * RK808-D PMIC
  * 2x GbE ports
  * 2x USB 3.0 ports
  * Extension pin-headers 
      * 2x USB 2.0
      * 1x SPI
      * 1x I2C
      * 1x UART (console)
      * RTC Battery
  * USB Type-C connector for power

What makes the board special is of course the dual GbE. One interface is integrated in the SoC and the other is a PCIe GbE which is connected on the SoC's PCIe bus.

As you can guess this board is meant to be used in custom router configurations and that's the reason that there's already a custom OpenWRT image for it, which is named FriendlyWRT. Therefore, in my tests I've used this image and actually I've used the image that it came in the SD card with the board. More details about the versions later.

Also the board I've received came with an aluminum case, which has a dual purpose, for housing -of course- and it's also used to cool down the CPU. This is the SBC I've received.

![]({{page.img_src}}/nanopi-r4s.jpg){: width="{{page.img_width}}" {{page.img_extras}}}

The Nanopi-R4S's case is very compact and it's only a bit bigger than its predecessor Nanopi-R2S, but also includes more horse power under the hood. You can see how those two compare in size.

![]({{page.img_src}}/nanopi-r4s-r2s-size.jpg){: width="{{page.img_width}}" {{page.img_extras}}}

As you can see in the above image I've done a modification on the case by drilling a hole above the USB power connector. I've done this hole in order to be able to use the UART console while the case is closed.

The Nanopi-R2S also has the same issue, as you can't connect the UART console while the case is closed. Therefore, I've done the same modification to both cases. This is very easy to do as aluminum is very easy and soft to drill.

Here's an image of the Nanopi-R2S with the case open.

![]({{page.img_src}}/nanopi-r2s-case-mod.jpg){: width="{{page.img_width}}" {{page.img_extras}}}

I also had to use a cutter to trim the top of the dupont connectors in order for the case to close properly.

In the Nanopi-R2S I've drilled the hole above the reset button and on the Nanopi-R4S above the USB power connector.

Another thing I need to mention here is that I had to also change the thermal pad on the Nanopi-R2S because it comes with a 0.5mm pad and I've seen that the temperature was a bit high. When I've changed the pad with a 1mm thickness then it was much better. I guess you can use any thermal pad, but in my case I've used this one that I got from ebay.

![]({{page.img_src}}/thermal-pad.jpg){: width="{{page.img_width}}" {{page.img_extras}}}

The thermal pad of the Nanopi-R4S seems to be fine so I haven't changed that.

## Test setup

The setup I've used for the benchmarks is very simple and I've only used standard equipment that anyone can buy cheap. So, no expensive or smart Ethernet switches or expensive cables. I think that way the results will reflect the most common case scenarios, which is use the board in a home or small office environment.

The switch I've used is the TP-Link TL-SG108, which is an 8-port GbE switch and it costs approx. 20 EUR here in Germany, which I believe is cheap. The cables I've used are some ultra-cheap 1m CAT6 which I use for my tests.

I've done two kind of tests. The first test is to test only the WAN interface, using my workstation which has an onboard GbE interface. This is the setup.

![]({{page.img_src}}/nanopi-rxs-setup.png){: width="{{page.img_width}}" {{page.img_extras}}}

As you can see from the above diagram the workstation is connected on the GbE switch as also the WAN interface of the Nanopi-RxS (I mean both R2S and R4S). Then the LAN interface, which by default is bridged internally in FriendlyWRT, is connected on my Laptop which is using a USB-to-GbE adaptor as it doesn't have a LAN connector.

I've tested thoroughly this USB-to-GbE adapter in many cases and it's perfectly capable of 1 Gbit. So, don't worry about it, it won't affect the results.

Someone could argue here that the switch should be placed after the LAN and not before WAN, because WAN is meant to be connected to your ADSL/VDSL router. Well, that's one option, but also this option is a valid setup for many setups. For example I prefer to have the WiFi router before the WAN and some of my devices after the LAN, so the devices connected with before WAN don't have access to the LAN devices via the bridge interface.

My workstation is a Ryzen 2700X and the Ethernet is an onboard interface on the ASRock Fatal1ty X470 Gaming K4 motherboard with the latest firmware at this date. The kernel and OS are the following:

```sj
PRETTY_NAME="Ubuntu 18.04.5 LTS"
Linux workstation 5.9.10-050910-generic #202011221708 SMP Sun Nov 22 18:07:21 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
```

The Laptop is a Lenovo 330S-15ARR with a Ryzen 2500u and the following kernel and OS.

```sh
PRETTY_NAME="Ubuntu 20.04.1 LTS"
Linux laptop 5.3.16-050316-generic #201912130343 SMP Fri Dec 13 08:45:06 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux
```

The USB-to-GbE is based on the RTL8153.
```sh
Bus 002 Device 004: ID 0bda:8153 Realtek Semiconductor Corp. RTL8153 Gigabit Ethernet Adapter
```

This is the kernel and OS of the Nanopi-R4S
```sh
PRETTY_NAME="OpenWrt 19.07.4"
Linux FriendlyWrt 5.4.75 #1 SMP PREEMPT Tue Nov 10 11:13:15 CST 2020 aarch64 GNU/Linux
```

And this is the kernel ans OS of the Nanopi-R2S

```sh
PRETTY_NAME="OpenWrt 19.07.1"
Linux FriendlyWrt 5.4.61 #1 SMP PREEMPT Fri Sep 4 15:12:58 CST 2020 aarch64 GNU/Linux
```

With this setup, I've used iperf to benchmark the WAN interface and the bridged interface. The WAN interface is getting an IP from the DHCP router which is also connected on the GbE switch and the Nanopi-RxS runs it's own DHCP server for the bridge interface which is the range of 192.168.2.0. Therefore, the laptop gets an IP address in the 192.168.2.x range but it does have access to all the IPs in the WAN. For that reason in the bridge tests the Laptop always acts as the client.

Before see the benchmark results this is the table of the IP addresses.

Host | IP
-|-
Workstation |	192.168.0.2
Nanopi-R4S (WAN) |	192.168.0.62
Nanopi-R4S (LAN) |	192.168.2.1
Nanopi-R2S (WAN) |	192.168.0.63
Laptop |	192.168.2.128

I'll do 6 different tests, which are described in the following table.

Test #	| iperf client cmd |	Description
-|-|-
1	| -t 120 | TCP, 2 mins, default window size
2	| -t 120 -w 65536 |	TCP, 2 mins, 128KB window size
3	| -t 120 -w 131072 |	TCP, 2 mins, 256KB window size
4	| -t 120 -d -P 2 |	TCP, 2 mins, default window size, 2x parallel
5	| -u -t 120 -b 1000M |	UDP, 2 mins, 1x Gbits
6	| -u -t 120 -b 1000M -d |	UDP, 2 mins, 1x Gbits, both directions

2 mins, means that the test lasts for 2 minutes (or 120 secs), which is a pretty good average time as it means approx. 13GB of data in a GbE.

I've also tried several TCP window sizes, but usually the default size is the one that you should focus.

Finally, I've also added a 2x parallel socket test for TCP and for UDP I've tested both directions (server/client).

Let's see the benchmarks now.

## Nanopi-R4S WAN benchmarks

#### Laptop -> Switch -> Workstation

The first benchmark is to test the speed between the workstation and the Laptop on the GbE switch to verify the max speed this setup can achieve. These are the results:

Host | Command
-|-
Workstation	| iperf -s
Laptop	| iperf -c 192.168.0.78 -t 120

```
------------------------------------------------------------
Client connecting to 192.168.0.2, TCP port 5001
TCP window size:  289 KByte (default)
------------------------------------------------------------
[  3] local 192.168.0.78 port 54456 connected with 192.168.0.2 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-120.0 sec  13.2 GBytes   941 Mbits/sec
```

In the tables I'll be adding the commands that I'm using on each server/client and then I'll add the result that iperf outputs.

So, in this case we can see that the setup maximizes at 941 Mbits/sec.

#### Workstation -> Switch -> Nanopi-R4S (WAN)

__Test #1__

Host | Command
-|-
Nanopi-R4S |	iperf -s
Workstation |	iperf -c 192.168.0.62 -t 120

```
------------------------------------------------------------
Client connecting to 192.168.0.62, TCP port 5001
TCP window size: 85.0 KByte (default)
------------------------------------------------------------
[  3] local 192.168.0.2 port 59820 connected with 192.168.0.62 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-120.0 sec  13.2 GBytes   942 Mbits/sec
```

__Test #2__

Host | Command
-|-
Nanopi-R4S |	iperf -s
Workstation |	iperf -c 192.168.0.62 -t 120 -w 65536

```
------------------------------------------------------------
Client connecting to 192.168.0.62, TCP port 5001
TCP window size:  128 KByte (WARNING: requested 64.0 KByte)
------------------------------------------------------------
[  3] local 192.168.0.2 port 59850 connected with 192.168.0.62 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-120.0 sec  13.2 GBytes   941 Mbits/sec
```

__Test #3__

Host | Command
-|-
Nanopi-R4S |	iperf -s -w 131072
Workstation |	iperf -c 192.168.0.62 -t 120 -w 131072

```
------------------------------------------------------------
Client connecting to 192.168.0.62, TCP port 5001
TCP window size:  256 KByte (WARNING: requested  128 KByte)
------------------------------------------------------------
[  3] local 192.168.0.2 port 59854 connected with 192.168.0.62 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-120.0 sec  13.1 GBytes   941 Mbits/sec
```

__Test #4__

Host | Command
-|-
Nanopi-R4S |	iperf -s
Workstation |	iperf -c 192.168.0.62 -t 120 -d -P 2

```
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size:  128 KByte (default)
------------------------------------------------------------
------------------------------------------------------------
Client connecting to 192.168.0.62, TCP port 5001
TCP window size:  391 KByte (default)
------------------------------------------------------------
[  5] local 192.168.0.2 port 32882 connected with 192.168.0.62 port 5001
[  4] local 192.168.0.2 port 32880 connected with 192.168.0.62 port 5001
[  6] local 192.168.0.2 port 5001 connected with 192.168.0.62 port 55152
[  7] local 192.168.0.2 port 5001 connected with 192.168.0.62 port 55154
[ ID] Interval       Transfer     Bandwidth
[  8]  0.0-120.0 sec  6.45 GBytes   462 Mbits/sec
[  6]  0.0-120.0 sec  6.46 GBytes   462 Mbits/sec
[  4]  0.0-120.5 sec  6.47 GBytes   461 Mbits/sec
[  5]  0.0-120.5 sec  6.46 GBytes   461 Mbits/sec
[SUM]  0.0-120.5 sec  12.9 GBytes   922 Mbits/sec
```

__Test #5__

Host | Command
-|-
Nanopi-R4S |	iperf -s -u
Workstation |	iperf -c 192.168.0.62 -u -t 120 -b 1000M

```
------------------------------------------------------------
Client connecting to 192.168.0.62, UDP port 5001
Sending 1470 byte datagrams, IPG target: 11.22 us (kalman adjust)
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
[  3] local 192.168.0.2 port 50200 connected with 192.168.0.62 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-120.0 sec  13.4 GBytes   957 Mbits/sec
[  3] Sent 9764940 datagrams
[  3] Server Report:
[  3]  0.0-120.0 sec  13.4 GBytes   957 Mbits/sec   0.000 ms 2127956392/2137718708 (0%)
```

__Test #6__

Host | Command
-|-
Nanopi-R4S |	iperf -s -u
Workstation |	iperf -c 192.168.0.62 -u -t 120 -b 1000M -d


```
------------------------------------------------------------
Server listening on UDP port 5001
Receiving 1470 byte datagrams
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
------------------------------------------------------------
Client connecting to 192.168.0.62, UDP port 5001
Sending 1470 byte datagrams, IPG target: 11.22 us (kalman adjust)
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
[  4] local 192.168.0.2 port 40576 connected with 192.168.0.62 port 5001 (peer 2.0.13)
[  3] local 192.168.0.2 port 5001 connected with 192.168.0.62 port 48176
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-120.0 sec  13.4 GBytes   957 Mbits/sec
[  4] Sent 9765245 datagrams
[  3]  0.0-120.0 sec  9.11 GBytes   652 Mbits/sec   0.027 ms    0/6653321 (0%)
[  3] WARNING: ack of last datagram failed after 10 tries.
[  4] Server Report:
[  4]  0.0-120.0 sec  12.9 GBytes   926 Mbits/sec   0.000 ms 2128274496/2137718403 (0%)
[  4] 0.00-120.00 sec  1 datagrams received out-of-order
```

## Nanopi-R4S WAN results

As you can see from the above benchmarks the Nanopi-R4S WAN interface is fully capable of GbE speed, which is really cool. I've also used the FriendlyWRT web interface to get some screenshots of the various Luci statistics using the default enabled collectd sensors. These are the results.

![]({{page.img_src}}/nanopi-r4s-graph-wan-processor.png){: width="{{page.img_width}}" {{page.img_extras}}}
![]({{page.img_src}}/nanopi-r4s-graph-wan-system-load.png){: width="{{page.img_width}}" {{page.img_extras}}}
![]({{page.img_src}}/nanopi-r4s-graph-wan-memory.png){: width="{{page.img_width}}" {{page.img_extras}}}
![]({{page.img_src}}/nanopi-r4s-graph-wan-thermal.png){: width="{{page.img_width}}" {{page.img_extras}}}

As you can see the CPU usage is ~35%, but most of the load is because of the docker daemon that is running in the background. Also note that the temperature is 60C without the heatsink and less than 40C with the heatsink. This happened because I've added the heatsink in the middle of the test, but that was eventually a good thing because I've seen the difference that it does.

As you can see the WAN interface reaches the max GbE speed of my setup, which is really great.

The consumption when Nanopi-R4S is idle is 0.44A at 5V and 1A during test #6.

![]({{page.img_src}}/nanopi-r4s-consumption.jpg){: width="{{page.img_width}}" {{page.img_extras}}}

## Nanopi-R4S bridge benchmarks

So, now lets test the bridge network interface, which is actually the most interesting benchmark for this device as it shows it's capabilities in the real-case scenario.

#### Workstation -> Switch -> Nanopi-R4S (WAN) -> Nanopi-R4S (Br0) -> Laptop (USB-to-GbE)

__Test #1__

Host | Command
-|-
Workstation	| iperf -s
Laptop	| iperf -c 192.168.0.2 -t 120

```
------------------------------------------------------------
Client connecting to 192.168.0.2, TCP port 5001
TCP window size: 204 KByte (default)
------------------------------------------------------------
[ 3] local 192.168.2.126 port 39014 connected with 192.168.0.2 port 5001
[ ID] Interval    Transfer   Bandwidth
[ 3] 0.0-120.0 sec 13.1 GBytes  940 Mbits/sec
```

__Test #2__

Host | Command
-|-
Workstation	| iperf -s
Laptop	| iperf -c 192.168.0.2 -t 120 -w 65536


```
------------------------------------------------------------
Client connecting to 192.168.0.2, TCP port 5001
TCP window size: 128 KByte (WARNING: requested 64.0 KByte)
------------------------------------------------------------
[ 3] local 192.168.2.126 port 39196 connected with 192.168.0.2 port 5001
[ ID] Interval    Transfer   Bandwidth
[ 3] 0.0-120.0 sec 9.50 GBytes  680 Mbits/sec
```

__Test #3__

Host | Command
-|-
Workstation |	iperf -s -w 131072
Laptop | iperf -c 192.168.0.2 -t 120 -w 131072

```
------------------------------------------------------------
Client connecting to 192.168.0.2, TCP port 5001
TCP window size: 256 KByte (WARNING: requested 128 KByte)
------------------------------------------------------------
[ 3] local 192.168.2.126 port 39240 connected with 192.168.0.2 port 5001
[ ID] Interval    Transfer   Bandwidth
[ 3] 0.0-120.0 sec 10.6 GBytes  758 Mbits/sec
```

__Test #4__

Host | Command
-|-
Workstation |	iperf -s
Laptop | iperf -c 192.168.0.2 -t 120 -d -P 2

```
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 128 KByte (default)
------------------------------------------------------------
------------------------------------------------------------
Client connecting to 192.168.0.2, TCP port 5001
TCP window size: 153 KByte (default)
------------------------------------------------------------
[ 4] local 192.168.2.126 port 49010 connected with 192.168.0.2 port 5001
[ 5] local 192.168.2.126 port 49012 connected with 192.168.0.2 port 5001
[ ID] Interval    Transfer   Bandwidth
[ 4] 0.0-120.0 sec 6.66 GBytes  476 Mbits/sec
[ 5] 0.0-120.0 sec 6.49 GBytes  465 Mbits/sec
[SUM] 0.0-120.0 sec 13.2 GBytes  941 Mbits/sec
```

__Test #5__

Host | Command
-|-
Workstation	| iperf -s -u
Laptop	| iperf -c 192.168.0.2 -u -t 120 -b 1000M

```
Client connecting to 192.168.0.2, UDP port 5001
Sending 1470 byte datagrams, IPG target: 11.22 us (kalman adjust)
UDP buffer size: 208 KByte (default)
------------------------------------------------------------
[ 3] local 192.168.2.126 port 57264 connected with 192.168.0.2 port 5001
[ 3] WARNING: did not receive ack of last datagram after 10 tries.
[ ID] Interval    Transfer   Bandwidth
[ 3] 0.0-120.0 sec 13.4 GBytes  957 Mbits/sec
[ 3] Sent 9761678 datagrams
```

__Test #6__

Host | Command
-|-
Workstation	| iperf -s -u
Laptop	| iperf -c 192.168.0.2 -u -t 120 -b 1000M -d

```
------------------------------------------------------------
Server listening on UDP port 5001
Receiving 1470 byte datagrams
UDP buffer size: 208 KByte (default)
------------------------------------------------------------
------------------------------------------------------------
Client connecting to 192.168.0.2, UDP port 5001
Sending 1470 byte datagrams, IPG target: 11.22 us (kalman adjust)
UDP buffer size: 208 KByte (default)
------------------------------------------------------------
[ 4] local 192.168.2.126 port 39169 connected with 192.168.0.2 port 5001 (peer 2.0.10-alpha)
[ ID] Interval    Transfer   Bandwidth
[ 4] 0.0-120.0 sec 13.4 GBytes  956 Mbits/sec
[ 4] Sent 9757183 datagrams
[ 4] Server Report:
[ 4] 0.0-120.0 sec 7.84 GBytes  561 Mbits/sec  0.000 ms 2131996332/2137726465 (1e+02%)
[ 4] 0.0000-120.0257 sec 1 datagrams received out-of-order
```

## Nanopi-R4S bridge results

As you can see from the above benchmarks the Nanopi-R4S can max the GbE speed of my setup in the bridged mode. You may see that the speed dropped when using custom TCP window sizes, which I guess it's because of the mismatch window sizes internally in bridge, but I don't give much attention to this as the default TCP size works fine.

These are some screenshots from the web interface and the sensors.

![]({{page.img_src}}/nanopi-r4s-graph-br0-interfaces.pngprocessor.png){: width="{{page.img_width}}" {{page.img_extras}}}
![]({{page.img_src}}/nanopi-r4s-graph-br0-interfaces.png){: width="{{page.img_width}}" {{page.img_extras}}}
![]({{page.img_src}}/nanopi-r4s-graph-br0-interfaces.pngsystem-load.png){: width="{{page.img_width}}" {{page.img_extras}}}
![]({{page.img_src}}/nanopi-r4s-graph-br0-interfaces.pngmemory.png){: width="{{page.img_width}}" {{page.img_extras}}}
![]({{page.img_src}}/nanopi-r4s-graph-br0-interfaces.pngthermal.png){: width="{{page.img_width}}" {{page.img_extras}}}


As you can see the CPU load is less than 30% and again most of the load is because of the docker daemon running in the background. Also the temperature doesn't exceed the 38C, which means the heatsink works really well.

Again my personal opinion is that the Nanopi-R4S reaches the maximum performance of my network also in the bridge mode. Excellent.

## Nanopi-R2S WAN Benchmarks

This post would be incomplete without compare benchmarks between the Nanopi-R4S and Nanopi-R2S. Therefore, I've also executed the same benchmarks on the R2S in both WAN and bridge interface. These are the WAN results.

__Test #1__

Host | Command
-|-
Nanopi-R2S |	iperf -s
Workstation |	iperf -c 192.168.0.63 -t 120
```

```
------------------------------------------------------------
Client connecting to 192.168.0.63, TCP port 5001
TCP window size: 85.0 KByte (default)
------------------------------------------------------------
[  3] local 192.168.0.2 port 60864 connected with 192.168.0.63 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-120.0 sec  13.1 GBytes   941 Mbits/sec
```

__Test #2__

Host | Command
-|-
Nanopi-R2S |	iperf -s
Workstation |	iperf -c 192.168.0.63 -t 120 -w 65536

```
------------------------------------------------------------
Client connecting to 192.168.0.63, TCP port 5001
TCP window size:  128 KByte (WARNING: requested 64.0 KByte)
------------------------------------------------------------
[  3] local 192.168.0.2 port 60878 connected with 192.168.0.63 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-120.0 sec  13.1 GBytes   937 Mbits/sec
```

__Test #3__

Host | Command
-|-
Nanopi-R2S	| iperf -s -w 131072
Workstation	| iperf -c 192.168.0.63 -t 120 -w 131072

```
------------------------------------------------------------
Client connecting to 192.168.0.63, TCP port 5001
TCP window size:  256 KByte (WARNING: requested  128 KByte)
------------------------------------------------------------
[  3] local 192.168.0.2 port 60884 connected with 192.168.0.63 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-120.0 sec  13.1 GBytes   938 Mbits/sec
```

__Test #4__

Host | Command
-|-
Nanopi-R2S | iperf -s
Workstation	| iperf -c 192.168.0.63 -t 120 -d -P 2


```
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size:  128 KByte (default)
------------------------------------------------------------
------------------------------------------------------------
Client connecting to 192.168.0.63, TCP port 5001
TCP window size:  246 KByte (default)
------------------------------------------------------------
[  5] local 192.168.0.2 port 60890 connected with 192.168.0.63 port 5001
[  4] local 192.168.0.2 port 60888 connected with 192.168.0.63 port 5001
[  6] local 192.168.0.2 port 5001 connected with 192.168.0.63 port 42238
[  7] local 192.168.0.2 port 5001 connected with 192.168.0.63 port 42240

[ ID] Interval       Transfer     Bandwidth
[  6]  0.0-120.0 sec  5.65 GBytes   405 Mbits/sec
[  4]  0.0-120.0 sec  5.12 GBytes   366 Mbits/sec
[  5]  0.0-120.1 sec  4.68 GBytes   335 Mbits/sec
[SUM]  0.0-120.1 sec  9.79 GBytes   701 Mbits/sec
[  8]  0.0-120.0 sec  7.29 GBytes   521 Mbits/sec
```

__Test #5__

Host | Command
-|-
Nanopi-R2S	| iperf -s -u
Workstation	| iperf -c 192.168.0.63 -u -t 120 -b 1000M

```
------------------------------------------------------------
Client connecting to 192.168.0.63, UDP port 5001
Sending 1470 byte datagrams, IPG target: 11.22 us (kalman adjust)
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
[  3] local 192.168.0.2 port 39818 connected with 192.168.0.63 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-120.0 sec  13.4 GBytes   957 Mbits/sec
[  3] Sent 9765428 datagrams
[  3] Server Report:
[  3]  0.0-120.0 sec  8.06 GBytes   577 Mbits/sec   0.000 ms 2131827393/2137718220 (0%)
```

__Test #6__

Host | Command
-|-
Nanopi-R2S	| iperf -s -u
Workstation	| iperf -c 192.168.0.63 -u -t 120 -b 1000M -d

```
------------------------------------------------------------
Server listening on UDP port 5001
Receiving 1470 byte datagrams
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
------------------------------------------------------------
Client connecting to 192.168.0.63, UDP port 5001
Sending 1470 byte datagrams, IPG target: 11.22 us (kalman adjust)
UDP buffer size:  208 KByte (default)
------------------------------------------------------------
[  4] local 192.168.0.2 port 50365 connected with 192.168.0.63 port 5001 (peer 2.0.13)
[  3] local 192.168.0.2 port 5001 connected with 192.168.0.63 port 58210
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-120.0 sec  13.4 GBytes   957 Mbits/sec
[  4] Sent 9765269 datagrams
[  3]  0.0-120.0 sec  7.56 GBytes   541 Mbits/sec   0.040 ms    0/5520546 (0%)
[  3] WARNING: ack of last datagram failed after 10 tries.
[  4] Server Report:
[  4]  0.0-120.0 sec  8.05 GBytes   576 Mbits/sec   0.000 ms 2131838458/2137718379 (0%)
[  4] 0.00-120.00 sec  1 datagrams received out-of-order
```

## Nanopi-R2S WAN results

As you can see from the above benchmarks, although the TCP test with the default window size reaches the maximum performance, the performance drops in the TCP parallel test.

These are the sensor graphs from the web interface.

![]({{page.img_src}}/nanopi-r2s-graph-wan-processor.png){: width="{{page.img_width}}" {{page.img_extras}}}
![]({{page.img_src}}/nanopi-r2s-graph-wan-thermal.png){: width="{{page.img_width}}" {{page.img_extras}}}
![]({{page.img_src}}/nanopi-r2s-graph-wan-memory.png){: width="{{page.img_width}}" {{page.img_extras}}}
![]({{page.img_src}}/nanopi-r2s-graph-wan-system-load.png){: width="{{page.img_width}}" {{page.img_extras}}}

As you can see the processor usage is ~60% which the double compared to the Nanopi-R4S, but again the docker daemon uses ~30% of the CPU. Also the temperature seems to be higher than Nanopi-R4S, even with the better thermal I've used.

## Nanopi-R2S bridge benchmarks

Let's now see the benchmarks of the bridge interface for the Nanopi-R2S

__Test #1__

Host | Command
-|-
Workstation	| iperf -s
Laptop	| iperf -c 192.168.0.2 -t 120

```
------------------------------------------------------------
Client connecting to 192.168.0.2, TCP port 5001
TCP window size: 196 KByte (default)
------------------------------------------------------------
[ 3] local 192.168.2.126 port 43028 connected with 192.168.0.2 port 5001
[ ID] Interval    Transfer   Bandwidth
[ 3] 0.0-120.0 sec 9.51 GBytes  681 Mbits/sec
```

__Test #2__

Host | Command
-|-
Workstation |	iperf -s
Laptop | iperf -c 192.168.0.2 -t 120 -w 65536

```
------------------------------------------------------------
Client connecting to 192.168.0.2, TCP port 5001
TCP window size: 128 KByte (WARNING: requested 64.0 KByte)
------------------------------------------------------------
[ 3] local 192.168.2.126 port 43030 connected with 192.168.0.2 port 5001
[ ID] Interval    Transfer   Bandwidth
[ 3] 0.0-120.0 sec 5.04 GBytes  360 Mbits/sec
```

__Test #3__

Host | Command
-|-
Workstation	| iperf -s -w 131072
Laptop	| iperf -c 192.168.0.2 -t 120 -w 131072

```
------------------------------------------------------------
Client connecting to 192.168.0.2, TCP port 5001
TCP window size: 128 KByte (WARNING: requested 64.0 KByte)
------------------------------------------------------------
[ 3] local 192.168.2.126 port 43030 connected with 192.168.0.2 port 5001
[ ID] Interval    Transfer   Bandwidth
[ 3] 0.0-120.0 sec 5.04 GBytes  360 Mbits/sec
```

__Test #4__

Host | Command
-|-
Workstation	| iperf -s
Laptop	| iperf -c 192.168.0.2 -t 120 -d -P 2

```
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 128 KByte (default)
------------------------------------------------------------
------------------------------------------------------------
Client connecting to 192.168.0.2, TCP port 5001
TCP window size: 153 KByte (default)
------------------------------------------------------------
[ 4] local 192.168.2.126 port 43042 connected with 192.168.0.2 port 5001
[ 5] local 192.168.2.126 port 43044 connected with 192.168.0.2 port 5001
[ ID] Interval    Transfer   Bandwidth
[ 5] 0.0-120.0 sec 4.41 GBytes  315 Mbits/sec
[ 4] 0.0-120.0 sec 4.63 GBytes  331 Mbits/sec
[SUM] 0.0-120.0 sec 9.04 GBytes  647 Mbits/sec
```

__Test #5__

Host | Command
-|-
Workstation	| iperf -s -u
Laptop	| iperf -c 192.168.0.2 -u -t 120 -b 1000M

```
------------------------------------------------------------
Client connecting to 192.168.0.2, UDP port 5001
Sending 1470 byte datagrams, IPG target: 11.22 us (kalman adjust)
UDP buffer size: 208 KByte (default)
------------------------------------------------------------
[ 3] local 192.168.2.126 port 52107 connected with 192.168.0.2 port 5001
[ ID] Interval    Transfer   Bandwidth
[ 3] 0.0-120.0 sec 13.4 GBytes  957 Mbits/sec
[ 3] Sent 9762311 datagrams
[ 3] Server Report:
[ 3] 0.0-120.0 sec 6.42 GBytes  460 Mbits/sec  0.000 ms 2133031099/2137721337 (1e+02%)
```

__Test #6__

Host | Command
-|-
Workstation	| iperf -s -u
Laptop | iperf -c 192.168.0.2 -u -t 120 -b 1000M -d

```
------------------------------------------------------------
Server listening on UDP port 5001
Receiving 1470 byte datagrams
UDP buffer size: 208 KByte (default)
------------------------------------------------------------
------------------------------------------------------------
Client connecting to 192.168.0.2, UDP port 5001
Sending 1470 byte datagrams, IPG target: 11.22 us (kalman adjust)
UDP buffer size: 208 KByte (default)
------------------------------------------------------------
[ 3] local 192.168.2.126 port 54616 connected with 192.168.0.2 port 5001 (peer 2.0.10-alpha)
[ ID] Interval    Transfer   Bandwidth
[ 3] 0.0-120.0 sec 12.4 GBytes  890 Mbits/sec
[ 3] Sent 9081045 datagrams
[ 3] Server Report:
[ 3] 0.0-120.2 sec  917 MBytes 64.0 Mbits/sec  0.000 ms 2137748578/2138402602 (1e+02%)
[ 3] 0.0000-120.2481 sec 1 datagrams received out-of-order
```

## Nanopi-R2S bridge results

As you can see from the above benchmarks the Nanopi-R2S has trouble to reach the maximum performance of the network and this seems to be an issue with the internal USB-to-GbE of the board. Nevertheless, some of you may be satisfied with those results for your use case.

These are the sensors graphs from the web interface.

![]({{page.img_src}}/nanopi-r2s-graph-br0-processor.png){: width="{{page.img_width}}" {{page.img_extras}}}
![]({{page.img_src}}/nanopi-r2s-graph-br0-interfaces.png){: width="{{page.img_width}}" {{page.img_extras}}}
![]({{page.img_src}}/nanopi-r2s-graph-br0-memory.png){: width="{{page.img_width}}" {{page.img_extras}}}
![]({{page.img_src}}/nanopi-r2s-graph-br0-system-load.png){: width="{{page.img_width}}" {{page.img_extras}}}
![]({{page.img_src}}/nanopi-r2s-graph-br0-thermal.png){: width="{{page.img_width}}" {{page.img_extras}}}

The consumption when Nanopi-R2S is idle is 0.3A at 5V and 0.58A during test #6.

![]({{page.img_src}}/nanopi-r2s-consumption.jpg){: width="{{page.img_width}}" {{page.img_extras}}}

## Nanopi-R4S vs Nanopi-R2S

OK, some of you may want to choose between those two boards. Well, I won't try to get into too many details in the specific things that are different between those two. Instead I'll just add a table here with the tests results and also add a few notes after that.

Test	| Nanopi-R4S (Mbits/sec) ||	Nanopi-R2S (Mbits/sec) |
      |     WAN	    |    Br0   |     WAN	    |   Br0    |
------|------------------------|-------------------------|
#1	| 942	| 940	| 941	| 681
#2	| 941	| 680	| 937	| 360
#3	| 941	| 758	| 938	| 360
#4	| 922	| 941	| 701	| 647
#5	| 957	| 957	| 577	| 460
#6	| 926	| 561	| 576	| 64

From the above table you can see that the new Nanopi-R4S is faster than R2S especially when it comes to UDP data transfers. The R4S is reaching in most cases the maximum network capacity, but R2S can't. Therefore, the R4S has better performance over the R2S.

|      | Nanopi R4S	     | Nanopi R2S   |
|------|------------------|---------------|
| pros | + Performance    | + Consumption
|  ^   | + Up to 4GB RAM  | + Smaller size
|  ^   | + Nice case      | + Nice case
|  ^   | + Doesn’t get hot	| + Price
| cons | – Price          | – Performance
|  ^   | – A bit larger than R2S | – It gets a bit hot


The R4S costs [$45 (1GB)](https://www.friendlyarm.com/index.php?route=product/product&product_id=284) and the R2S [$22](https://www.friendlyarm.com/index.php?route=product/product&product_id=282).

## Conclusions

As I've mentioned, I've received this board from FriendlyArm as a sample for evaluation purposes. My plan was to create a Yocto BSP layer for this, but since the Armbian support is not ready yet I've decided to do a benchmark and a comparison between the R4S and the R2S.

Personally, I like the performance of this board and I think it's nice to use as a home router. Just have in mind that if you compare it with the R2S then the performance is better but also it consumes more power, as the _RK3399_ is a more power-hungry SoC than the _RK3328_.

Hope this post was useful.

Have fun!