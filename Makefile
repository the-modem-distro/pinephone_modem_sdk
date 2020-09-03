# Paths - Remember to first run the script "initialize_repositories.sh" to download
# both the ARM toolchain and the source code repositories
CURRENT_PATH:=$(shell pwd)
APPSBOOT_PATH:=$(CURRENT_PATH)/quectel_lk
KERNEL_PATH:=$(CURRENT_PATH)/quectel_eg25_kernel
ROOTFS_PATH:=$(CURRENT_PATH)/rootfs
YOCTO_PATH:=$(CURRENT_PATH)/yocto
# Arguments for ubinize
MKUBIFS_ARGS:=-m 2048 -e 126976 -c 4292 -F
UBINIZE_ARGS:=-m 2048 -p 128KiB -s 2048
# Number of threads to use when compiling
NUM_THREADS?=12
# Cross compile
CROSS_COMPILE:=$(CURRENT_PATH)/tools/gcc-arm-none-eabi-7-2017-q4-major/bin/arm-none-eabi-

 # Exported variables for mkbootimg
export KERNEL_CMD_PARAMS="noinitrd ro console=ttyHSL0,115200,n8 androidboot.hardware=qcom ehci-hcd.park=3 msm_rtb.filter=0x37 lpm_levels.sleep_disabled=1 earlycon=msm_hsl_uart,0x78b3000 earlyprintk=msm_hsl_uart,0x78b3000,115200"
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

export TARGET_PREFIX=arm-none-eabi-
CFLAGS=" -Wno-error=maybe-uninitialized -Wno-format-truncation -Wno-discarded-qualifiers \
		 -Wno-misleading-indentation -Wno-int-conversion -finline-functions \
		 -Wno-bool-operation -Wno-unused-label -Wno-unused-variable \
		 -Wno-duplicate-decl-specifier -Wno-uninitialized \
		 -Wno-pointer-compare -Wno-aggressive-loop-optimizations \
		 -Wno-incompatible-pointer-types -Wno-format-overflow \
		 -Wno-format -Wframe-larger-than=1036 -Wno-unused-function \
		 -Wno-comment -Wno-array-bounds -Wno-switch-bool -Wno-int-in-bool-context"
export LDFLAGS="-O1 --hash-style=gnu --as-needed"

export ARCH=arm
help:
	@echo "Welcome to the Pinephone Modem SDK"
	@echo "------------------------------------"
	@echo "Before running this makefile, you have to initialize the repositories using"
	@echo "the init.sh script."
	@echo "After you've done that, you can run: "
	@echo "    make aboot : It will build the LK bootloader"
	@echo "    make aboot_signed : It will build the LK bootloader and sign it with Qcom sectools, if available (run make help-sectools)"
	@echo "    make kernel_menuconfig : Will generate the defconfig to build the kernel"
	@echo "    make kernel : Will build the kernel"
	@echo "    make kernel_module : Will make the kernel modules"
	@echo "    make rootfs : Will build you a rootfs"

help-sectools:
	@echo "QCom Sectools cannot be distributed since they are proprietary"
	@echo "If you manage to find them from some leak, you can extract it to tools/sectools"
	@echo "and if it follows sectools folder structure, you will be able to sign LK images with it"
	@echo "Make sure 'sectools.py' can be reached from 'tools/sectools/sectools.py'"
	@echo "And SECIMAGE.xml is available at 'tools/sectools/config/9607/9607_secimage.xml'"
	@echo "Hope these are enough hints :)"

aboot:
	cd $(APPSBOOT_PATH) ; make -j $(NUM_THREADS) mdm9607 TOOLCHAIN_PREFIX=$(CROSS_COMPILE) SIGNED_KERNEL=0 DEBUG=1 ENABLE_DISPLAY=0 WITH_DEBUG_UART=1 BOARD=9607 SMD_SUPPORT=1 MMC_SDHCI_SUPPORT=1 || exit ; \
	cp build-mdm9607/appsboot.mbn $(CURRENT_PATH)/target

aboot_signed:
	cd $(APPSBOOT_PATH) ; make -j $(NUM_THREADS) mdm9607 TOOLCHAIN_PREFIX=$(CROSS_COMPILE) SIGNED_KERNEL=0 DEBUG=1 ENABLE_DISPLAY=0 WITH_DEBUG_UART=1 BOARD=9607 SMD_SUPPORT=1 MMC_SDHCI_SUPPORT=1 || exit ; \
	mkdir -p tools/signwk
	python tools/sectools/sectools.py secimage -i $(CURRENT_PATH)/quectel_lk/build-mdm9607/appsboot.mbn -o $(CURRENT_PATH)/target/signwk -g appsboot -c $(CURRENT_PATH)/tools/sectools/config/9607/9607_secimage.xml -sa && \
	cp $(CURRENT_PATH)/target/signwk/9607/appsboot/appsboot.mbn $(CURRENT_PATH)/target

kernel:
	cd $(YOCTO_PATH) && \
	source ./oe-init-build-env && bitbake virtual/kernel && \
	cp build/tmp/deploy/images/mdm9607/boot-mdm9607.img $(CURRENT_PATH)/target

rootfs:
	cd $(YOCTO_PATH) && \
	source $(YOCTO_PATH)/oe-init-build-env && \
	bitbake core-image-minimal && \
	cp build/tmp/deploy/images/mdm9607/* $(CURRENT_PATH)/target

clean: aboot/clean kernel/clean rootfs/clean

aboot/clean:
	rm -rf $(APPSBOOT_PATH)/build-mdm9607
	rm -rf target/appsboot.mbn

yocto/clean:
	rm -rf build/tmp

yocto/cleancache:
	rm -rf build/sstate-cache
