# Choosing an ADSP firmware version

## What is the ADSP firmware?
This firmware does it best to fix some really annoying issues found in the stock firmware. It does not, however, touch the ADSP firmware. The ADSP firmware is what actually controls all the modem functionality. It's the software in charge of all the RF functions, what reads your SIM card, processes calls and messages, and gets your internet connection running. All the rest is just a proxy so the Pinephone can communicate with it.

## Which versions do you recommend?
For my use case, I use the latest version, 01.003.01.003. This works perfectly for me, without issues to place calls, always recovering the data session when waking up from suspend, and in general, not causing any issues whatsoever. But what works for me might not work for you, specially when using some specific carriers. If you flash this version and you run into problems, downgrading back to 01.002.01.002 will probably fix any issues with the ADSP firmware.

## Where do I get them?
Here:
* [ADSP Version 30.004.30.004](https://github.com/Biktorgj/quectel_eg25_recovery/raw/EG25GGBR07A08M2G_30.004.30.004/update/NON-HLOS.ubi)
* [ADSP Version 01.003.01.003](https://github.com/Biktorgj/quectel_eg25_recovery/raw/EG25GGBR07A08M2G_01.003.01.003/update/NON-HLOS.ubi). 
* [ADSP Version 01.002.01.002](https://github.com/Biktorgj/quectel_eg25_recovery/raw/EG25GGBR07A08M2G_01.002.01.002/update/NON-HLOS.ubi)

## How do I flash them?
Just download whichever version you want, reboot to fastboot and flash the modem partition with the image file:
- `adb shell reboot && fastboot oem stay && fastboot flash modem NON-HLOS.ubi && fastboot reboot`from the folder you downloaded the file (as root!)

## Will X firmware version work with Y provider?
Here's an (almost empty) table with results from different providers. Feel free to do a PR with your results!


| Country | Carrier | Recommended ADSP version | Remarks |
| ------- |:-----------:|:----------:|:-----------:|
| Austria | Bob | ? | Network doesn't provide any correct date & time [1] |
| Germany | 1&1 (using Telefonica network) | 01.003, 30.004 | No issues |
| Spain | Vodafone ES (Postpaid) | 01.003 | Version 01.002 sometimes doesn't reconnect correctly to data |
| Spain | Pepephone (Roaming on Orange| 01.003 | No issues found with either version |
| US | Verizon US ( Postpaid ) | 01.002 | Version 01.003 does take a real long time connecting, sometimes does not detect sim card |
| US | Mint Mobile | 01.003 | Data doesn't seem to work on 30.004 |
| US | T-Mobile | 01.003 | |
| US | Ting (T-Mobile) | 01.003 | Data is IPv6 only on 30.004 |


[1] If you use *Bob* in Austria, you might run into an issue where the time never syncs from the network, as the network never sends correct date and time to the Modem. This is a problem, because AGPS won't be valid if the modem thinks it's in 1980. A fallback method is implemented into the modem userspace where it will first try to sync the time from network. If that fails, it will try to sync from the baseband RTC instead. It will keep trying until a somewhat-correct date is detected. 

User @karl implemented a script and a systemd unit that reads the correct date from the Pinephone and sends it via mmcli to the Modem, you can get instructions to set this up [in his blog](https://karl.kashofer.org/pinephone/114)