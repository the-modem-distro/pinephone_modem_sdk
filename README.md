# Pinephone Modem SDK

### Custom firmware for your Pinephone's modem

#### Dependencies
This project depends on the following repositories:
* LK - [Little Kernel bootloader](https://github.com/Biktorgj/quectel_lk)
* [Downstream 3.18.140 Kernel based on CAF](https://github.com/Biktorgj/quectel_eg25_kernel)
* [Forked meta-qcom repository](https://github.com/Biktorgj/meta-qcom)
* [The Yocto Project](https://yoctoproject.org)

Make sure you have your recoveries ready just in case:
* [Quectel EG25 firmware repo](https://github.com/Biktorgj/quectel_eg25_recovery)

### Rolling your own? [Check the Howto](https://github.com/Biktorgj/pinephone_modem_sdk/blob/hardknott/docs/HOWTO.md)

### Want to flash it? [Here's a guide!](https://github.com/Biktorgj/pinephone_modem_sdk/blob/hardknott/docs/FLASHING.md)

### Going back to stock? [There's a Howto](https://github.com/Biktorgj/pinephone_modem_sdk/blob/hardknott/docs/RECOVERY.md) too!

### Latest release: [Yocto 3.3.2](https://github.com/Biktorgj/pinephone_modem_sdk/releases/tag/0.3.5)

### Having issues? [Check out if the issue is already documented or create a new one](https://github.com/Biktorgj/pinephone_modem_sdk/issues)

#### Current Status:
* LK Bootloader
  * Image building: Works
  * Bootloader functionality:
    * Boot: OK
    * Flash: OK
    * Debugging: Via debug UART
    * Signals and custom boot modes via GPIO pins: OK
      * Check tools/helpers for scripts to force boot into fastboot or out of it
    	* On reset, the bootloader enters into fastboot mode automatically for 2 seconds, and boots normally unless instructed to stay (leave the command `fastboot oem stay` running while rebooting the modem to make it stop at fastboot).
  * Custom fastboot commands:
    * fastboot reboot-bootlader: Reboot to fastboot
    * fastboot oem stay: Stay in fastboot instead of booting normally
    * fastboot oem reboot-recovery: Reboot to recovery mode
    * fastboot oem reboot-edl: Currently not working (investigating why)
    * fastboot oem getmfg: Try to identify the modem from the partition table

* CAF Kernel:
	* Building: Works
	* Booting: Works
		* USB Peripheral mode: WWAN+ADB are working blobfree, WWAN+GPS+ADB with blobs
		* Modem (ADSP): Firmware loading, booting, data and calling works.
    * Audio: Working, needs fine tunning (1-5 seconds of silence on call start)
    * Ring In: Works correctly when setting the modem to report RING to all interfaces. You can do this by sending the following command to the modem:
      * AT+QURCCFG="urcport","all". Most distros have this setting already enabled
    * Call volume: May need some tweaking to the ALSA UCM configuration file. You can do this by editing `/usr/share/alsa/ucm2/PinePhone/VoiceCall.conf`. These values seem to work well:
      * `cset "name='AIF1 DA0 Playback Volume' 90%"`
      * `cset "name='AIF2 DAC Playback Volume' 90%"`
      * A reboot is required after changing this configuration file.
    * GPS: Working
    * Sleep / Power management: The kernel is always running in low power mode now, this should make the Pinephone consume between 1.12%-1.89% battery on suspend, giving a max runtime on a battery charge of 78 hours / 3 days if there's nothing waking it up, in par with factory firmware with ADB disabled.
    * Non persistent data partition (now there's no way of corrupting anything when killing the modem)
* System images:
  * root_fs: Default system image. Includes a minimal root filesystem and one application replacing the entire Qualcomm / Quectel stack. Some functions are not yet functional
  * recovery_fs: Minimal bootable image to be flashed into the recovery partitions to retrieve logs and make changes to the root image
* Custom AT Commands: Please see this [document](https://github.com/Biktorgj/pinephone_modem_sdk/blob/0.3.5/docs/AT_INTERFACE.md#custom-commands-in-this-firmware)

TODO
 1. Find fixes to support dynamic rate settings in the Pinephone
 2. Finish and tidy up the AT command handling stuff
 3. Allow bootloader PIN lock to prevent accidental flashing
 4. Implement opensource ACDB loader?
 5. Fix fastboot reboot to EDL if possible
 6. Companion app to update the firmware / manage modem settings / retrieve logs
 
 Contribution is always welcome! Feel free to share any issue or something that you think may be interesting to have!

#### Documentation
I'm really bad at documentation, but you have some docs [here](https://github.com/Biktorgj/pinephone_modem_sdk/tree/hardknott/docs), thanks @Zapeth for your help!
