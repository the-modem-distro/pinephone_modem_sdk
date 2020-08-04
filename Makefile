# Paths - Remember to first run the script "initialize_repositories.sh" to download
# both the ARM toolchain and the source code repositories
CURRENT_PATH:=$(shell pwd)
APPSBOOT_PATH:=$(CURRENT_PATH)/quectel_lk
KERNEL_PATH:=$(CURRENT_PATH)/quectel_eg25_kernel
ROOTFS_PATH:=$(CURRENT_PATH)/rootfs
# Arguments for ubinize
MKUBIFS_ARGS:=-m 2048 -e 126976 -c 4292 -F
UBINIZE_ARGS:=-m 2048 -p 128KiB -s 2048
# Number of threads to use when compiling
NUM_THREADS?=12
# Cross compile
CROSS_COMPILE:=$(CURRENT_PATH)/tools/gcc-arm-none-eabi-7-2017-q4-major/bin/arm-none-eabi-
# Exported variables for mkbootimg
export KERNEL_CMD_PARAMS="noinitrd ro console=ttyHSL0,115200,n8 androidboot.hardware=qcom ehci-hcd.park=3 msm_rtb.filter=0x37 lpm_levels.sleep_disabled=1 earlycon=msm_hsl_uart,0x78b0000"
export PAGE_SIZE=2048
export KERNEL_BASE=0x80000000
export RAMDISK_OFFSET=0x0
export KERNEL_TAGS_OFFSET=0x81E00000

$(shell mkdir -p target)

all: help
everything: kernel_menuconfig aboot kernel kernel_module rootfs
# Quectel exports for their makefiles
export QUECTEL_PROJECT_NAME=EC25E
export QUECTEL_PROJECT_REV=EC25CEVAR05A05T4G_OCPU

help:
	@echo "Welcome to the Pinephone Modem's SDK"
	@echo "Before running this makefile, you have to initialize the repositories using"
	@echo "the initialize_repositories.sh script."
	@echo "After you've done that, you can run: "
	@echo "    make aboot : It will build the LK bootloader"
	@echo "    make kernel_menuconfig : Will generate the defconfig to build the kernel"
	@echo "    make kernel : Will build the kernel"
	@echo "    make kernel_module : Will make the kernel modules"
	@echo "    make rootfs : Will build you a rootfs"
	

aboot:
	cd $(APPSBOOT_PATH) ; make -j $(NUM_THREADS) mdm9607 TOOLCHAIN_PREFIX=$(CROSS_COMPILE) SIGNED_KERNEL=0 DEBUG=1 ENABLE_DISPLAY=0 WITH_DEBUG_UART=1 BOARD=9607 SMD_SUPPORT=1 MMC_SDHCI_SUPPORT=0 || exit ; \
	cp build-mdm9607/appsboot.mbn $(CURRENT_PATH)/target

kernel_menuconfig:
	cd $(KERNEL_PATH) ; make ARCH=arm mdm9607-perf_defconfig menuconfig O=build
	cp $(KERNEL_PATH)/build/.config $(KERNEL_PATH)/arch/arm/configs/mdm9607-perf_defconfig

kernel:
	cd $(KERNEL_PATH) ; [ ! -f build/.config ] && echo -e "\033[31m.config doesnt exist, Please run \"make kernel_menuconfig\" \033[0m" && exit 1 ;\
	make ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) -j $(NUM_THREADS) O=build || exit ; \
	cp build/arch/arm/boot/zImage build/arch/arm/boot/dts/qcom/mdm9607-mtp.dtb $(CURRENT_PATH)/tools/quectel_mkboot/
	cd $(CURRENT_PATH)/tools/quectel_mkboot ; chmod +x * ;  \
        ./quec_mkboot dtb2img mdm9607-mtp.dtb zImage   ; \
	cp ./target/* $(CURRENT_PATH)/target

kernel_modules:
	cd $(KERNEL_PATH) ; [ ! -f build/.config ] && echo -e "\033[31m.config doesnt exist, Please run \"make kernel_menuconfig\" \033[0m" && exit 1; \
	make modules ARCH=arm CROSS_COMPILE=$(TOOLCHAIN_PATH) -j $(NUM_THREADS) O=build || exit ; \
	make ARCH=arm CROSS_COMPILE=arm-oe-linux-gnueabi- INSTALL_MOD_STRIP=1 O=$(KERNEL_PATH)/build INSTALL_MOD_PATH=$(ROOTFS_DIR)/usr  modules_install || exit
	echo -e "\033[32m# Kernel modules have been built, now regenerate the sysfs image via make rootfs #\033[0m"

rootfs:
	cd $(CURRENT_PATH) ; chmod +x ./ql-ol-extsdk/tools/quectel_ubi/* ; \
	fakeroot $(CURRENT_PATH)/tools/quectel_ubi/mkfs.ubifs -r ql-ol-rootfs -o mdm9607-perf-sysfs.ubifs ${MKUBIFS_ARGS}
	./ql-ol-extsdk/tools/quectel_ubi/ubinize  -o $(sysfs-ubi-fname) ${UBINIZE_ARGS} $(CURRENT_PATH)/quectel_ubi/$(ubicfg-fname)
	rm -rf mdm9607*.ubifs
	mv $(sysfs-ubi-fname) target/



$(usrdata):
	cd $(CURRENT_PATH) ; chmod +x ./ql-ol-extsdk/tools/quectel_ubi/* ; $(FAKEROOT) ./ql-ol-extsdk/tools/quectel_ubi/mkfs.ubifs -r ql-ol-usrdata -o usrdata.ubifs ${MKUBIFS_ARGS} ;	\
	./ql-ol-extsdk/tools/quectel_ubi/ubinize  -o usrdata.ubi ${UBINIZE_ARGS} ql-ol-extsdk/tools/quectel_ubi/ubinize_usrdata.cfg ; \
	rm -rf usrdata.ubifs
	mv usrdata.ubi target/


clean: aboot/clean kernel/clean rootfs/clean

aboot/clean:
	rm -rf $(ABOOT_DIR)/build-mdm9607
	rm -rf target/appsboot.mbn

kernel/clean:
	cd $(KERNEL_PATH) ; make clean O=build || exit
	rm -rf target/*.img

kernel/distclean:
	cd $(KERNEL_PATH) ; make distclean O=build || exit
	rm -rf target/*.img

rootfs/clean:
	rm -rf target/mdm9607-perf-sysfs.ubi*
