# FLASHING THIS FIRMWARE
If you ever flashed an Android phone, this will be pretty easy:

1. Get required tools: you need adb and fastboot installed in your pinephone
 - Debian/Ubuntu based distros: `apt install android-tools`
 - postmarketOS / Alpine: `apk add android-tools`
 - Arch/Manjaro: `pacman -S android-tools`
2. Grab a copy of the firmware, and, optionally, a recovery firmware (https://github.com/Biktorgj/quectel_eg25_recovery)
3. With the modem active, jump to fastboot mode:
	* If you don't have ADB enabled, enter the following command in `/dev/ttyS2` (minicom -D /dev/ttyS2):
		- `AT+QFASTBOOT`
	* If you already have ADB enabled:
		- `adb reboot bootloader`
  * If you have an old version of this firmware:
    - `adb shell reboot; fastboot oem stay`
4. After a bit, if you run `lsusb` you should see the modem in fastboot mode:
 - `Bus 003 Device 005: ID 18d1:d00d Google Inc. Xiaomi Mi/Redmi 2 (fastboot)`
5. Once in fastboot mode, *first* flash the unlocked bootloader:
   * `fastboot flash aboot appsboot.mbn`
   * After that `fastboot reboot ; fastboot oem stay`
6. After flashing and rebooting to the bootloader the modem will say `FAILED (remote: 'Waiting for orders!')`
7. Now you can flash everything:
  * `fastboot flash boot boot-mdm9607.img`
    * If you get an error flashing the kernel, run fastboot flash:raw : `fastboot flash:raw boot boot-mdm9607.img`
  * `fastboot flash recovery recovery.img`
  * `fastboot flash system rootfs-mdm9607.ubi`
  * `fastboot flash recoveryfs recoveryfs.ubi`
8. After you flashed everything, you can run 'fastboot reboot' and wait for it to come back.
