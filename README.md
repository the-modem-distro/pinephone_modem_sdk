# Pinephone Modem SDK

### (nearly) Free custom firmware for your Pinephone's modem!

This repository contains all the tools you need use to make your own Modem userspace for your Pinephone.

### Latest release: [Version 0.4.1 based on Yocto 3.3.2](https://github.com/Biktorgj/pinephone_modem_sdk/releases/tag/0.4.1)

- Rolling your own? [Check the Howto](https://github.com/Biktorgj/pinephone_modem_sdk/blob/hardknott/docs/HOWTO.md)
- Want to flash it? [Here's a guide!](https://github.com/Biktorgj/pinephone_modem_sdk/blob/hardknott/docs/FLASHING.md)
- Going back to stock? [There's a Howto](https://github.com/Biktorgj/pinephone_modem_sdk/blob/hardknott/docs/RECOVERY.md) too!
- Having issues? [Check out if the issue is already documented or create a new one](https://github.com/Biktorgj/pinephone_modem_sdk/issues)
  - There's also a [Matrix room now!](https://matrix.to/#/#pinephone_modem_sdk-issue-9:matrix.org)

#### Current Status:
* LK Bootloader: Working
  * On reset, the bootloader enters into fastboot mode automatically for 2 seconds, and boots normally unless instructed to stay (leave the command `fastboot oem stay` running while rebooting the modem to make it stop at fastboot).
   * Custom fastboot commands:
    * fastboot reboot-bootlader: Reboot to fastboot
    * fastboot oem stay: Stay in fastboot instead of booting normally
    * fastboot oem reboot-recovery: Reboot to recovery mode
    * fastboot oem reboot-edl: Currently not working (investigating why)
    * fastboot oem getmfg: Try to identify the modem from the partition table

* CAF Kernel: Working
* Audio: Working, needs fine tunning (1-5 seconds of silence on call start)
* Call volume: May need some tweaking to the ALSA UCM configuration file. You can do this by editing `/usr/share/alsa/ucm2/PinePhone/VoiceCall.conf`. These values seem to work well:
      * `cset "name='AIF2 DAC Playback Volume' 90%"`
      * `cset "name='AIF2 ADC Capture Volume' 90%"`
      * A reboot is required after changing this configuration file.
      * Feel free to play around with the values, default value is '160' for both items (without '%' sign). Mine sounds loud enough at both extremes with 90% and 80% respectively
* GPS: Working
* Sleep / Power management: Working (New current measurement and profiling required after latest changes)
* System images:
  * root_fs: Default system image. Includes a minimal root filesystem and one application replacing the entire Qualcomm / Quectel stack. Some functions are not yet functional
  * recovery_fs: Minimal bootable image to be flashed into the recovery partitions to retrieve logs and make changes to the root image
* Custom AT Commands: Please see this [document](https://github.com/Biktorgj/pinephone_modem_sdk/blob/0.3.5/docs/AT_INTERFACE.md#custom-commands-in-this-firmware)

#### Features not available on stock firmware:
 * Non persistent storage: There's no way of corrupting your modem firmware from a bad shutdown
 * Automatic time synchronization from the carrier into the userspace
 * Minimum clock frequency is set to 100Mhz, either awake or sleeping (stock is 800MHz awake and 400Mhz sleep), making the modem run cooler
 * Different sampling rates available at runtime without requiring a reboot (missing companion app in the pinephone to make use of them)
 * 0 binary blobs in the userspace. Only closed source running on the modem are TZ Kernel and ADSP firmware
#### TODO
 1. Find fixes to support dynamic rate settings in the Pinephone
 2. Finish and tidy up the AT command handling stuff
 3. Allow bootloader PIN lock to prevent accidental flashing
 4. Implement opensource ACDB loader?
 5. Fix fastboot reboot to EDL if possible
 6. Companion app to update the firmware / manage modem settings / retrieve logs
 
 Contribution is always welcome! Feel free to share any issue or something that you think may be interesting to have!

#### Related Repositories
This project depends on the following repositories:
* LK - [Little Kernel bootloader](https://github.com/Biktorgj/quectel_lk)
* [Downstream 3.18.140 Kernel based on CAF](https://github.com/Biktorgj/quectel_eg25_kernel)
* [Forked meta-qcom repository](https://github.com/Biktorgj/meta-qcom)
* [The Yocto Project](https://yoctoproject.org)

Make sure you have your recoveries ready just in case:
* [Quectel EG25 firmware repo](https://github.com/Biktorgj/quectel_eg25_recovery)

#### Documentation
I'm really bad at documentation, but you have some docs [here](https://github.com/Biktorgj/pinephone_modem_sdk/tree/hardknott/docs), thanks @Zapeth for your help!
