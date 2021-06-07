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

### Latest release:
[Yocto 3.3](https://github.com/Biktorgj/pinephone_modem_sdk/releases/tag/0.2.1)

#### Current Status:
* LK Bootloader
  * Image building: Works
  * Bootloader functionality:
    * Boot: OK
    * Flash: OK
    * Debugging: Via debug UART
    * Signals and custom boot modes via GPIO pins: OK
      * Check tools/helpers for scripts to force boot into fastboot or out of it
      * Fastboot auto entering: OK
	* On reset, the bootloader enters into fastboot mode automatically for 2 seconds, and boots normally unless instructed to stay (leave the command `fastboot oem stay` running while rebooting the modemto make it stop at fastboot).
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
    * Audio: Working, there might be some glitches still in some scenarios
    * Ring In: Works correctly when setting the modem to report RING to all interfaces. You can do this by sending the following command to the modem:
      * AT+QURCCFG="urcport","all"
    * GPS: Working
    * Sleep / Power management: The kernel is always running in low power mode now, this should make the Pinephone consume between 1.12%-1.89% battery on suspend, giving a max runtime on a battery charge of 78 hours / 3 days if there's nothing waking it up, in par with factory firmware with ADB disabled.
    * Non persistent data partition (now there's no way of corrupting anything when killing the modem)
* System images:
  * root_fs: Default system image. Includes a minimal root filesystem and one application replacing the entire Qualcomm / Quectel stack. Some functions are not yet functional
  * recovery_fs: Minimal bootable image to be flashed into the recovery partitions to retrieve logs and make changes to the root image
* Custom AT Commands:
  * AT+ADBON / AT+ADBOFF: Enable or disable ADB at runtime (this will reset USB for a second)
  * AT+RESETUSB: Stop and start USB on the modem
  * AT+QFASTBOOT: Jump to fastboot mode
  * AT+REBOOT_REC: Jump to recovery mode
  * AT+PWRDN: Shut down the modem
  * AT+QDAI: WIP, set audio configuration on the modem
  * AT+EN_PCM8K: (default) Set sampling rate to 8KHz
  * AT+EN_PCM16K: Set sampling rate to 16KHz
  * AT+EN_PCM48K: Set sampling rate to 48KHz


Pending tasks:
 1. Find a fix for issues with latest ModemManager breaking data
 2. Find fixes to support dynamic rate settings in the Pinephone
 3. Finish and tidy up the AT command handling stuff
 4. Test out audio over USB. Can be enabled via USB config, but haven't tested if audio is actually routed through there

##### NOTES:
###### Proprietary recipes removed
With the move from Yocto 3.2 to 3.3, I have removed all the proprietary recipes. You can still check them out in the `meta-qcom` repository's *main* branch if you're looking for something specific, but I won't be checking if it builds and boots with it as I don't think they're necessary anymore

###### Opensource recipes:
  * meta-qcom/recipes-modem/openqti: I've reimplemented everything I had separated in three different utilities into OpenQTI. This takes care of the folllowing at this point:
     - Initialize Kernel's IPC Security settings
     - Initialize DPM to start the required devices for QMI to pass through USB
     - Initialize I2S settings for call audio
     - Initialize the AT service in the DSP and register all commands
     - Act as a proxy between modem's USB QMI and the kernel smdcntl8 node
     - Act as a proxy for the GPS port
     - Listen to AT Commands and blindly respond OK to everything not implemented (to make userspace happy)
     - Sniffs on the QMI port to try and detect when there's a CS/VoLTE call and enable/disable audio accordingly

#### About call audio
If curious, I've left some notes on how audio is setup in this firmware in docs/AUDIO_PKT
