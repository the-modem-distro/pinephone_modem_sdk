# Recommended settings
This document describes recommended settings you can apply to your Pinephone or Pinephone Pro to get the best experience out of the modem

## Common
1. If your carrier doesn't provide an alerting tone indication, calls are completely silent until the other party picks up the phone
 - You can enable a local emulation of the alerting tone on the modem, by using the following command (as root): `echo -ne "AT+EN_CAT\r" > /dev/ttyUSB2`

## Pinephone
1. Frequent disconnects and reconnects (Modem vanishes and reappears a few seconds later during operation or after waking up from suspend)

Sometimes the kernel is too aggressive trying to suspend the USB port when it's actually in use. Disabling runtime suspend for the port usually helps a lot. 
- Edit `/usr/lib/udev/rules.d/80-modem-eg25.rules`
- Look at the first line where it says `ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="2c7c", ATTRS{idProduct}=="0125", ATTR{power/control}="auto"`
- And change it to ON `ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="2c7c", ATTRS{idProduct}=="0125", ATTR{power/control}="on"`

2. Audio volume is too low
- Edit the ALSA UCM config file `/usr/share/alsa/ucm2/PinePhone/VoiceCall.conf` and look for the following parameters:
  - `AIF2 DAC Playback Volume`
  - `AIF2 ADC Capture Volume`
- Replace their values with `80%` or `90%` (some people noticed that 90% gets echo at the other side of the call, but doesn't happen to everyone, so feel free to experiment with the most suitable values for you) 

## PinePhone Pro
1. Stop the modem from disappearing on suspend
 - Edit `/usr/lib/udev/rules.d/80-modem-eg25.rules`
 - Look at the last line: `ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="2c7c", ATTRS{idProduct}=="0125", ATTR{power/persist}="0"`
 - And change persist to 1: `ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="2c7c", ATTRS{idProduct}=="0125", ATTR{power/persist}="1"`
 - Edit `/usr/share/eg25-manager/pine64,pinephone-pro.toml` and make sure `monitor_udev` is set to `false`
