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
      * Signals and custom boot modes via GPIO pins: Pending
* Quectel Kernel:
	* Building: Works
	* Booting: Works
		* USB Working with custom image based in original firmware
		* Modem: Working with custom image based in original firmware
		* Sleep: Partially working with custom image, tends to have issues waking usb back from suspend when >3 hours in sleep mode
* CAF Kernel:
	* Building: Works
	* Booting: Works or not...
		* USB Peripheral mode: usb gadget working, adb supported though it sometimes doesnt completely start
		* Modem: Firmware uploading works, rest is crashing when you attempt to start it
		* Sleep: Some parts of it are working, but ring_in and all that stuff isn't really implemented yet. About 26hours of battery runtime
* Yocto:
	* Two images available: root_fs and recovery_fs
        * root_fs: Includes all Quectel and Qualcomm binary blobs, patched to work with a newer glibc (more or less)
                - Problems with libcrypt in atfwd_daemon. Everything has been compiled with older libraries, path to make it fully work is still WIP
        * recovery_fs: Minimal bootable image to be flashed into the recovery MTD partitions to retrieve logs and make changes to the root image



Next steps:
 1. Debug why PSM sometimes fails to find the modem image (maybe the partition is mounted after PSM has started?)
 2. Debug why USB doesn't always start (but sometimes it does)
 3. Find a way to actually start the atfwd daemon, or find newer libraries which haven't been compiled for a 4 year old distro

NOTES:
Inside meta-qcom there are now 3 proprietary recipes:
    - qualcomm-proprietary: All the Qualcomm blobs
    - quectel-proprietary: Quectel management server and client with some more libraries
    - proprietary-libraries: Shared libraries between both
All these libraries and binaries have been compiled with an older GLIBC and all of them have been patched to _not complain_ with glibc 2.37, as bundled
with Yocto 3.1 release with _patchelf_. The problem with atfwd_daemon is that it also depends on libcrypto.so.1, and if my google fu is correct, it was
depreciated in 2016. Patching it to use libcrypt.so.2 fails miserably, as expected, but best way looking forward would be to recompile with a modern 
toolchain. But license is unknown, so it must be assumed it is proprietary too. The other option is to rebuild it from scratch