# GOING BACK TO STOCK

If you want to return to stock, I would advise to keep the unlocked bootloader. It will do no harm, and it will give you more recovery functions in case you mess something up or something in the firmware breaks. It is compatible with Quectel's firmware, and the only thing it doesn't do is allowing automatic OTA updates. In case you want to recover the bootloader too, follow the following steps _exactly_
  * Grab the recovery image from my [recovery repo](https://github.com/Biktorgj/quectel_eg25_recovery)
  * Extract it to some folder and move to the update/ folder
  * One by one, flash all the image files, *in this order*:
    - `fastboot flash system mdm9607-sysfs.ubi`
    - `fastboot flash recoveryfs mdm9607-recovery.ubi`
    - `fastboot flash:raw boot mdm9607-boot.img`
    - `fastboot flash:raw recovery mdm9607-boot.img`
    - If all the files have been correctly flashed, *only then*, run `fastboot flash aboot appsboot.mbn`

The reason for this is because if you reinstall the locked bootloader and some of the official files weren't flashed you might enter a reboot loop and you will need to open the phone and short the emergency recovery test points to get into EDL mode and use Qfirehose.