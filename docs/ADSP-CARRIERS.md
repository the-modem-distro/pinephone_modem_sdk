# Choosing an ADSP firmware version

## What is the ADSP firmware?
This firmware does it best to fix some really annoying issues found in the stock firmware. It does not, however, touch the ADSP firmware. The ADSP firmware is what actually controls all the modem functionality. It's the software in charge of all the RF functions, what reads your SIM card, processes calls and messages, and gets your internet connection running. All the rest is just a proxy so the Pinephone can communicate with it.

## Which versions do you recommend?
For my use case, I use the latest version, 01.003.01.003. This works perfectly for me, without issues to place calls, always recovering the data session when waking up from suspend, and in general, not causing any issues whatsoever. But what works for me might not work for you, specially when using some specific carriers. If you flash this version and you run into problems, downgrading back to 01.002.01.002 will probably fix any issues with the ADSP firmware.

## Where do I get them?
Here:
* [ADSP Version 01.003.01.003](https://github.com/Biktorgj/quectel_eg25_recovery/raw/EG25GGBR07A08M2G_01.003.01.003/update/NON-HLOS.ubi). 
* [ADSP Version 01.002.01.002](https://github.com/Biktorgj/quectel_eg25_recovery/raw/EG25GGBR07A08M2G_01.002.01.002/update/NON-HLOS.ubi)

## How do I flash them?
Just download whichever version you want, reboot to fastboot and flash the modem partition with the image file:
- `adb shell reboot && fastboot oem stay && fastboot flash modem NON-HLOS.ubi && fastboot reboot`from the folder you downloaded the file (as root!)

## Will X firmware version work with Y provider?
Here's an (almost empty) table with results from different providers. Feel free to do a PR with your results!


| Country | Carrier | Recommended ADSP version | Remarks |
| ------- |:-----------:|:----------:|:-----------:|
| Spain | Vodafone ES (Postpaid) | 01.003 | Version 01.002 sometimes doesn't reconnect correctly to data |
| Spain | Pepephone (Roaming on Orange| 01.003 | No issues found with either version |
| US | Verizon US ( Postpaid ) | 01.002 | Version 01.003 does take a real long time connecting, sometimes does not detect sim card |
| US | Mint Mobile | 01.003 | Data doesn't seem to work on 30.004 |
| US | T-Mobile | 01.003 | |
