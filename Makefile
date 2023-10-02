SHELL := /bin/bash
# Paths - Remember to first run the script "init.sh" to download
CURRENT_PATH:=$(shell pwd)
YOCTO_PATH:=$(CURRENT_PATH)/yocto
APPSBOOT_PATH:=$(CURRENT_PATH)/lk2nd
$(shell mkdir -p target)
$(shell mkdir -p keys)

# Version must be set when using 'make everything'
VERSION?="0.0.0"
# Used when building ramdisk images
KERNEL_COMMAND_LINE="console=ttyHSL0 ro androidboot.hardware=qcom ehci-hcd.park=3 msm_rtb.filter=0x37 lpm_levels.sleep_disabled=1"
MACHINE?=mdm9607
ABOOT_TOOLCHAIN="arm-none-eabi-"

# aboot build settings
ifeq ($(MACHINE), mdm9607)
	ABOOT_PROJECT="mdm9607"
	ABOOT_BUILD_FILENAME=$(APPSBOOT_PATH)/build-mdm9607/appsboot.mbn
	ABOOT_BUILD_OUT=$(CURRENT_PATH)/target/appsboot_mdm9607.mbn
else ifeq ($(MACHINE), mdm9640)
	ABOOT_PROJECT="mdm9640"
	ABOOT_BUILD_FILENAME=$(APPSBOOT_PATH)/build-mdm9640/appsboot.mbn
	ABOOT_BUILD_OUT=$(CURRENT_PATH)/target/appsboot_mdm9640.mbn
endif
# Check if yocto/ source directory exists. If it doesn't, run init script
.PHONY: all
all:
ifneq ($(wildcard $(CURRENT_PATH)/yocto),)
	@echo "If in doubt, use 'make build' to make a build with a bootloader, kernel, rootfs and recovery"
else
	@echo "** The yocto source code doesn't seem to exist. Fetching repositories..."
	@./init.sh
endif
all:help

bootable_ramdisks: rootfs_ram recoveryfs_ram
signed_bootable_ramdisks: rootfs_ram recoveryfs_ram sign_boot_ramdisk sign_recovery_ramdisk
rootfs_ram: root_fs rootfs_ramdisk
recoveryfs_ram: recovery_fs recovery_ramdisk
build: target_clean aboot root_fs recovery_fs package
everything: target_clean aboot root_fs recovery_fs package meta_log zip_file cab_file
everything_signed: target_clean aboot root_fs recovery_fs sign_boot package meta_log zip_file cab_file
cabinet_package: meta_log zip_file cab_file
help:
	@echo "Welcome to the Pinephone Modem SDK"
	@echo "------------------------------------"
	@echo " Available commands:"
	@echo " --> Bootloader"
	@echo "    make aboot : It will build the LK2ND bootloader and place the binary in /target"
	@echo " --> Kernel"
	@echo "    make kernel : Will build the kernel and place it in /target"
	@echo " --> Root Filesystems"
	@echo "    make root_fs : Will build you a kernel + root filesystem in /target"
	@echo "    make recovery_fs : Will build you a kernel + minimal adb-enabled shell in /target"
	@echo " --> Non-flashable builds"
	@echo "    make rootfs_ram : Will make a bootable-only build with all functionality. Boot it with 'fastboot boot boot-rootfs.img' "
	@echo "    make recoveryfs_ram : Will build a bootable-only adb-enabled shell. Boot it with 'fastboot boot boot-recovery.img'"
	@echo "    make bootable_ramdisks : Will build two bootable-only images, one with full modem capabilities and another one only with ADB and utilities"
	@echo "    make signed_bootable_ramdisks : Same as above, but will also sign the files with the certificate stored in keys/"
	@echo " --> Packaged builds"
	@echo "    make build: Will build the bootloader, kernel, rootfs and recovery image and make a 'package.tar.gz'"
	@echo "    make everything VERSION=\"X.Y.Z\": Will build the bootloader, kernel, rootfs and recovery image and pack it in a tgz with a flash script and a LVFS compatible cab file"
	@echo "    make everything_signed VERSION=\"X.Y.Z\": Will build the bootloader, kernel, rootfs and recovery image and pack it in a tgz with a flash script and a LVFS compatible cab file *and* sign it with a certificate stored in keys/ folder"
	@echo "    ---- "
	@echo "    make clean : Removes all the built images and temporary directories from bootloader and yocto"
	@echo "    make sync : Pulls latest changes from the repositories"
	@echo " "

