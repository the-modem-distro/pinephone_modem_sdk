SHELL := /bin/bash
# Paths - Remember to first run the script "initialize_repositories.sh" to download
# both the ARM toolchain and the source code repositories
CURRENT_PATH:=$(shell pwd)
APPSBOOT_PATH:=$(CURRENT_PATH)/quectel_lk
YOCTO_PATH:=$(CURRENT_PATH)/yocto
# Number of threads to use when compiling LK
NUM_THREADS?=12
# Cross compile
CROSS_COMPILE:=$(CURRENT_PATH)/tools/gcc-arm-none-eabi-7-2017-q4-major/bin/arm-none-eabi-
$(shell mkdir -p target)

export ARCH=arm

all: help
everything: aboot root_fs recovery_fs packagewldr

help:
	@echo "Welcome to the Pinephone Modem SDK"
	@echo "------------------------------------"
	@echo "Before running this makefile, you have to initialize the repositories using"
	@echo "the init.sh script."
	@echo "After you've done that, you can run: "
	@echo "    make aboot : It will build the LK bootloader"
	@echo "    make aboot_signed : It will build the LK bootloader and sign it with Qcom sectools, if available (run make help-sectools)"
	@echo "    make kernel : Will build the kernel and place it in /target"
	@echo "    make root_fs : Will build you a rootfs from Yocto"
	@echo "    make recovery_fs : Will build you a minimal recovery image from Yocto"
	@echo "    make everything : Will build the bootloader, kernel, rootfs and recovery image and pack it in a tgz with a flash script "
	@echo "    ---- "
	@echo "    make clean : Removes all the built images and temporary directories from bootloader and yocto"


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
	mv $(YOCTO_PATH)/build/conf/local.conf $(YOCTO_PATH)/build/conf/backup.conf 
	cp $(CURRENT_PATH)/tools/config/poky/rootfs.conf $(YOCTO_PATH)/build/conf/local.conf
	cd $(YOCTO_PATH) && source $(YOCTO_PATH)/oe-init-build-env && \
	bitbake virtual/kernel && \
	cp $(YOCTO_PATH)/build/tmp/deploy/images/mdm9607/boot-mdm9607.img $(CURRENT_PATH)/target || exit 1

root_fs:
	mv $(YOCTO_PATH)/build/conf/local.conf $(YOCTO_PATH)/build/conf/backup.conf 
	rm -rf $(YOCTO_PATH)/build/tmp
	cp $(CURRENT_PATH)/tools/config/poky/rootfs.conf $(YOCTO_PATH)/build/conf/local.conf
	cd $(YOCTO_PATH) && source $(YOCTO_PATH)/oe-init-build-env && \
	bitbake core-image-minimal && \
	cp $(YOCTO_PATH)/build/tmp/deploy/images/mdm9607/core-image-minimal-mdm9607.ubi $(CURRENT_PATH)/target/rootfs-mdm9607.ubi && \
	cp $(YOCTO_PATH)/build/tmp/deploy/images/mdm9607/boot-mdm9607.img $(CURRENT_PATH)/target
	rm $(YOCTO_PATH)/build/conf/local.conf
	mv $(YOCTO_PATH)/build/conf/backup.conf $(YOCTO_PATH)/build/conf/local.conf 

recovery_fs:
	mv $(YOCTO_PATH)/build/conf/local.conf $(YOCTO_PATH)/build/conf/backup.conf 
	rm -rf $(YOCTO_PATH)/build/tmp
	cp $(CURRENT_PATH)/tools/config/poky/recovery.conf $(YOCTO_PATH)/build/conf/local.conf
	cd $(YOCTO_PATH) && source $(YOCTO_PATH)/oe-init-build-env && \
	bitbake core-image-minimal && \
	cp $(YOCTO_PATH)/build/tmp/deploy/images/mdm9607/core-image-minimal-mdm9607.ubi $(CURRENT_PATH)/target/recoveryfs.ubi && \
	cp $(YOCTO_PATH)/build/tmp/deploy/images/mdm9607/boot-mdm9607.img $(CURRENT_PATH)/target/recovery.img
	rm $(YOCTO_PATH)/build/conf/local.conf
	mv $(YOCTO_PATH)/build/conf/backup.conf $(YOCTO_PATH)/build/conf/local.conf 

package: 
	cp $(CURRENT_PATH)/tools/helpers/flashall $(CURRENT_PATH)/target && \
	cd $(CURRENT_PATH)/target && \
	chmod +x flashall && \
	tar czvf package.tar.gz appsboot.mbn boot-mdm9607.img recovery.img recoveryfs.ubi rootfs-mdm9607.ubi

target_extract:
	rm -rf $(CURRENT_PATH)/target/dump ; \
	mkdir -p $(CURRENT_PATH)/target/dump/rootfs ; \
	mkdir -p $(CURRENT_PATH)/target/dump/recoveryfs ; \
	python3 $(CURRENT_PATH)/tools/ubidump/ubidump.py $(CURRENT_PATH)/target/rootfs-mdm9607.ubi --savedir $(CURRENT_PATH)/target/dump/rootfs
	python3 $(CURRENT_PATH)/tools/ubidump/ubidump.py $(CURRENT_PATH)/target/recoveryfs.ubi --savedir $(CURRENT_PATH)/target/dump/recoveryfs
	
clean: aboot_clean target_clean yocto_clean yocto_cleancache
clean_all: aboot_clean target_clean yocto_clean yocto_cleancache yocto_cleandownloads

target_clean:
	rm -rf $(CURRENT_PATH)/target && mkdir -p $(CURRENT_PATH)/target/dump

aboot_clean:
	rm -rf $(APPSBOOT_PATH)/build-mdm9607
	rm -rf target/appsboot.mbn

yocto_clean:
	rm -rf $(YOCTO_PATH)/build/tmp

yocto_cleancache:
	rm -rf $(YOCTO_PATH)/build/sstate-cache

yocto_cleandownloads:
	rm -rf $(YOCTO_PATH)/build/downloads
