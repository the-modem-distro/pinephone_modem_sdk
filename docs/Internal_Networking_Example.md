# Enabling internal networking
This is a WIP and instructions may and will change

## Before you begin
Please enable ADB before beginning, so you can check logs if things go wrong

This will probably work poorly in most cases, as the distros are _not_ ready for a configuration involving two network devices showing up from the modem. Since we're cheating and keeping RMNET available through USB so you're still able to make calls, network manager / ModemManager might assign a higher priority to the USB Ethernet device, so you might have issues with wifi after enabling this.

1. Open the modem chat and send: `enable internal net`
2. Set the correct APN configuration for your carrier:
 - Set the APN name: `set internal network apn APN_NAME`, for example, `set internal network apn ac.vodafone.es`
 - *IF* your provider requires authentication for the APN, use `set internal network user USERNAME`, `set internal network pass PASSWORD` and `set internal network auth method [none|pap|chap|auto]` (for example, `set internal network auth method pap`)

3. Reboot the modem (you can do it from the chat with the command `reboot`)

After rebooting, the modem will send you a message informing if the network connection was correctly turned on. You can enable or disable the network by sending `ifup` and `ifdown` on the modem chat
To disable the setting and go back to the "normal" mode, just send `disable internal net` in the chat, and reboot the modem again