# Sync the repos again
sync:
	@echo "Syncing repositories..."
	@./init.sh

# Build the bootloader
aboot:
	@echo "Building aboot..."
	@cd $(APPSBOOT_PATH) && make -j $(NUM_THREADS) $(MACHINE) TOOLCHAIN_PREFIX=$(ABOOT_TOOLCHAIN) FASTBOOT_TIMER=1 || exit ; \
	cp $(ABOOT_BUILD_FILENAME) $(ABOOT_BUILD_OUT) && \
	cp $(ABOOT_BUILD_FILENAME) $(CURRENT_PATH)/target/appsboot.mbn

# Build the kernel using Bitbake
kernel:
	@echo "Building the kernel..."
	@cp $(CURRENT_PATH)/tools/config/poky/rootfs_${MACHINE}.conf $(YOCTO_PATH)/build/conf/local.conf
	@cd $(YOCTO_PATH) && source $(YOCTO_PATH)/oe-init-build-env && \
	bitbake virtual/kernel && \
	cp $(YOCTO_PATH)/build/tmp/deploy/images/${MACHINE}/boot-${MACHINE}.img $(CURRENT_PATH)/target || exit 1

# Build the kernel + rootfs via Bitbake
root_fs:
	@echo "Building kernel + rootfs..."
	@rm -rf $(YOCTO_PATH)/build/tmp
	cp $(CURRENT_PATH)/tools/config/poky/rootfs_${MACHINE}.conf $(YOCTO_PATH)/build/conf/local.conf && \
	cd $(YOCTO_PATH) && source $(YOCTO_PATH)/oe-init-build-env && \
	bitbake core-image-minimal && \
	cp $(YOCTO_PATH)/build/tmp/deploy/images/${MACHINE}/core-image-minimal-${MACHINE}.ubi $(CURRENT_PATH)/target/rootfs-${MACHINE}.ubi && \
	cp $(YOCTO_PATH)/build/tmp/deploy/images/${MACHINE}/boot-${MACHINE}.img $(CURRENT_PATH)/target

# Build kernel + recovery filesystem via Bitbake
recovery_fs:
	@echo "Building kernel + recoveryfs..."
	@rm -rf $(YOCTO_PATH)/build/tmp
	@cp $(CURRENT_PATH)/tools/config/poky/recovery.conf $(YOCTO_PATH)/build/conf/local.conf
	@cd $(YOCTO_PATH) && source $(YOCTO_PATH)/oe-init-build-env && \
	bitbake core-image-minimal && \
	cp $(YOCTO_PATH)/build/tmp/deploy/images/${MACHINE}/core-image-minimal-${MACHINE}.ubi $(CURRENT_PATH)/target/recoveryfs.ubi && \
	cp $(YOCTO_PATH)/build/tmp/deploy/images/${MACHINE}/boot-${MACHINE}.img $(CURRENT_PATH)/target/recovery.img


rootfs_ramdisk:
	@echo "Building rootfs as a ramdisk only image..."
	@${YOCTO_PATH}/build/tmp/deploy/images/${MACHINE}/mkbootimg --kernel ${YOCTO_PATH}/build/tmp/deploy/images/${MACHINE}/zImage \
              --ramdisk ${YOCTO_PATH}/build/tmp/deploy/images/${MACHINE}/core-image-minimal-${MACHINE}.ext3.gz \
              --output ${CURRENT_PATH}/target/boot-rootfs.img \
              --pagesize 2048 \
              --base 0x80000000 \
              --tags-addr 0x81E00000 \
              --dt ${YOCTO_PATH}/build/tmp/deploy/images/${MACHINE}/dtb.img \
              --cmdline $(KERNEL_COMMAND_LINE)

