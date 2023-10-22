
# HOW TO BUILD YOUR OWN FIRMWARE
1. Make sure you have these packages preinstalled in your host:
 `gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev pylint xterm python3-subunit mesa-common-dev zstd liblz4-tool gcc-arm-none-eabi`
2. If you plan to make a build for fwupd, make sure you also have these packages preinstalled in your host: `php gcab`
3. Make sure you have at least 50Gb of available space
4. Do at least a quick read of Yocto's Project Quick build doc: http://docs.yoctoproject.org/brief-yoctoprojectqs/index.html
5.	Clone this repository in your computer
6.	Go to the folder where you downloaded your copy and run `./init.sh`
 * The init script should do the following things for you
   - Get the modem's bootloader source
   - Get the ARM toolchain to build the bootloader
   - Get Yocto build source
   - Get the specific layers and dependencies to build it all
   - Initialize yocto and add the bitbake layers to the env
 
7.	Run `make`, without arguments, to see what you can build:
  - `everything`: Build Bootloader, System and Recovery and pack it
  - `aboot`: build the LK bootloader
  - `kernel`: Build the kernel and place a bootable image in target/
  - `root_fs`: Build the kernel and rootfs without proprietary blobs and place both in target/
  - `recovery_fs`: will initialize Yocto’s build environment if it wasn’t already done before, and will build a bootable image that fits into the recovery partition to make debugging easier. I've left two scripts: recoverymount and rootfs mount that mount either of the rootfs partitions into /tmp so you can make modifications to the running image more easily
  - `clean`: Will remove build and temporary directories
  - `target_extract`: Will dump the contents of the generated image to target/dump so you can examine the contents of what you're pushing (you'll need python and python's CRC and LZO modules for it to work - check out [UBIDUMP here](https://github.com/nlitsme/ubidump))
  - `target_clean`: Removes the target directory contents
  - `aboot_clean`: Cleans the LK bootloader build folder along with the generated binary
  - `yocto_clean`: Removes Yocto's temporary folder
  - `yocto_cleancache`: Removes Yocto's sstate-cache in case you need to force a rebuild while working on recipes
