# QUECTEL EG25-G AT COMMANDS


## This is *incomplete* and a work in progress. Some info here might not be correct

These are all the base commands that appear in Quectel's AT Command Manual (Version 2.0). The specific GNSS/GPS and Application control commands *are not* included here, though they will be added when this list is ready.

- AT+<cmd>=? Checks if the command exists
- AT+<cmd>? Prints the values for a specific command

To connect to the serial terminal with local echo and automatic LF trimming, you can use `sudo picocom --echo --omap ignlf /dev/ttyUSB2`.

Alternatively, you can use mmcli to run a command non-interactively: `sudo mmcli -m any --command='AT+QMBNCFG="list"'`

### Notes:
Handled by can be
 * DSP: Handled by the ADSP firmware with no interaction from the userspace
 * Userspace: Handled only by the userspace
 * Userspace+DSP: Handled by the ADSP first, then notified to the userspace via IPC

Implemented can be
 * Yes: The command is implemented and should be working
 * No: The command is not implemented
 * Dummy: The command blindly responds OK to whatever value you send, but won't do anything
 * WIP: Work in progress

| Command | Description | Handled by | Implemented |
| ------- |:-----------:|:----------:| -----------:|
| +++ | Switch from Data Mode to Command Mode | DSP | Yes |
| A/ | Repeat Previous Command Line | DSP | Yes |
| AT$QCRMCALL | Start or Stop an RmNet Call | DSP | Yes |
| AT&C | Set DCD Function Mode | DSP | Yes |
| AT&D | Set DTR Function Mode | DSP | Yes |
| AT&F | Reset AT Command Settings to Factory Defaults | DSP | Yes |
| AT&V | Display Current Configuration | DSP | Yes |
| AT&W | Store Current Settings to User-defined Profile | DSP | Yes |
| AT+CBC | Battery Charge | DSP | Yes |
| AT+CBST | Select Bearer Service Type | DSP | Yes |
| AT+CCFC | Call Forwarding Number and Conditions Control | DSP | Yes |
| AT+CCHC | Close Logical Channel | DSP | Yes |
| AT+CCHO | Open Logical Channel | DSP | Yes |
| AT+CCLK | Clock | DSP | Yes |
| AT+CCWA | Call Waiting Control | DSP | Yes |
| AT+CEER | Extended Error Report | DSP | Yes |
| AT+CEREG | EPS Network Registration Status | DSP | Yes |
| AT+CFUN | Set UE Functionality |  Userspace+DSP  | Yes (DSP only) |
| AT+CGACT | Activate or Deactivate PDP Context | DSP | Yes |
| AT+CGATT | Attachment or Detachment of PS | DSP | Yes |
| AT+CGCLASS | GPRS Mobile Station Class | DSP | Yes |
| AT+CGCONTRDP | PDP Context Read Dynamic Parameters | DSP | Yes |
| AT+CGDATA | Enter Data State | DSP | Yes |
| AT+CGDCONT | Define PDP Context | DSP | Yes |
| AT+CGEQMIN | UMTS Quality of Service Profile (Minimum Acceptable) | DSP | Yes |
| AT+CGEQREQ | UMTS Quality of Service Profile (Requested) | DSP | Yes |
| AT+CGEREP | Packet Domain Event Reporting | DSP | Yes |
| AT+CGLA | UICC Logical Channel Access | DSP | Yes |
| AT+CGMI | Request Manufacturer Identification | DSP | Yes |
| AT+CGMM | Request MT Model Identification | DSP | Yes |
| AT+CGMR | Request MT Firmware Revision Identification | DSP | Yes |
| AT+CGPADDR | Show PDP Address | DSP | Yes |
| AT+CGQMIN | Quality of Service Profile (Minimum Acceptable) | DSP | Yes |
| AT+CGQREQ | Quality of Service Profile (Requested) | DSP | Yes |
| AT+CGREG | Network Registration Status | DSP | Yes |
| AT+CGSMS | Select Service for MO SMS Messages | DSP | Yes |
| AT+CGSN | Request International Mobile Equipment Identity (IMEI) | DSP | Yes |
| AT+CHLD | Call Related Supplementary Services | DSP | Yes |
| AT+CHUP | Hang up Voice Call | DSP | Yes |
| AT+CIMI | Request International Mobile Subscriber Identity (IMSI) | DSP | Yes |
| AT+CIND | Command of Control Instructions | DSP | Yes |
| AT+CLCC | List Current Calls of ME | DSP | Yes |
| AT+CLCK | Facility Lock | DSP | Yes |
| AT+CLIP | Calling Line Identification Presentation | DSP | Yes |
| AT+CLIR | Calling Line Identification Restriction | DSP | Yes |
| AT+CLVL | Loudspeaker Volume Level Selection | DSP | Yes |
| AT+CMEE | Error Message Format | DSP | Yes |
| AT+CMGD | Delete Message | DSP | Yes |
| AT+CMGF | Message Format | DSP | Yes |
| AT+CMGL | List Message | DSP | Yes |
| AT+CMGR | Read Message | DSP | Yes |
| AT+CMGS | Send Message | DSP | Yes |
| AT+CMGW | Write Message to Memory | DSP | Yes |
| AT+CMMS | More Messages to Send | DSP | Yes |
| AT+CMSS | Send Message from Storage | DSP | Yes |
| AT+CMUT | Mute Control | DSP | Yes |
| AT+CMUX | +CMUX | Userspace  |  Dummy |
| AT+CNMA | New Message Acknowledgement to UE/TE | DSP | Yes |
| AT+CNMI | SMS Event Reporting Configuration | DSP | Yes |
| AT+CNUM | Subscriber Number | DSP | Yes |
| AT+COLP | Connected Line Identification Presentation | DSP | Yes |
| AT+COPN | Read Operator Names | DSP | Yes |
| AT+COPS | Operator Selection | DSP | Yes |
| AT+CPAS | Mobile Equipment Activity Status | DSP | Yes |
| AT+CPBF | Find Phonebook Entries | DSP | Yes |
| AT+CPBR | Read Phonebook Entries | DSP | Yes |
| AT+CPBS | Select Phonebook Memory Storage | DSP | Yes |
| AT+CPBW | Write Phonebook Entry | DSP | Yes |
| AT+CPIN | Enter PIN | DSP | Yes |
| AT+CPMS | Preferred Message Storage | DSP | Yes |
| AT+CPOL | Preferred Operator List | DSP | Yes |
| AT+CPWD | Change Password | DSP | Yes |
| AT+CR | Service Reporting Control | DSP | Yes |
| AT+CRC | Set Cellular Result Codes for Incoming Call Indication | DSP | Yes |
| AT+CREG | Network Registration Status | DSP | Yes |
| AT+CRLP | Select Radio Link Protocol Parameter | DSP | Yes |
| AT+CRSM | Restricted (U)SIM Access | DSP | Yes |
| AT+CSCA | Service Center Address | DSP | Yes |
| AT+CSCB | Select Cell Broadcast Message Types | DSP | Yes |
| AT+CSCS | Select TE Character Set | DSP | Yes |
| AT+CSDH | Show SMS Text Mode Parameters | DSP | Yes |
| AT+CSIM | Generic (U)SIM Access | DSP | Yes |
| AT+CSMP | Set SMS Text Mode Parameters | DSP | Yes |
| AT+CSMS | Select Message Service | DSP | Yes |
| AT+CSQ | Signal Quality Report | DSP | Yes |
| AT+CSSN | Supplementary Service Notifications | DSP | Yes |
| AT+CSTA | Select Type of Address | DSP | Yes |
| AT+CTZR | Time Zone Reporting | DSP | Yes |
| AT+CTZU | Automatic Time Zone Update | DSP | Yes |
| AT+CUSD | Unstructured Supplementary Service Data | DSP | Yes |
| AT+CVHU | Voice Hang up Control | DSP | Yes |
| AT+GMI | Request Manufacturer Identification | DSP | Yes |
| AT+GMM | Request Model Identification | DSP | Yes |
| AT+GMR | Request TA Firmware Revision Identification | DSP | Yes |
| AT+GSN | Request International Mobile Equipment Identity (IMEI) and SN | DSP | Yes |
| AT+ICF | Set TE-TA Control Character Framing | DSP | Yes |
| AT+IFC | Set TE-TA Local Data Flow Control | DSP | Yes |
| AT+IPR | Set TE-TA Fixed Local Rate | Userspace+DSP | Yes (DSP only) |
| AT+QACDBDEL | Delete ACDB File | DSP | Yes |
| AT+QACDBLOAD | Write ACDB File | DSP | Yes |
| AT+QACDBREAD | Read ACDB File | DSP | Yes |
| AT+QADBKEY | +QADBKEY | Userspace  |  Dummy |
| AT+QADC | Read ADC Value | Userspace+DSP | Unknown |
| AT+QADCTEMP | +QADCTEMP | Userspace  |  Dummy |
| AT+QAPRDYIND | Configure to Report Specified URC | Userspace+DSP | Yes(DSP only) |
| AT+QAUDCFG | Query and Configure Audio Tuning Process | Userspace+DSP | Yes(DSP only) |
| AT+QAUDLOOP | Enable/Disable Audio Loop Test | Userspace+DSP | Yes(DSP only) |
| AT+QAUDMOD | Set Audio Mode | Userspace+DSP | Unknown |
| AT+QAUDPLAY | Play Media File | Userspace+DSP | Dummy |
| AT+QAUDPLAYGAIN | Set Audio Playing Gain | DSP | Dummy |
| AT+QAUDRD | Record Media File | Userspace+DSP | Dummy |
| AT+QAUDRDGAIN | Set Audio Recording Gain | DSP | Dummy |
| AT+QAUDSTOP | +QAUDSTOP | Userspace  |  Dummy |
| AT+QAUGDCNT | Auto Save Packet Data Counter | DSP | Yes |
| AT+QBTAVACT | +QBTAVACT | Userspace  |  Dummy |
| AT+QBTAVCON | +QBTAVCON | Userspace  |  Dummy |
| AT+QBTAVREG | +QBTAVREG | Userspace  |  Dummy |
| AT+QBTGATADV | +QBTGATADV | Userspace  |  Dummy |
| AT+QBTGATDA | +QBTGATDA | Userspace  |  Dummy |
| AT+QBTGATDBALC | +QBTGATDBALC | Userspace  |  Dummy |
| AT+QBTGATDBDEALC | +QBTGATDBDEALC | Userspace  |  Dummy |
| AT+QBTGATDISC | +QBTGATDISC | Userspace  |  Dummy |
| AT+QBTGATPER | +QBTGATPER | Userspace  |  Dummy |
| AT+QBTGATREG | +QBTGATREG | Userspace  |  Dummy |
| AT+QBTGATRRSP | +QBTGATRRSP | Userspace  |  Dummy |
| AT+QBTGATSA | +QBTGATSA | Userspace  |  Dummy |
| AT+QBTGATSC | +QBTGATSC | Userspace  |  Dummy |
| AT+QBTGATSD | +QBTGATSD | Userspace  |  Dummy |
| AT+QBTGATSENLE | +QBTGATSENLE | Userspace  |  Dummy |
| AT+QBTGATSIND | +QBTGATSIND | Userspace  |  Dummy |
| AT+QBTGATSNOD | +QBTGATSNOD | Userspace  |  Dummy |
| AT+QBTGATSS | +QBTGATSS | Userspace  |  Dummy |
| AT+QBTGATWRSP | +QBTGATWRSP | Userspace  |  Dummy |
| AT+QBTHFGCON | +QBTHFGCON | Userspace  |  Dummy |
| AT+QBTLEADDR | +QBTLEADDR | Userspace  |  Dummy |
| AT+QBTNAME | +QBTNAME | Userspace  |  Dummy |
| AT+QBTPWR | +QBTPWR | Userspace  |  Dummy |
| AT+QBTSCAN | +QBTSCAN | Userspace  |  Dummy |
| AT+QBTSPPACT | +QBTSPPACT | Userspace  |  Dummy |
| AT+QBTSPPDIC | +QBTSPPDIC | Userspace  |  Dummy |
| AT+QBTSPPWRS | +QBTSPPWRS | Userspace  |  Dummy |
| AT+QCCID | Show ICCID | DSP | Yes |
| AT+QCFG | Extended Configuration Settings  | Userspace+DSP | Yes(DSP only) |
| AT+QCHLDIPMPTY | Hang Up a Call in the VoLTE Conference | DSP | Yes |
| AT+QCMGR | Read Concatenated Messages | DSP | Yes |
| AT+QCMGS | Send Concatenated Messages | DSP | Yes |
| AT+QDAI | Digital Audio Interface Configuration | Userspace+DSP | WIP |
| AT+QDATAFWD | +QDATAFWD | Userspace  |  Dummy |
| AT+QDIAGPORT[1] | Debug UART Configuration | Userspace+DSP | Unknown |
| AT+QECCNUM | Configure Emergency Call Numbers | DSP | Yes |
| AT+QEEC | Set Echo Cancellation Parameters | Userspace+DSP | Yes(DSP only) |
| AT+QENG | Switching on/off Engineering Mode | DSP | Yes |
| AT+QFASTBOOT | +QFASTBOOT | Userspace  |  Yes |
| AT+QFCT | +QFCT | Userspace  |  Dummy |
| AT+QFCTRX | +QFCTRX | Userspace  |  Dummy |
| AT+QFCTTX | +QFCTTX | Userspace  |  Dummy |
| AT+QFOTADL[2] | FOTA Download | Userspace  |  Dummy |
| AT+QFPLMNCFG | FPLMN Configuration | DSP | Yes |
| AT+QFTCMD | +QFTCMD | Userspace  |  Dummy |
| AT+QFUMO | +QFUMO | Userspace  |  Dummy |
| AT+QFUMOCFG | +QFUMOCFG | Userspace  |  Dummy |
| AT+QGDCNT | Packet Data Counter | DSP | Yes |
| AT+QGPSCFG[4] | +QGPSCFG | Userspace  |  Dummy |
| AT+QGMR[7] | Get ADSP firmware version | DSP | Yes |
| AT+QHUP | Hang up Call with a Specific Release Cause | DSP | Yes |
| AT+QIIC[3] | Read and Write Codec via IIC | Userspace+DSP | No |
| AT+QINDCFG | URC Indication Configuration | DSP | Yes |
| AT+QINISTAT | Query Initialization Status of (U)SIM Card | DSP | Yes |
| AT+QLDTMF | Play Local DTMF | Userspace+DSP | Unknown |
| AT+QLINUXCPU | +QLINUXCPU | Userspace  |  Dummy |
| AT+QODM | +QODM | Userspace  |  Dummy |
| AT+QPCMV | +QPCMV | Userspace  |  Dummy |
| AT+QPRINT | +QPRINT | Userspace  |  Dummy |
| AT+QPRTPARA | +QPRTPARA | Userspace  |  Dummy |
| AT+QPSM | +QPSM | Userspace  |  Dummy |
| AT+QPSMCFG | +QPSMCFG | Userspace  |  Dummy |
| AT+QLPING | +QLPING | Userspace  |  Dummy |
| AT+QLPMCFG | +QLPMCFG | Userspace  |  Dummy |
| AT+QLTONE | Play a Local Customized Tone | Userspace+DSP | No? |
| AT+QLTS | Obtain the Latest Time Synchronized Through Network | DSP | Yes |
| AT+QLWWANCID | +QLWWANCID | Userspace  |  Dummy |
| AT+QLWWANDOWN | +QLWWANDOWN | Userspace  |  Dummy |
| AT+QLWWANSTATUS | +QLWWANSTATUS | Userspace  |  Dummy |
| AT+QLWWANUP | +QLWWANUP | Userspace  |  Dummy |
| AT+QLWWANURCCFG | +QLWWANURCCFG | Userspace  |  Dummy |
| AT+QMBNCFG | MBN File Configuration Setting | DSP | Yes |
| AT+QMIC | Set Uplink Gains of Microphone | Userspace+DSP | Yes(DSP only) |
| AT+QNAND | +QNAND | Userspace+DSP |  Yes(DSP only, read) |
| AT+QNETDEVSTATUS | Query RmNet Device Status | DSP | Yes |
| AT+QNETINFO | Query Network Information of RATs | DSP | Yes |
| AT+QNWINFO | Query Network Information | DSP | Yes |
| AT+QNWLOCK="common/lte" | Network Locking Configuration | DSP | Yes |
| AT+QOPS | Band Scan | DSP | Yes |
| AT+QOPSCFG="displayrssi" | Enable/Disable to Display RSSI in LTE | DSP | Yes |
| AT+QOPSCFG="scancontrol" | Configure Bands to be Scanned in 2G/3G/4G | DSP | Yes |
| AT+QPINC | Display PIN Remainder Counter | DSP | Yes |
| AT+QPOWD | Power off | Userspace+DSP | Yes |
| AT+QPSND | Play WAV File | Userspace+DSP | No |
| AT+QRIR | Restore RI Behavior to Inactive | DSP | Yes |
| AT+QRXGAIN | Set Downlink Gains of RX | Userspace+DSP | Yes(DSP only) |
| AT+QRXIIR | +QRXIIR | Userspace  |  Dummy |
| AT+QSCLK[5] | Enable/Disable Low Power Mode | Userspace+DSP | Yes(DSP only) |
| AT+QSDMOUNT | +QSDMOUNT | Userspace  |  Dummy |
| AT+QSGMIICFG | +QSGMIICFG | Userspace  |  Dummy |
| AT+QSIDET | Set the Side Tone Gain in Current Mode | Userspace+DSP | Yes(DSP only) |
| AT+QSIMDET | (U)SIM Card Detection | DSP | Yes |
| AT+QSIMSTAT | (U)SIM Card Insertion Status Report | DSP | Yes |
| AT+QSIMVOL | Fix (U)SIM Card Supply Voltage | DSP | Yes |
| AT+QSPN | Display the Name of Registered Network | DSP | Yes |
| AT+QSUBSYSVER | +QSUBSYSVER | Userspace  |  Dummy |
| AT+QTEMP | +QTEMP | Userspace  |  Dummy |
| AT+QTEMPDBG | +QTEMPDBG | Userspace  |  Dummy |
| AT+QTEMPDBGLVL | +QTEMPDBGLVL | Userspace  |  Dummy |
| AT+QTONEDET | Enable/Disable DTMF Detection | Userspace+DSP | Yes(DSP only) |
| AT+QTTS | +QTTS | Userspace  |  Dummy |
| AT+QTTSETUP | +QTTSETUP | Userspace  |  Dummy |
| AT+QTTSETUP | Set TTS | DSP | No |
| AT+QTXIIR | +QTXIIR | Userspace  |  Dummy |
| AT+QURCCFG | Configure URC Indication Option | DSP | Yes |
| AT+QVERSION | +QVERSION | Userspace  |  Dummy |
| AT+QWAUTH | +QWAUTH | Userspace  |  Dummy |
| AT+QWBCAST | +QWBCAST | Userspace  |  Dummy |
| AT+QWCLICNT | +QWCLICNT | Userspace  |  Dummy |
| AT+QWCLILST | +QWCLILST | Userspace  |  Dummy |
| AT+QWCLIP | +QWCLIP | Userspace  |  Dummy |
| AT+QWCLIRM | +QWCLIRM | Userspace  |  Dummy |
| AT+QWDTMF | Play or Send DTMF Files to Far End | DSP | Yes |
| AT+QWIFI | +QWIFI | Userspace  |  Dummy |
| AT+QWIFICFG | +QWIFICFG | Userspace  |  Dummy |
| AT+QWISO | +QWISO | Userspace  |  Dummy |
| AT+QWMOCH | +QWMOCH | Userspace  |  Dummy |
| AT+QWPARAM | +QWPARAM | Userspace  |  Dummy |
| AT+QWRSTD | +QWRSTD | Userspace  |  Dummy |
| AT+QWSERVER | +QWSERVER | Userspace  |  Dummy |
| AT+QWSETMAC | +QWSETMAC | Userspace  |  Dummy |
| AT+QWSSID | +QWSSID | Userspace  |  Dummy |
| AT+QWSSIDHEX | +QWSSIDHEX | Userspace  |  Dummy |
| AT+QWSTAINFO | +QWSTAINFO | Userspace  |  Dummy |
| AT+QWTTS | Play Text or Send Text To Far End | Userspace+DSP | No |
| AT+QWTOCLI | +QWTOCLI | Userspace  |  Dummy |
| AT+QWTOCLIEN | +QWTOCLIEN | Userspace  |  Dummy |
| AT+QWWAN | +QWWAN | Userspace  |  Dummy |
| AT+VTD | Set Tone Duration | DSP | Yes |
| AT+VTS | DTMF and Tone Generation | DSP | Yes |
| ATA | Answer an Incoming Call | DSP | Yes |
| ATD | Mobile Originated Call to Dial a Number | DSP | Yes |
| ATE | Set Command Echo Mode | DSP | Yes |
| ATH | Disconnect Existing Connection | DSP | Yes |
| ATI | Display MT Identification Information | DSP | Yes |
| ATO | Switch from Command Mode to Data Mode | DSP | Yes |
| ATQ | Set Result Code Presentation Mode | DSP | Yes |
| ATS0 | Set Number of Rings before Automatical Answering | DSP | Yes |
| ATS10 | Set Disconnection Delay after Indicating the Absence of Data Carrier | DSP | Yes |
| ATS12 | Set the Interval for Exiting the Transparent Access Mode Using +++ | DSP | Yes |
| ATS3 | Set Command Line Termination Character | DSP | Yes |
| ATS4 | Set Response Formatting Character | DSP | Yes |
| ATS5 | Set Command Line Editing Character | DSP | Yes |
| ATS6 | Set Pause before Blind Dialing | DSP | Yes |
| ATS7 | Set Time to Wait for Connection Completion | DSP | Yes |
| ATS8 | Set the Time to Wait for Comma Dial Modifier | DSP | Yes |
| ATV | MT Response Format | DSP | Yes |
| ATX | Set CONNECT Result Code Format and Monitor Call Progress | DSP | Yes |
| ATZ | Set all Current Parameters to User-defined Profile | DSP | Yes |
| AT^DSCI | Call Status Indication | DSP | Yes |

