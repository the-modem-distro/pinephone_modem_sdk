# Pinephone Modem SDK

### Collection of tools and scripts to build custom boot images for Quectel EG25G modem.

#### Requirements
Before you can use this make sure your OS has all the packages needed by Yocto

Check them out here: https://www.yoctoproject.org/docs/2.4.2/yocto-project-qs/yocto-project-qs.html

#### How to use

1.	Clone this repository in your computer
2.	Go to the folder where you downloaded your copy and run ./init.sh
3.	The script will download the LK bootloader, arm toolchain, Yocto 3.1 build environment and all the layers required to biild a bootanle sysyem.
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
      * Jump to...
        * Fastboot mode: OK (fastboot reboot-bootloader)
        * DLOAD Mode: NO (fastboot oem reboot-emergency): Pending
        * Recovery mode: OK (fastboot oem reboot-recovery)
* Quectel Kernel:
	* Building: Works
	* Booting: Works
		* USB Working with custom image based in original firmware
		* Modem: Working with custom image based in original firmware
		* Sleep: Partially working with custom image, tends to have issues waking usb back from suspend when >3 hours in sleep mode
* CAF Kernel:
	* Building: Works
	* Booting: Works
		* USB Peripheral mode: WWAN + GPS + ADB
		* Modem (ADSP): Firmware loading, booting, data and calling work.
    * Audio: Half working. Earpiece works but microphone doesn't seem to. Needs more testing
    * Ring In: RI Signal works, depending on distro it shows the incoming call or not. Needs more testing
		* Sleep: Some parts of it are working, but ring_in and all that stuff isn't really implemented yet. About 26hours of battery runtime with the modem in zombie mode
* Yocto:
	* Two images available: root_fs and recovery_fs
        * root_fs: Includes all Quectel and Qualcomm binary blobs, patched to work with a newer glibc (more or less)
        * recovery_fs: Minimal bootable image to be flashed into the recovery MTD partitions to retrieve logs and make changes to the root image


Next steps:
 1. Audio. Don't really know if the problem is in the modem side or in the distro's userspace, check with other distros
 2. RingIn: Check with latest builds of Mobian, UBPorts and pmOS if Ring In is working and it's just my install
 3. Check power management. If you have GPS + DATA it gets quite hot
 4. Cleanup as many blobs as possible (take out all that isn't really required)

NOTES:
Inside meta-qcom there are 3 proprietary recipes:
    * qualcomm-proprietary: All the Qualcomm blobs
    * quectel-proprietary: Quectel management server and client with some more libraries
    * proprietary-libraries: Shared libraries between both

All these libraries and binaries have been compiled with an older GLIBC and all of them have been patched to _not complain_ with glibc 2.37, as bundled
with Yocto 3.1 release with _patchelf_.
