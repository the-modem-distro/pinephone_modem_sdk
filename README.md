# Pinephone Modem SDK

### Collection of tools and scripts to build custom boot images for Quectel EG25G modem.

#### Requirements
Before you can use this make sure your OS has all the packages needed by Yocto

Check them out here: https://docs.yoctoproject.org/singleindex.html

#### How to use

1.	Clone this repository in your computer
2.	Go to the folder where you downloaded your copy and run ./init.sh
3.	The script will download the LK bootloader, arm toolchain, Yocto 3.2 build environment and all the layers required to biild a bootanle sysyem.
4.	Run make, without arguments, to see what you can build:
    - Make aboot: build the LK bootloader but don’t sign it
    - Make aboot_signed: same as above, but sign it with Sectools (if available, sectools is not provided here to respect Qualcomm’s license)
    - Make kernel: will initialize Yocto’s build environment if it wasn’t already done before, and will build a bootable kernel which will be then copied to the target folder
    - Make root_fs: will initialize Yocto’s build environment if it wasn’t already done before, and will build a bootable rootfs+kernel which will be then copied to the target folder
    - Make recovery_fs: will initialize Yocto’s build environment if it wasn’t already done before, and will build a 15Mb bootable image that fits into the recovery partition to make debugging easier. I've left two scripts: recoverymount and rootfs mount that mount either of the rootfs partitions into /tmp so you can make modifications to the running image more easily
    - Make clean: Will remove build and temporary directories
    - Make target_extract: Will dump the contents of the generated image to target/dump so you can examine the contents of what you're pushing
    - make target_clean: Removes the target directory contents
    - make aboot_clean: Cleans the LK bootloader build folder along with the generated binary
    - make yocto_clean: Removes Yocto's temporary folder
    - make yocto_cleancache: Removes Yocto's sstate-cache in case you need to force a rebuild while working on recipes



#### Current Status:
* LK Bootloader
   * Image building: Works
   * Image Signing: Works (if you have sectools)
   * Bootloader functionality:
      * Boot: OK
      * Flash: OK
      * Debugging: Via debug pins
      * Signals and custom boot modes via GPIO pins: OK
        * Check tools/helpers for scripts to force boot into fastboot or out of it
      * Fastboot auto entering: OK
	* On reset, the bootloader enters into fastboot mode automatically for 5 seconds, and boots normally unless instructed to stay.
	* On reset, run _fastboot oem stay_ to stay in fastboot mode to flash the modem
      * Jump to...
        * Fastboot mode: OK (fastboot reboot-bootloader)
        * DLOAD Mode: NO (fastboot oem reboot-emergency): Pending
        * Recovery mode: OK (fastboot oem reboot-recovery)
   ** If there's a functionality you would like to see in the modem, drop me a message and I'll see what I can do **
* CAF Kernel:
	* Building: Works
	* Booting: Works
		* USB Peripheral mode: Audio, WWAN, GPS and ADB are working
		* Modem (ADSP): Firmware loading, booting, data and calling works.
    * Audio: Working
    * Ring In: Works correctly when setting the modem to report RING to all interfaces. You can do this by sending the following command to the modem:
      * AT+QURCCFG:"urcport","all"
      * You can also make this permanent by editing "pinephone-modem-setup.sh" and replacing the following line:
        * configure_modem "QURCCFG" '"urcport","usbat"' to
        * configure_modem "QURCCFG" '"urcport","all"'
      * I need to investigate where is the USB driver not passing it through (if it really is or is another issue, for sure it is kernel related)
		* Sleep: About 23-26 hours of runtime, consistent with Quectel's kernel
    * Modem services no longer run as root
    * Non persistent data partition (now there's no way of corrupting anything when killing the modem)
* System images:
	* Two images available: root_fs and recovery_fs
        * root_fs: From now on, by default rootfs won't include any proprietary blobs. In practice and at this point in development, this makes calls only half usable because internal DSP volume is quite low, and there's a lingering issue with some distros and URC port settings, which at this point is impossible to set without blobs. Opensource replacements for closed binaries only include "openirscutil" (to handle IPC router security) and "openqti" (modem initialization and QMI passthrough). This allows the modem to work for at least outgoing audio calls and 3G/LTE data
        * recovery_fs: Minimal bootable image to be flashed into the recovery MTD partitions to retrieve logs and make changes to the root image


Next steps:
 1. Check power management. If you have GPS + DATA it gets quite hot
 2. Another cleaning in the device tree and unnecessary kernel drivers would be welcome
 3. Continue development of OpenQTI so it does handle everything it needs to without problems
 
NOTES:
Proprietary recipes
    * qualcomm-proprietary: All the Qualcomm blobs
    * quectel-proprietary: Quectel management server and client with some more libraries
    * proprietary-libraries: Shared libraries between both

All these libraries and binaries have been compiled with an older GLIBC and all of them have been patched to _not complain_ with glibc 2.37, as bundled
with Yocto 3.2 release with _patchelf_.
Opensource recipes:
  * openirscutil: Sets access for all DSP services to a specific user
  * openqti: Initializes the modem, handles audio in calls and can optionally dump all packets passing between rmnet_ctl and smdcntl8