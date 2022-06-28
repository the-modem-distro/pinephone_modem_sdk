SHELL := /bin/bash
# Paths - Remember to first run the script "init.sh" to download
CURRENT_PATH:=$(shell pwd)
YOCTO_PATH:=$(CURRENT_PATH)/yocto
# Number of threads to use when compiling LK
NUM_THREADS?=12
# Cross compile
$(shell mkdir -p target)
VERSION?="0.0.0"

all: help
build: target_clean aboot root_fs recovery_fs package
everything: target_clean aboot root_fs recovery_fs package meta_log zip_file cab_file
cabinet_package: meta_log zip_file cab_file
help:
	@echo "Welcome to the Pinephone Modem SDK"
	@echo "------------------------------------"
	@echo "Before running this makefile, you have to initialize the repositories using"
	@echo "the init.sh script."
	@echo "After you've done that, you can run: "
	@echo "    make aboot : It will build the LK bootloader"
	@echo "    make kernel : Will build the kernel and place it in /target"
	@echo "    make root_fs : Will build you a rootfs from Yocto"
	@echo "    make recovery_fs : Will build you a minimal recovery image from Yocto"
	@echo "    make build: Will build the bootloader, kernel, rootfs and recovery image and pack it in a tgz with a flash script."
	@echo "    make everything [VERSION="X.Y.Z"]: Will build the bootloader, kernel, rootfs and recovery image and pack it in a tgz with a flash script and a LVFS compatible cab file"
	@echo "    ---- "
	@echo "    make clean : Removes all the built images and temporary directories from bootloader and yocto"

aboot:
	cp $(CURRENT_PATH)/tools/config/poky/rootfs.conf $(YOCTO_PATH)/build/conf/local.conf
	@cd $(YOCTO_PATH) && source $(YOCTO_PATH)/oe-init-build-env && \
	bitbake virtual/bootloader && \
	cp $(YOCTO_PATH)/build/tmp/deploy/images/mdm9607/appsboot.mbn $(CURRENT_PATH)/target || exit 1

kernel:
	@mv $(YOCTO_PATH)/build/conf/local.conf $(YOCTO_PATH)/build/conf/backup.conf 
	cp $(CURRENT_PATH)/tools/config/poky/rootfs.conf $(YOCTO_PATH)/build/conf/local.conf
	@cd $(YOCTO_PATH) && source $(YOCTO_PATH)/oe-init-build-env && \
	bitbake virtual/kernel && \
	cp $(YOCTO_PATH)/build/tmp/deploy/images/mdm9607/boot-mdm9607.img $(CURRENT_PATH)/target || exit 1

root_fs:
	@rm -rf $(YOCTO_PATH)/build/tmp && \
	cp $(CURRENT_PATH)/tools/config/poky/rootfs.conf $(YOCTO_PATH)/build/conf/local.conf && \
	cd $(YOCTO_PATH) && source $(YOCTO_PATH)/oe-init-build-env && \
	bitbake core-image-minimal && \
	cp $(YOCTO_PATH)/build/tmp/deploy/images/mdm9607/core-image-minimal-mdm9607.ubi $(CURRENT_PATH)/target/rootfs-mdm9607.ubi && \
	cp $(YOCTO_PATH)/build/tmp/deploy/images/mdm9607/boot-mdm9607.img $(CURRENT_PATH)/target
	
recovery_fs:
	@rm -rf $(YOCTO_PATH)/build/tmp
	cp $(CURRENT_PATH)/tools/config/poky/recovery.conf $(YOCTO_PATH)/build/conf/local.conf
	@cd $(YOCTO_PATH) && source $(YOCTO_PATH)/oe-init-build-env && \
	bitbake core-image-minimal && \
	cp $(YOCTO_PATH)/build/tmp/deploy/images/mdm9607/core-image-minimal-mdm9607.ubi $(CURRENT_PATH)/target/recoveryfs.ubi && \
	cp $(YOCTO_PATH)/build/tmp/deploy/images/mdm9607/boot-mdm9607.img $(CURRENT_PATH)/target/recovery.img
	
package: 
	cp $(CURRENT_PATH)/tools/helpers/flashall $(CURRENT_PATH)/target && \
	cd $(CURRENT_PATH)/target && \
	sha512sum appsboot.mbn > shasums.txt && \
	sha512sum boot-mdm9607.img >> shasums.txt && \
	sha512sum recoveryfs.ubi >> shasums.txt && \
	sha512sum rootfs-mdm9607.ubi >> shasums.txt && \
	sha512sum flashall >> shasums.txt && \
	chmod +x flashall && \
	tar czvf package.tar.gz appsboot.mbn boot-mdm9607.img recoveryfs.ubi rootfs-mdm9607.ubi flashall shasums.txt && \
	sha512sum $(CURRENT_PATH)/target/package.tar.gz && \
	rm -rf $(CURRENT_PATH)/licenses/licenses && \
	cp -rf $(CURRENT_PATH)/yocto/build/tmp/deploy/licenses $(CURRENT_PATH)/licenses/

meta_log:
	nano $(CURRENT_PATH)/target/changelog.log 
	#$(CURRENT_PATH)/tools/fwupd/get_commit_history.sh

zip_file: 
	cp $(CURRENT_PATH)/tools/fwupd/partition_nand.xml $(CURRENT_PATH)/target && \
	cd $(CURRENT_PATH)/target && \
	zip package_$(VERSION).zip appsboot.mbn boot-mdm9607.img recovery.img recoveryfs.ubi rootfs-mdm9607.ubi partition_nand.xml

cab_file: 
	@php $(CURRENT_PATH)/tools/fwupd/buildxml.php $(VERSION) $(CURRENT_PATH)/target/changelog.log $(CURRENT_PATH)/tools/fwupd/prototype.xml $(CURRENT_PATH)/target/package_$(VERSION).zip $(CURRENT_PATH)/target && \
	cd $(CURRENT_PATH)/target && \
	gcab --create package_$(VERSION).cab package_$(VERSION).zip package_$(VERSION).metainfo.xml && \
	rm -rf $(CURRENT_PATH)/licenses/licenses && \
	cp -rf $(CURRENT_PATH)/yocto/build/tmp/deploy/licenses $(CURRENT_PATH)/licenses/

target_extract:
	rm -rf $(CURRENT_PATH)/target/dump ; \
	mkdir -p $(CURRENT_PATH)/target/dump/rootfs ; \
	mkdir -p $(CURRENT_PATH)/target/dump/recoveryfs ; \
	python3 $(CURRENT_PATH)/tools/ubidump/ubidump.py $(CURRENT_PATH)/target/rootfs-mdm9607.ubi --savedir $(CURRENT_PATH)/target/dump/rootfs
	python3 $(CURRENT_PATH)/tools/ubidump/ubidump.py $(CURRENT_PATH)/target/recoveryfs.ubi --savedir $(CURRENT_PATH)/target/dump/recoveryfs

clean: aboot_clean target_clean yocto_clean yocto_cleancache
clean_all: aboot_clean target_clean yocto_clean yocto_cleancache yocto_cleandownloads

target_clean:
	rm -rf $(CURRENT_PATH)/target && mkdir -p $(CURRENT_PATH)/target

aboot_clean:
	rm -rf target/appsboot.mbn

yocto_clean:
	rm -rf $(YOCTO_PATH)/build/tmp

yocto_cleancache:
	rm -rf $(YOCTO_PATH)/build/sstate-cache

yocto_cleandownloads:
	rm -rf $(YOCTO_PATH)/build/downloads
