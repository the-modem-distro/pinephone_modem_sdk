# What's in a QMI voice call indication packet

The modem exposes 2 primary interfaces to communicate with its host, the AT interface and the QMI interface. While you can make a call and answer it from the AT interface, it's only there for legacy reasons and lacks the verbosity of the QMI protocol, so you can't know for example at which stage the call is in.

A Voice Call indication message is usually 100-130 bytes in size, and is always sent from the modem to the host via QMI. In this modem specifically, it's sent from `/dev/smdcntl8`, which both in this firmware and in the sock one is piped directly to `/dev/rmnet_ctrl` which is the exposed connection on the USB port. 

It provides the following information:
* Which state the call is in, 
  * Is it in progress?
  * Is it on hold?
  * Ringing?
* The type of the call:
  * Is it a voice call?
  * A voice call over IP?
  * Something else?
* The direction of the call (incoming or outgoing)
* Which mode is used to call (this is the most important to know)
  * LTE
  * GSM
  * UMTS
  * ...
* The phone number that is making the call
* The number to show as a Caller ID
* Some more information that I haven't been able to understand (no docs!)

From OpenQTI's point of view, we're only interesting on some specific parts of the indication data. Here is a sample packet captured from the modem:

0x01 0x42 0x00 0x80 0x09 0x02 0x04 0x01 0x00 0x2e 0x00 0x36 0x00 0x01 0x08 0x00 0x01 0x01 x 0x0a 0x00 0x02 0x03 0x00 0x00 0x10 0x11 0x00 0x01 0x01 0x00 ....

First part is just a control header so we know what info we're getting:
| Frame | Packet length |Flags |  Service | Client | Packet type | Transaction ID |  Message ID |
|:-----:|:-------------:|:----:|:--------:|:------:|:-----------:|:--------------:|:-----------:|
| 0x01  |   0x42 0x00   | 0x80 |  0x09    |  0x02  |  0x04       |   0x01 0x00    |   0x2e      |

These all are QMI control headers, and we don't care too much about them, we just need to know that:
1. They belong to Service 0x09 (The voice service)
2. Message ID is 0x2e (Voice call indication)
The rest can be discarded. In OpenQTI I also use frame and packet type to omit the registration from the Pinephone itself, since I don't need that to know when to enable or disable audio

The next part of the data is a little mistery:

|Message length |   Constant data  |
|:-------------:|:----------------:|
| 0x00 0x36     |  0x00 0x01 0x08 0x00 0x01 0x01 |

Besides the size of the message (which lets you know how to parse parts of the voice numbers, something we don't need) I haven't been able to guess what the rest of those bytes are.

Now comes the interesting part:

| 0x0a   | 0x00   |0x02   |0x03    |0x00 0x00 0x10 0x11 0x00 0x01 0x01 0x00 |
|:------:|:------:|:------|:------:|:--------------------------------------:|
| state  | call type | direction | method |This data is always the same for voice|


The first byte indicates the call is being set up (0x0a). It could also be an incoming call ringing (0x02), an outgoing call waiting to pick up (0x01), a call successfuly established and talking (0x04) etc.

The second byte show us the call type, if it is a normal voice call (0x00), Voice over IP (for VoLTE or VoWIFI) (0x02), or something else. We don't really need that right now as the modem only uses two mixer paths for setting up audio, but we'll keep note of this byte in case someone is able to implement HD Voice support in the PinePhone side of the software stack, since the modem supports it

The third byte helps us know the direction of the call. While we could mostly getting from the first byte, because it's already telling us that it can be originating from our side or ringing on us, there are some stages where we couldn't know it, for example when it is setup, or when the call is already in progress.

Finally the fourth byte is the most important one, it's the method used to place the call. The modem supports various ways of placing a call: GSM, UMTS, LTE, etc. It also shows us if it's making a call but has no cell service (0x00).

As you could gather from the code, the modem only really uses two mixer paths and PCM devices to set up audio, but if you open the wrong one you won't hear anything. To make this work we also need the help from the kernel, so we need to tell ALSA to enable the mixer paths we need and open the correct PCM channels (imagine a professional digital mixer but instead of having physical faders and buttons to select the inputs and outputs it's all controlled by sending messages to the drivers).

So, for example, if we know we're making a LTE call, we need to enable the output and input mixers for VoLTE (if we miss one we won't hear or won't be able to speak -SEC_AUX_PCM_RX_Voice Mixer VoLTE, VoLTE_Tx Mixer SEC_AUX_PCM_TX_VoLTE), and the PCM device 4 (/dev/pcmC0D4, pcm Card 0, device 4)

With the PCM device open and the mixers enabled, audio can freely flow between the Pinephone and the modem's DSP. But there are some times, where the carrier will allow LTE data, but will reject our call in LTE mode and force the us to downgrade the call type to a normal (CS or Circuit Switch) one, either because the cell tower we're connected to is overloaded, it doesn't support it, or simply because your contract with the carrier or the negotiation with the modem doesn't result in you being allowed to place VoLTE calls. But we were already setup for a VoLTE call! If this happens, we will receive another call indication, with the same data everywhere, but with the calling method changed, and openQTI will close the PCM device we just open, unset the mixers, and set them up again for a CS call. This process takes less than 10ms, and as the modem is still placing the call, as a user you shouldn't notice this happening