## Custom commands in this firmware

| Command | Description | Handled by | Implemented |
| ------- |:-----------:|:----------:| -----------:|
| AT+PWRDN | Shut down the modem | Userspace | Yes |
| AT+ADBON | Enable ADB | Userspace | Yes |
| AT+ADBOFF | Disable ADB | Userspace | Yes |
| AT+RESETUSB | Disable and enable the USB Port | Userspace | Yes |
| AT+REBOOT_REC | Restart the modem in recovery mode | Userspace | Yes |
| AT+EN_PCM8K | (default) Set sampling rate to 8KHz | Userspace | Yes |
| AT+EN_PCM16K | Set sampling rate to 16KHz | Userspace | Yes |
| AT+EN_PCM48K | Set sampling rate to 48KHz | Userspace | Yes |
| AT+EN_USBAUD[6] | USB Gadget driver: enable USB audio | Userspace | Yes |
| AT+DIS_USBAUD[6] | USB Gadget driver: disable USB audio | Userspace | Yes |
| AT+EN_CAT | Enable Custom Alert Tone (local dialing indication generation) | Userspace | Yes |
| AT+DIS_CAT | Disable Custom Alert Tone | Userspace | Yes |
| AT+GETSWREV | Report OpenQTI version | Userspace | Yes |
| AT+GETFWBRANCH | Get firmware bramch (fwupd) | Userspace | Yes |
| AT+DMESG | Dump kernel log via serial | Userspace | Yes |
| AT+OQLOG | Dump OpenQTI log via serial | Userspace | Yes |
| AT+GETADSPVER | Show ADSP firmware version | Userspace | Yes |
[1]: Diag port is hardwired from LK to the userspace by the firmware. If GPIOs are available in your platform it'll just work(tm), disabling it will probably not work though

[2]: FOTA functionality is completely removed in this firmware

[3]: i2c is disabled for the most part in the kernel and userspace support is removed by default. Handling i2c from AT command interface is not supported

[4]: Qualcomm IZAT is removed from userspace. GPS, GNSS and A-GPS work but the modem will be unable to do standalone A-GPS tracking without cooperation from the PinePhone

[5]: Userspace ignores QSCLK config.

[6]: For this to correctly work you'll still have to go through Quectel's USB configuration guide, and it's unknown if it fully works or not. Help would be appreciated

[7]: QGMR has been replaced in this firmware to report the firmware version instead of the ADSP version, so fwupd doesn't need to query different commands depending if you're running stock or this one
