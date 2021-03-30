# Pinephone Modem SDK

### Collection of tools and scripts to build custom boot images for Quectel EG25G modem.

#### Requirements
Before you can use this make sure your OS has all the packages needed by Yocto

Check them out here: https://docs.yoctoproject.org/singleindex.html

#### Dependencies
This project depends on the following repositories:
* LK - Little Kernel bootloader: https://github.com/Biktorgj/quectel_lk
* Downstream 3.18.140 Kernel based on CAF: https://github.com/Biktorgj/quectel_eg25_kernel
* Forked meta-qcom repository: https://github.com/Biktorgj/meta-qcom
Make sure you have your recoveries ready just in case:
* Quectel EG25 firmware repo: https://github.com/Biktorgj/quectel_eg25_recovery

#### How to use

1.	Clone this repository in your computer
2.	Go to the folder where you downloaded your copy and run ./init.sh
3.	The script will download the LK bootloader, arm toolchain, Yocto 3.2 build environment and all the layers required to biild a bootanle sysyem.
4.	Run make, without arguments, to see what you can build:
    - Make aboot: build the LK bootloader but don’t sign it
    - Make kernel: Build the kernel and place a bootable image in target/
    - Make root_fs: Build the kernel and rootfs without proprietary blobs and place both in target/
    - Make root_fs_full: Build the kernel and rootfs _with_ proprietary blobs and place both in target/
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
   * Bootloader functionality:
      * Boot: OK
      * Flash: OK
      * Debugging: Via debug UART
      * Signals and custom boot modes via GPIO pins: OK
        * Check tools/helpers for scripts to force boot into fastboot or out of it
      * Fastboot auto entering: OK
	* On reset, the bootloader enters into fastboot mode automatically for 2 seconds, and boots normally unless instructed to stay.
	* On reset, run _fastboot oem stay_ to stay in fastboot mode to flash the modem
      * Jump to...
        * Fastboot mode: OK (fastboot reboot-bootloader)
        * DLOAD Mode: NO (fastboot oem reboot-emergency): Pending
        * Recovery mode: OK (fastboot oem reboot-recovery)
   ** If there's a functionality you would like to see in the modem, drop me a message and I'll see what I can do **
* CAF Kernel:
	* Building: Works
	* Booting: Works
		* USB Peripheral mode: WWAN+ADB are working blobfree, WWAN+GPS+ADB with blobs
		* Modem (ADSP): Firmware loading, booting, data and calling works.
    * Audio: Works for me (tm)
    * Ring In: Works correctly when setting the modem to report RING to all interfaces. You can do this by sending the following command to the modem:
      * AT+QURCCFG:"urcport","all"
    * Sleep / Power management: The kernel is always running in low power mode now, this should make the Pinephone consume between 1.12%-1.89% battery on suspend, giving a max runtime on a battery charge of 78 hours / 3 days if there's nothing waking it up, in par with factory firmware with ADB disabled.
    * Non persistent data partition (now there's no way of corrupting anything when killing the modem)
* System images:
	* Three images available: root_fs, root_fs_full and recovery_fs
        * root_fs: Default system image. Includes a minimal root filesystem and one application replacing the entire Qualcomm / Quectel stack. Some functions are not yet functional
        * root_fs_full: Rootfs with all Qualcomm and Quectel blobs. Takes the fun out of it
        * recovery_fs: Minimal bootable image to be flashed into the recovery MTD partitions to retrieve logs and make changes to the root image


Next steps:
 1. Implement the AT commands we actually use (QDAI et al)
 2. Finish up some special commands to reset USB and disable/enable ADB during runtime
 2. Find a way to correctly subscribe to call notifications instead of using ugly hacks
 3. Fix GPS: The port is not binding to the USB side, so no messages are passed through even if GPS is correctly enabled. More investigation is required


##### NOTES:
###### Proprietary recipes
  * qualcomm-proprietary: All the Qualcomm blobs
  * quectel-proprietary: Quectel management server and client with some more libraries
  * proprietary-libraries: Shared libraries between both

All these libraries and binaries have been compiled with an older GLIBC and all of them have been patched to _not complain_ with glibc 2.37, as bundled with Yocto 3.2 release with _patchelf_.

###### Opensource recipes:
  * meta-qcom/recipes-modem/openqti: I've reimplemented everything I had separated in three different utilities into OpenQTI. This takes care of the folllowing at this point:
     - Initialize Kernel's IPC Security settings
     - Initialize DPM to start the required devices for QMI to pass through USB
     - Initialize I2S settings for call audio
     - Initialize the AT service in the DSP and register all commands
     - Act as a proxy between modem's USB QMI and the kernel smdcntl8 node
     - Listen to AT Commands and blindly respond OK to everything not implemented (to make userspace happy)
     - Sniffs on the QMI port to try and detect when there's a CS/VoLTE call and enable/disable audio accordingly

#### About call audio
   My detection method is currently shit. It sniffs out whateves is going between ModemManager/oFono in the host side and the modem itself looking for certain magic packets. Everytime there's a call a packet is sent from the modem to the host indicating the call type and the phone number calling, with some other stuff. These typically look like 0x01 [CALLTYPE] 0x00 0x80 0x09 [0x02/0x06] followed by a bunch of other stuff. I'm investigating on how to actually subscribe to call events to do this nicer, but it seems to work on my limited testing capacity.

   If you want to help out, and it doesn't work for you, you can help by sending me logs. Note **you will/may be leaking phone numbers or other PII info so don't post it somewhere public**.

   If you want to see what's going on in the modem, I've setup some logging functionality in OpenQTI that lets you do that. To enable it, you will need to remount the system partition and modify the initialization script for OpenQTI a bit:
   `adb shell mount -o remount,rw /`
   `adb shell`
   `vi /etc/init.d/init_openqti`
   Add the parameter ` -l` at the end of line #14 so it looks like this:
   `start-stop-daemon -c $USER:$GROUP -S -b -a $DAEMON_PATH$DAEMON -l`
   Save and reboot, and on next boot the log file (/var/log/openqti.log) will be filled with debug messages and the packets being sent and received on each side (usb & modem)
   You can get that file from the modem by simply running
   `adb pull /var/log/openqti.log` 
   on the PinePhone