recovery_ramdisk:
	@echo "Building recoveryfs as a ramdisk only image..."
	@${YOCTO_PATH}/build/tmp/deploy/images/${MACHINE}/mkbootimg --kernel ${YOCTO_PATH}/build/tmp/deploy/images/${MACHINE}/zImage \
              --ramdisk ${YOCTO_PATH}/build/tmp/deploy/images/${MACHINE}/core-image-minimal-${MACHINE}.cpio.gz \
              --output ${CURRENT_PATH}/target/boot-recovery.img \
              --pagesize 2048 \
              --base 0x80000000 \
              --tags-addr 0x81E00000 \
              --dt ${YOCTO_PATH}/build/tmp/deploy/images/${MACHINE}/dtb.img \
              --cmdline $(KERNEL_COMMAND_LINE)
sign_boot_ramdisk:
	@$(CURRENT_PATH)/tools/avbtool/avbtool add_hash_footer --image target/boot-rootfs.img  --partition_name boot --key $(CURRENT_PATH)/keys/private.key --algorith SHA256_RSA4096 --dynamic_partition_size

sign_recovery_ramdisk:
	@$(CURRENT_PATH)/tools/avbtool/avbtool add_hash_footer --image target/boot-recovery.img  --partition_name boot --key $(CURRENT_PATH)/keys/private.key --algorith SHA256_RSA4096 --dynamic_partition_size

sign_boot:
	@$(CURRENT_PATH)/tools/avbtool/avbtool add_hash_footer --image target/boot-${MACHINE}.img  --partition_name boot --key $(CURRENT_PATH)/keys/private.key --algorith SHA256_RSA4096 --dynamic_partition_size

# These aren't working right now
sign_rootfs:
	$(CURRENT_PATH)/tools/avbtool/avbtool add_hash_footer --image target/rootfs-${MACHINE}.ubi  --partition_name system --key $(CURRENT_PATH)/keys/private.key --algorith SHA256_RSA4096 --dynamic_partition_size

sign_recoveryfs:
	$(CURRENT_PATH)/tools/avbtool/avbtool add_hash_footer --image target/recoveryfs.ubi  --partition_name recoveryfs --key $(CURRENT_PATH)/keys/private.key --algorith SHA256_RSA4096 --dynamic_partition_size

package: 
	@echo "Packing the build..."
	@cp $(CURRENT_PATH)/tools/helpers/flashall $(CURRENT_PATH)/target && \
	cd $(CURRENT_PATH)/target && \
	sha512sum appsboot.mbn > shasums.txt && \
	sha512sum boot-${MACHINE}.img >> shasums.txt && \
	sha512sum recoveryfs.ubi >> shasums.txt && \
	sha512sum rootfs-${MACHINE}.ubi >> shasums.txt && \
	sha512sum flashall >> shasums.txt && \
	chmod +x flashall && \
	tar czvf package.tar.gz appsboot.mbn boot-${MACHINE}.img recoveryfs.ubi rootfs-${MACHINE}.ubi flashall shasums.txt && \
	sha512sum $(CURRENT_PATH)/target/package.tar.gz && \
	rm -rf $(CURRENT_PATH)/licenses/licenses && \
	cp -rf $(CURRENT_PATH)/yocto/build/tmp/deploy/licenses $(CURRENT_PATH)/licenses/

meta_log:
	echo "Changelog for $(VERSION)" > $(CURRENT_PATH)/target/changelog.log
	@nano $(CURRENT_PATH)/target/changelog.log 

zip_file: 
	@cp $(CURRENT_PATH)/tools/fwupd/partition_nand.xml $(CURRENT_PATH)/target && \
	cd $(CURRENT_PATH)/target && \
	zip package_$(VERSION).zip appsboot.mbn boot-${MACHINE}.img recovery.img recoveryfs.ubi rootfs-${MACHINE}.ubi partition_nand.xml

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
	python3 $(CURRENT_PATH)/tools/ubidump/ubidump.py $(CURRENT_PATH)/target/rootfs-${MACHINE}.ubi --savedir $(CURRENT_PATH)/target/dump/rootfs
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
