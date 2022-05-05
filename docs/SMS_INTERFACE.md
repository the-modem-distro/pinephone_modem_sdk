# SMS Interface
Interfacing with a device that has no keys and no screen, and only has limited, intermittent support for voice can be tricky.

Using AT commands for everything is also inconvenient, more so if you're on the go without a physical keyboard.

This firmware implements a fake phone number you can interact with, directly from your preferred chat application. From 0.6.4 onwards, the modem will send you a message the first time you flash it if you have a SIM installed.

#### NOTE: You need to have an active SIM for this to work, as ModemManager/oFono won't even try to connect to the modem's Wireless Messaging Service if there's no SIM in the modem

## Commands

### Status and info
- `name`: Show modem's name
- `username`: Show the name used by the modem to talk to you
- `uptime`: Show current uptime for the modem
- `load`: Show modem's load average
- `version`: Returns current firmware and ADSP firmware version
- `usbsuspend`: Returns USB suspend state (a little obvious as if it can answer it means it's active, but sometimes used for debugging)
- `memory`: Get used/free memory
- `get reconnects`: Get the number of times ModemManager/oFono lost connection to the modem and did a 'dirty-reconnect' (didn't do normal release from the modem before disconnecting)
- `net report`: Show advanced network data (**needs to have tracking enabled)

### Power related commands
- `caffeinate`: Prevent USB port suspend from the modem side
- `decaf`: Allow USB port suspend (default state, useful when `caffeinate` was issued)
- `reboot`: Reboots the modem
- `off`: Shuts down the modem entirely (Need to restart eg25-manager or reboot the phone to power it back on)
- `help`: List all available commands

### Logging
- `get history`: (WIP) Get history of commands sent to the modem
- `get log`: (Not recommended for normal use) Dump Openqti's log through the chat
- `get dmesg`: (Not recommended for normal use) Dump Modem's kernel log through the chat

### Statistics
- `net stats`: Get statistics from the RMNET control port (where QMI messages flow between modem and host)
- `gps stats`: Same as before but for the GPS capability (both the NMEA port and QMI based location gathering). Useful if you want to find out if something is using GPS without your knowledge
- `gsm signal`: Gets you information about the current network type and signal level

### Configuration
- `enable adb`: Enable ADB support (resets the USB port for a second)
- `disable adb`: Disable ADB (resets the USB port for a second)
- `enable tracking`: Enables cell data tracking. This keeps data of the connected and neighbour cells
- `disable tracking`: Disables cell data tracking
- `enable persistent logging`: Enables storing logs to `/persist/`
- `disable persistent logging`: Disables persistent storage
- `enable sms logging`: Enables logging of every message sent/received to `openqti.log`
- `disable sms logging`: Disables SMS logging
- `set user name [NEWNAME]`: Tell the modem the name you want it to use when calling you
- `set name [NEWNAME]`: Give the modem a new name

### Utilities
- `call me`: Calls you back right away
- `call me in [SECONDS]`: Modem will call you back in X seconds
- `remind me [at/in] HH[:MM] [OF SOMETHING]`: Use it to set a reminder *Limitations [1]
  - Examples:
    * `remind me at 08:30 Remember to join the meeting` will call you at half past eight and speak to you "Remember to join the meeting"
    * `remind me in 1 do some important thing`: Will call you back in one hour and tell you "do some important thing"
- `wake me up [at/in] HH[:MM]`: Use it to call you back at/in and tell you "It's time to wake up [YOUR NAME]" 
- `list tasks`: Show pending tasks (reminders and wake up calls)
- `delete task [TASK_ID]`: Remove the ID of a pending task
