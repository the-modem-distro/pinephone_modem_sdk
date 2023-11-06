# Recommended settings
This document describes recommended settings you can apply to your Pinephone or Pinephone Pro to get the best experience out of the modem

## Common
1. If your carrier doesn't provide an alerting tone indication, calls are completely silent until the other party picks up the phone
 - You can enable a local emulation of the alerting tone on the modem, by using the following command (as root): `echo -ne "AT+EN_CAT\r" > /dev/ttyUSB2`

2. If your carrier doesn't provide a valid date and time, the modem will keep looping trying to set the date in the userspace, making all internal generated SMS be sent with an invalid timestamp (2022-01-01).

User @karl implemented a script and a systemd unit that reads the correct date from the Pinephone and sends it via mmcli to the Modem, you can get instructions to set this up [in his blog](https://karl.kashofer.org/pinephone/114)

## Pinephone

1. Audio volume is too low
- Edit the ALSA UCM config file `/usr/share/alsa/ucm2/PinePhone/VoiceCall.conf` and look for the following parameters:
  - `AIF2 DAC Playback Volume`
  - `AIF2 ADC Capture Volume`
- Replace their values with `80%` or `90%` (some people noticed that 90% gets echo at the other side of the call, but doesn't happen to everyone, so feel free to experiment with the most suitable values for you) 

## PinePhone Pro
1. Microphone audio is too loud during phone calls ( distorted audio and lots of background noise from your side )
- Edit the ALSA UCM config file `/usr/share/alsa/ucm2/PinePhonePro/VoiceCall.conf` and look for the following parameters:
  - `IN1 Boost`
- Change the default value from 8 to 3 ( YMMV you may need to go a bit higher or lower, but 8 is way too much in my testing ).

2. If you are using a megi kernel ( archlinux for example ) or a kernel that adds the reset quirk to the modem:
 - Edit `/usr/lib/udev/rules.d/80-modem-eg25.rules`
 - Add a new line after `ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="2c7c", ATTRS{idProduct}=="0125", ATTR{power/persist}="1"` that reads `ATTRS{idVendor}=="2c7c", ATTRS{idProduct}=="0125", ATTR{avoid_reset_quirk}="0"`
