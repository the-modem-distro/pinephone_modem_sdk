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
		* Sleep: Partially working with custom image, tends to have issues waking usb back from suspend when >3 in sleep mode
* CAF Kernel:
	* Building: Works
	* Booting: Worksm
		* USB Peripheral mode: Not working with stock, not working in Yocto
		* Modem: Firmware uploading works, rest is unknown
		* Sleep: Unknown
* Yocto:
	* Minimal image: Bootable, drops you to a shell through the debug serial port



Next steps:
 1. Enable USB in the MDM9207
 2. Enable ADB access to the Yocto image
 3. Push all the proprietary files to the image to make an assessment of what works and what not
