# Paths - Remember to first run the script "initialize_repositories.sh" to download
# both the ARM toolchain and the source code repositories
# Need to fix all this since I'm moving almost everything to the yocto build tree, why make it twice?
CURRENT_PATH:=$(shell pwd)
APPSBOOT_PATH:=$(CURRENT_PATH)/quectel_lk
YOCTO_PATH:=$(CURRENT_PATH)/yocto
# Number of threads to use when compiling LK
NUM_THREADS?=12
# Cross compile
CROSS_COMPILE:=$(CURRENT_PATH)/tools/gcc-arm-none-eabi-7-2017-q4-major/bin/arm-none-eabi-

$(shell mkdir -p target)
all: help
everything: kernel_menuconfig aboot kernel kernel_module rootfs

export ARCH=arm
help:
	@echo "Welcome to the Pinephone Modem SDK"
	@echo "------------------------------------"
	@echo "Before running this makefile, you have to initialize the repositories using"
	@echo "the init.sh script."
	@echo "After you've done that, you can run: "
	@echo "    make aboot : It will build the LK bootloader"
	@echo "    make aboot_signed : It will build the LK bootloader and sign it with Qcom sectools, if available (run make help-sectools)"
	@echo "    make kernel : Will build the kernel and place it in /target"
	@echo "    make rootfs : Will build you a rootfs from Yocto"

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

clean: aboot/clean kernel/clean

aboot/clean:
	rm -rf $(APPSBOOT_PATH)/build-mdm9607
	rm -rf target/appsboot.mbn

yocto/clean:
	rm -rf build/tmp

yocto/cleancache:
	rm -rf build/sstate-cache
