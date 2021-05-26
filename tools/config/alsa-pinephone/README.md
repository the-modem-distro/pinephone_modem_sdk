# CUSTOM AUDIO SETTINGS FOR A CUSTOM FIRMWARE

This folder contains custom ALSA UCM config files for the PinePhone.
If you want to use the 48KHz sampling rate this firmware provides, you'll want to replace the default `VoiceCall.conf` file in your PinePhone for the file named `VoiceCall_48K.conf` in this repo.

Even if you're keeping the default sampling rate, you might want to replace `VoiceCall.conf` with `VoiceCall_8K.conf` in this repo, which will increase the DAC Playback volume to 100% to compensate for the modem not using its voice codec calibration to compensate for low volumes (thanks @kkeijzer for the help!)