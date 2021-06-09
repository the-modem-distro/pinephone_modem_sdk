# QUECTEL EG25-G AT COMMANDS


## This is currently just a placeholder, I need to check all commands one by one and fix all the descriptions, and there might be missing commands (there are quite a lot of them)

These are all the base commands that appear in Quectel's AT Command Manual (Version 2.0). The specific GNSS/GPS and Application control commands *are not* included here, though they will be added when this list is ready.

- AT+<cmd>=? Checks if the command exists
- AT+<cmd>? Prints the values for a specific command

### Notes:
Handled by can be
 * DSP: Handled by the ADSP firmware with no interaction from the userspace
 * Userspace: Handled only by the userspace
 * Both: Handled by the ADSP first, then notified to the userspace via IPC

Implemented can be
 * Yes: The command is implemented and should be working
 * No: The command is not implemented
 * Dummy: The command blindly responds OK to whatever value you send, but won't do anything

| Command | Description | Handled by | Implemented |
| ------- |:-----------:|:----------:| -----------:|
| AT$QCRMCALL | AT$QCRMCALL Start or Stop an RmNet Call | DSP  |  Yes |
| AT&F | AT&F  289 | DSP  |  Yes |
| AT&V | AT&V View Current Settings in User-defined Profile  | DSP  |  Yes |
| AT&W | AT&W Store Current Settings to User-defined Profile | DSP  |  Yes |
| AT+CBC | AT+CBC Battery Charge | DSP  |  Yes |
| AT+CBST | AT+CBST  125 | DSP  |  Yes |
| AT+CCFC | AT+CCFC Call Forwarding Number and Conditions Control | DSP  |  Yes |
| AT+CCHC | AT+CCHC (Chapter | DSP  |  Yes |
| AT+CCHO | AT+CCHO Open Logical Channel | DSP  |  Yes |
| AT+CCLK | AT+CCLK Clock | DSP  |  Yes |
| AT+CCWA | AT+CCWA Call Waiting Control | DSP  |  Yes |
| AT+CCWA=1,1 | AT+CCWA=1,1 | DSP  |  Yes |
| AT+CEER | AT+CEER  304 | DSP  |  Yes |
| AT+CEREG | AT+CEREG | DSP  |  Yes |
| AT+CFUN | AT+CFUN Set UE Functionality  32 | DSP  |  Yes |
| AT+CGACT | AT+CGACT | DSP  |  Yes |
| AT+CGATT | AT+CGATT | DSP  |  Yes |
| AT+CGCLASS | AT+CGCLASS | DSP  |  Yes |
| AT+CGCONTRDP | AT+CGCONTRDP PDP Context Read Dynamic Parameters | DSP  |  Yes |
| AT+CGDATA | AT+CGDATA Enter Data State | DSP  |  Yes |
| AT+CGDCONT | AT+CGDCONT | DSP  |  Yes |
| AT+CGEQMIN | AT+CGEQMIN | DSP  |  Yes |
| AT+CGEQREQ | AT+CGEQREQ UMTS Quality of Service Profile (Requested) | DSP  |  Yes |
| AT+CGEREP | AT+CGEREP Packet Domain Event Reporting | DSP  |  Yes |
| AT+CGLA | AT+CGLA UICC Logical Channel Access | DSP  |  Yes |
| AT+CGMI | AT+CGMI Request Manufacturer Identification | DSP  |  Yes |
| AT+CGMM | AT+CGMM in Chapter 26 | DSP  |  Yes |
| AT+CGPADDR | AT+CGPADDR | DSP  |  Yes |
| AT+CGQMIN | AT+CGQMIN | DSP  |  Yes |
| AT+CGQREQ | AT+CGQREQ Quality of Service Profile (Requested) | DSP  |  Yes |
| AT+CGREG | AT+CGREG Network Registration Status | DSP  |  Yes |
| AT+CGSMS | AT+CGSMS | DSP  |  Yes |
| AT+CGSN | AT+CGSN (Chapter 29) | DSP  |  Yes |
| AT+CHLD | AT+CHLD Call Related Supplementary Services | DSP  |  Yes |
| AT+CHUP | AT+CHUP Hang up Voice Call | DSP  |  Yes |
| AT+CLCC | AT+CLCC AT+QHUP will terminate the call identified by the given call | DSP  |  Yes |
| AT+CLCK | AT+CLCK Facility Lock | DSP  |  Yes |
| AT+CLIP | AT+CLIP Calling Line Identification Presentation | DSP  |  Yes |
| AT+CLVL | AT+CLVL Loudspeaker Volume Level Selection | DSP  |  Yes |
| AT+CMEE | AT+CMEE Error Message Format | DSP  |  Yes |
| AT+CMGF | AT+CMGF=0) | DSP  |  Yes |
| AT+CMGL | AT+CMGL List Message | DSP  |  Yes |
| AT+CMGR | AT+CMGR, except that the message to be read is a segment of | DSP  |  Yes |
| AT+CMGS | AT+CMGS Write Command | DSP  |  Yes |
| AT+CMGW | AT+CMGW Write Message to Memory | DSP  |  Yes |
| AT+CMSS | AT+CMSS Send Message from Storage | DSP  |  Yes |
| AT+CMUT | AT+CMUT Mute Control | DSP  |  Yes |
| AT+CNMA | AT+CNMA New Message Acknowledgement to UE/TE | DSP  |  Yes |
| AT+CNMI | AT+CNMI to 0 | DSP  |  Yes |
| AT+CNMI) | AT+CNMI) | DSP  |  Yes |
| AT+COLP | AT+COLP Connected Line Identification Presentation | DSP  |  Yes |
| AT+COPN | AT+COPN Read Operator Names | DSP  |  Yes |
| AT+COPS) | AT+COPS) | DSP  |  Yes |
| AT+CPBF | AT+CPBF Find Phonebook Entries | DSP  |  Yes |
| AT+CPBR | AT+CPBR Read Phonebook Entries | DSP  |  Yes |
| AT+CPBS | AT+CPBS If <index2> is left out, only location <index1> is | DSP  |  Yes |
| AT+CPBW | AT+CPBW may not be applicable to this | DSP  |  Yes |
| AT+CPMS | AT+CPMS) setting, and the value is: | DSP  |  Yes |
| AT+CPOL | AT+CPOL Preferred Operator List | DSP  |  Yes |
| AT+CR | AT+CR Service Reporting Control | DSP  |  Yes |
| AT+CRC | AT+CRC Set Cellular Result Codes for Incoming Call Indication  129 | DSP  |  Yes |
| AT+CREG | AT+CREG Network Registration Status | DSP  |  Yes |
| AT+CRLP | AT+CRLP Select Radio Link Protocol Parameter | DSP  |  Yes |
| AT+CRSM | AT+CRSM Restricted (U)SIM Access | DSP  |  Yes |
| AT+CSCA | AT+CSCA Service Center Address | DSP  |  Yes |
| AT+CSCB | AT+CSCB), and the value is: | DSP  |  Yes |
| AT+CSCS | AT+CSCS Select TE Character Set | DSP  |  Yes |
| AT+CSMP | AT+CSMP Set SMS Text Mode Parameters | DSP  |  Yes |
| AT+CSMS | AT+CSMS Select Message Service | DSP  |  Yes |
| AT+CSQ | AT+CSQ so as to ensure that any network access required for the preceding | DSP  |  Yes |
| AT+CSSN | AT+CSSN=1 | DSP  |  Yes |
| AT+CSTA | AT+CSTA Select Type of Address | DSP  |  Yes |
| AT+CTZR | AT+CTZR Time Zone Reporting | DSP  |  Yes |
| AT+CTZU | AT+CTZU, AT+QDAI, AT+QEEC, | DSP  |  Yes |
| AT+CUSD | AT+CUSD Unstructured Supplementary Service Data | DSP  |  Yes |
| AT+GSN | AT+GSN (Chapter 28) | DSP  |  Yes |
| AT+ICF | AT+ICF Set TE-TA Control Character Framing | DSP  |  Yes |
| AT+IPR | AT+IPR Set TE-TA Fixed Local Rate | DSP  |  Yes |
| AT+QACDBDEL | AT+QACDBDEL Delete ACDB File | DSP  |  Yes |
| AT+QACDBLOAD | AT+QACDBLOAD | DSP  |  Yes |
| AT+QACDBREAD | AT+QACDBREAD Read ACDB File | DSP  |  Yes |
| AT+QADC | AT+QADC Read ADC Value | DSP  |  Yes |
| AT+QAPRDYIND | AT+QAPRDYIND | DSP  |  Yes |
| AT+QAUDCFG | AT+QAUDCFG | DSP  |  Yes |
| AT+QAUDLOOP | AT+QAUDLOOP Enable/Disable Audio Loop Test | DSP  |  Yes |
| AT+QAUDMOD | AT+QAUDMOD | DSP  |  Yes |
| AT+QAUDPLAY | AT+QAUDPLAY Play Media File | DSP  |  Yes |
| AT+QAUDPLAYGAIN | AT+QAUDPLAYGAIN | DSP  |  Yes |
| AT+QAUDRD | AT+QAUDRD Record Media File | DSP  |  Yes |
| AT+QAUDRD, | AT+QAUDRD, AT+QPSND, | DSP  |  Yes |
| AT+QAUDRDGAIN | AT+QAUDRDGAIN | DSP  |  Yes |
| AT+QAUGDCNT | AT+QAUGDCNT | DSP  |  Yes |
| AT+QCCID | AT+QCCID | DSP  |  Yes |
| AT+QCFG | AT+QCFG Please refer to AT+QCFG="urc/ri/ring", | DSP  |  Yes |
| AT+QCHLDIPMPTY | AT+QCHLDIPMPTY (Chapter 722) | DSP  |  Yes |
| AT+QCMGR | AT+QCMGR | DSP  |  Yes |
| AT+QCMGS | AT+QCMGS It is possible that UE receives | DSP  |  Yes |
| AT+QDAI | AT+QDAI Digital Audio Interface Configuration | DSP  |  Yes |
| AT+QDIAGPORT | AT+QDIAGPORT (Chapter | DSP  |  Yes |
| AT+QECCNUM | AT+QECCNUM Configure Emergency Call Numbers | DSP  |  Yes |
| AT+QEEC | AT+QEEC Set Echo Cancellation Parameters  235 | DSP  |  Yes |
| AT+QENG | AT+QENG (Chapter 611–617) | DSP  |  Yes |
| AT+QFPLMNCFG | AT+QFPLMNCFG | DSP  |  Yes |
| AT+QGDCNT | AT+QGDCNT | DSP  |  Yes |
| AT+QHUP | AT+QHUP Hang up Call with a Specific Release Cause | DSP  |  Yes |
| AT+QIIC | AT+QIIC Read and Write Codec via IIC | DSP  |  Yes |
| AT+QINDCFG | AT+QINDCFG | DSP  |  Yes |
| AT+QINISTAT | AT+QINISTAT | DSP  |  Yes |
| AT+QISEND | AT+QISEND | DSP  |  Yes |
| AT+QLDTMF | AT+QLDTMF | DSP  |  Yes |
| AT+QLTONE | AT+QLTONE Play a Local Customized Tone | DSP  |  Yes |
| AT+QMBNCFG | AT+QMBNCFG MBN File Configuration Setting | DSP  |  Yes |
| AT+QMIC | AT+QMIC Set Uplink Gains of Microphone  237 | DSP  |  Yes |
| AT+QNETDEVSTATUS | AT+QNETDEVSTATUS | DSP  |  Yes |
| AT+QNETINFO | AT+QNETINFO Query Network Information of RATs | DSP  |  Yes |
| AT+QNWINFO | AT+QNWINFO | DSP  |  Yes |
| AT+QNWLOCK| AT+QNWLOCK="common/lte" | DSP  |  Yes |
| AT+QOPS | AT+QOPS Band Scan | DSP  |  Yes |
| AT+QOPSCFG | AT+QOPSCFG="displayrssi" | DSP  |  Yes |
| AT+QPINC | AT+QPINC Display PIN Remainder Counter | DSP  |  Yes |
| AT+QPOWD | AT+QPOWD | DSP  |  Yes |
| AT+QPSND | AT+QPSND | DSP  |  Yes |
| AT+QRIR | AT+QRIR Restore RI Behavior to Inactive | DSP  |  Yes |
| AT+QRXGAIN | AT+QRXGAIN Set Downlink Gains of RX | DSP  |  Yes |
| AT+QSCLK | AT+QSCLK | DSP  |  Yes |
| AT+QSIDET | AT+QSIDET | DSP  |  Yes |
| AT+QSIMDET | AT+QSIMDET | DSP  |  Yes |
| AT+QSIMSTAT | AT+QSIMSTAT (U)SIM Card Insertion Status Report | DSP  |  Yes |
| AT+QSIMVOL | AT+QSIMVOL Fix (U)SIM Card Supply Voltage | DSP  |  Yes |
| AT+QSPN | AT+QSPN Display the Name of Registered Network | DSP  |  Yes |
| AT+QTONEDET | AT+QTONEDET | DSP  |  Yes |
| AT+QTTS | AT+QTTS Play Text | DSP  |  Yes |
| AT+QTTSETUP | AT+QTTSETUP Set TTS | DSP  |  Yes |
| AT+QURCCFG | AT+QURCCFG (Chapter 225) | DSP  |  Yes |
| AT+QWDTMF | AT+QWDTMF | DSP  |  Yes |
| AT+QWTTS | AT+QWTTS Play Text or Send Text To Far End | DSP  |  Yes |
| AT+VTD | AT+VTD Set Tone Duration 231 | DSP  |  Yes |
| AT+VTS | AT+VTS DTMF and Tone Generation | DSP  |  Yes |
| AT/+QLTS/+QSPN/ | AT/+QLTS/+QSPN/ | DSP  |  Yes |
| ATA | ATA Answer an Incoming Call | DSP  |  Yes |
| ATD | ATD Mobile Originated Call to Dial a Number | DSP  |  Yes |
| ATFWD | ATFWD READY will be | DSP  |  Yes |
| ATH | ATH can be used to disconnect the voice call | DSP  |  Yes |
| ATO | ATO Switch from Command Mode to Data Mode | DSP  |  Yes |
| ATQ | ATQ Set Result Code Presentation Mode  26 | DSP  |  Yes |
| ATS10 | ATS10 Set Disconnection Delay after Indicating the Absence of Data Carrier  122 | DSP  |  Yes |
| ATS3 | ATS3 Set Command Line Termination Character  29 | DSP  |  Yes |
| ATS4 | ATS4 Set Response Formatting Character  30 | DSP  |  Yes |
| ATS5 | ATS5 Set Command Line Editing Character  31 | DSP  |  Yes |
| ATS7 | ATS7 Set Time to Wait for Connection Completion  121 | DSP  |  Yes |
| ATS8 | ATS8 Set the Time to Wait for Comma Dial Modifier  121 | DSP  |  Yes |
| ATT | ATT Adds or deletes attachments for an Email | DSP  |  Yes |
| ATV | ATV MT Response Format  26 | DSP  |  Yes |
| ATX | ATX Set CONNECT Result Code Format and Monitor Call Progress  31 | DSP  |  Yes |
| ATZ | ATZ Set all Current Parameters to User-defined Profile  25 | DSP  |  Yes |

## Commands implemented in the stock firmware by atfwd_daemon in userspace
| Command | Description | Handled by | Implemented |
| ------- |:-----------:|:----------:| -----------:|
| AT+CFUN | +CFUN | Userspace+DSP  |  Yes (DSP only) |
| AT+CMUX | +CMUX | Userspace  |  Dummy |
| AT+IPR | +IPR | Userspace  |  Dummy |
| AT+QADBKEY | +QADBKEY | Userspace  |  Dummy |
| AT+QADC | +QADC | Userspace  |  Dummy |
| AT+QADCTEMP | +QADCTEMP | Userspace  |  Dummy |
| AT+QAPRDYIND | +QAPRDYIND | Userspace  |  Dummy |
| AT+QAUDCFG | +QAUDCFG | Userspace  |  Dummy |
| AT+QAUDLOOP | +QAUDLOOP | Userspace  |  Dummy |
| AT+QAUDMOD | +QAUDMOD | Userspace  |  Dummy |
| AT+QAUDPLAY | +QAUDPLAY | Userspace  |  Dummy |
| AT+QAUDRD | +QAUDRD | Userspace  |  Dummy |
| AT+QAUDSTOP | +QAUDSTOP | Userspace  |  Dummy |
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
| AT+QCFG | +QCFG | Userspace+ADSP  |  Yes (DSP only) |
| AT+QDAI | +QDAI | Userspace  |  WIP |
| AT+QDATAFWD | +QDATAFWD | Userspace  |  Dummy |
| AT+QDIAGPORT | +QDIAGPORT | Userspace  |  Dummy |
| AT+QEEC | +QEEC | Userspace+DSP  |  Yes(DSP) |
| AT+QFASTBOOT | +QFASTBOOT | Userspace  |  Yes |
| AT+QFCT | +QFCT | Userspace  |  Dummy |
| AT+QFCTRX | +QFCTRX | Userspace  |  Dummy |
| AT+QFCTTX | +QFCTTX | Userspace  |  Dummy |
| AT+QFOTADL | +QFOTADL | Userspace  |  Dummy |
| AT+QFTCMD | +QFTCMD | Userspace  |  Dummy |
| AT+QFUMO | +QFUMO | Userspace  |  Dummy |
| AT+QFUMOCFG | +QFUMOCFG | Userspace  |  Dummy |
| AT+QGPSCFG | +QGPSCFG | Userspace  |  Dummy |
| AT+QIIC | +QIIC | Userspace  |  Dummy |
| AT+QLDTMF | +QLDTMF | Userspace  |  Dummy |
| AT+QLINUXCPU | +QLINUXCPU | Userspace  |  Dummy |
| AT+QLPING | +QLPING | Userspace  |  Dummy |
| AT+QLPMCFG | +QLPMCFG | Userspace  |  Dummy |
| AT+QLTONE | +QLTONE | Userspace  |  Dummy |
| AT+QLWWANCID | +QLWWANCID | Userspace  |  Dummy |
| AT+QLWWANDOWN | +QLWWANDOWN | Userspace  |  Dummy |
| AT+QLWWANSTATUS | +QLWWANSTATUS | Userspace  |  Dummy |
| AT+QLWWANUP | +QLWWANUP | Userspace  |  Dummy |
| AT+QLWWANURCCFG | +QLWWANURCCFG | Userspace  |  Dummy |
| AT+QMIC | +QMIC | Userspace  |  Dummy |
| AT+QNAND | +QNAND | Userspace  |  Dummy |
| AT+QODM | +QODM | Userspace  |  Dummy |
| AT+QPCMV | +QPCMV | Userspace  |  Dummy |
| AT+QPOWD | +QPOWD | Userspace  |  Dummy |
| AT+QPRINT | +QPRINT | Userspace  |  Dummy |
| AT+QPRTPARA | +QPRTPARA | Userspace  |  Dummy |
| AT+QPSM | +QPSM | Userspace  |  Dummy |
| AT+QPSMCFG | +QPSMCFG | Userspace  |  Dummy |
| AT+QPSND | +QPSND | Userspace  |  Dummy |
| AT+QRXGAIN | +QRXGAIN | Userspace  |  Dummy |
| AT+QRXIIR | +QRXIIR | Userspace  |  Dummy |
| AT+QSCLK | +QSCLK | Userspace  |  Dummy |
| AT+QSDMOUNT | +QSDMOUNT | Userspace  |  Dummy |
| AT+QSGMIICFG | +QSGMIICFG | Userspace  |  Dummy |
| AT+QSIDET | +QSIDET | Userspace  |  Dummy |
| AT+QSUBSYSVER | +QSUBSYSVER | Userspace  |  Dummy |
| AT+QTEMP | +QTEMP | Userspace  |  Dummy |
| AT+QTEMPDBG | +QTEMPDBG | Userspace  |  Dummy |
| AT+QTEMPDBGLVL | +QTEMPDBGLVL | Userspace  |  Dummy |
| AT+QTONEDET | +QTONEDET | Userspace  |  Dummy |
| AT+QTTS | +QTTS | Userspace  |  Dummy |
| AT+QTTSETUP | +QTTSETUP | Userspace  |  Dummy |
| AT+QTXIIR | +QTXIIR | Userspace  |  Dummy |
| AT+QVERSION | +QVERSION | Userspace  |  Dummy |
| AT+QWAUTH | +QWAUTH | Userspace  |  Dummy |
| AT+QWBCAST | +QWBCAST | Userspace  |  Dummy |
| AT+QWCLICNT | +QWCLICNT | Userspace  |  Dummy |
| AT+QWCLILST | +QWCLILST | Userspace  |  Dummy |
| AT+QWCLIP | +QWCLIP | Userspace  |  Dummy |
| AT+QWCLIRM | +QWCLIRM | Userspace  |  Dummy |
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
| AT+QWTOCLI | +QWTOCLI | Userspace  |  Dummy |
| AT+QWTOCLIEN | +QWTOCLIEN | Userspace  |  Dummy |
| AT+QWTTS | +QWTTS | Userspace  |  Dummy |
| AT+QWWAN | +QWWAN | Userspace  |  Dummy |

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
