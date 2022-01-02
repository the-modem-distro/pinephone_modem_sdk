# FLASHING THIS FIRMWARE

## Using the sample script
If you ever flashed an Android phone, this will be pretty easy. In essence, the only thing you need to do is reboot the modem into fastboot mode and flash everything. You have a [sample script you can use here](https://github.com/Biktorgj/pinephone_modem_sdk/blob/hardknott/tools/helpers/flashall). Install fastboot and adb,  place the script in the same folder as the unpacked firmware and run it as root. If the modem was booted, it will reboot it and flash the entire firmware. This script doesn't check for errors though, so keep an eye on the screen in case something fails.

## Manually flashing
1. Get required tools: you need adb and fastboot installed in your pinephone
 - Debian/Ubuntu based distros: 
  - `apt install android-tools-adb android-tools-fastboot`
  - OR `apt install adb fastboot`
 - postmarketOS / Alpine: `apk add android-tools`
 - Arch/Manjaro: `pacman -S android-tools`
2. Grab a copy of the firmware, and, optionally, a recovery firmware (https://github.com/Biktorgj/quectel_eg25_recovery)
3. With the modem active, jump to fastboot mode:
	* As *root*, tell the modem to shutdown and enter fastboot mode: 
    - `echo -ne "AT+QFASTBOOT\r" > /dev/ttyUSB2`
	  * If the AT interface is not available, you can also do it from ADB:
		  - If running stock: `adb reboot bootloader`
      - If already running this firmware: `adb shell reboot; fastboot oem stay`
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
8. After you flashed everything, you can run 'fastboot reboot' and wait for it to come back (you might have to run `fastboot reboot` twice to clear Quectel's bootloader flags).

