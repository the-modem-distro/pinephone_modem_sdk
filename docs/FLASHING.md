# FLASHING THIS FIRMWARE

## Using the provided script
If you ever flashed an Android phone, this should be even easier:
1. [Get latest release from Github](https://github.com/Biktorgj/pinephone_modem_sdk/releases/latest)
2. Unpack the `package.tar.gz` file in some directory: `tar xzvf package.tar.gz`
3. Execute the script included in the file: `./flashall`
3b. If the modem doesn't disappear when the script starts, try running the flashall script as root
4. Wait for the modem to come back

## ADSP Versions
If your Pinephone / Pro came with a really old stock firmware, you might need to update it

* [ADSP Version 01.002.01.002](https://github.com/Biktorgj/quectel_eg25_recovery/raw/EG25GGBR07A08M2G_01.002.01.002/update/NON-HLOS.ubi)
* [ADSP Version 01.003.01.003](https://github.com/Biktorgj/quectel_eg25_recovery/raw/EG25GGBR07A08M2G_01.003.01.003/update/NON-HLOS.ubi) 
* [ADSP Version 30.004.30.004](https://github.com/Biktorgj/quectel_eg25_recovery/raw/EG25GGBR07A08M2G_30.004.30.004/update/NON-HLOS.ubi)
#### Flashing it:
1. Open a root terminal and run: `echo -ne "AT+QFASTBOOT\r" > /dev/ttyUSB2` to enter fastboot mode
2. Run `fastboot flash modem NON-HLOS.ubi && fastboot reboot`


## Flashing manually
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

