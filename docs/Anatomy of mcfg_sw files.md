# Anatomy of a Qualcomm Carrier Configuration file

### INTRODUCTION
Qualcomm basebands need a lot of software to work. While on the outside it might seem like the modem is just a bridge between your phone and your provider's network, there's a lot of software and fine tunning required for that to actually work.

This document is primarily focused on the mdm9x07 platform as used in the PinePhone and PinePhone Pro, but applies just the same as any other Qualcomm based phone, from a Xiaomi to a Sony or an iPad with a qualcomm baseband.

### WHY?
Because a lot of people can't get VoLTE to work, because the modem is missing a lot of configuration profiles for different carriers around the world, and the OEM won't provide them, so it's up to us to fill the gap.

### WHAT ARE WE LOOKING AT?
This is a really simplified diagram of the boot process for a Qualcomm SoC.
![Qualcomm boot process diagram simple](https://raw.githubusercontent.com/the-modem-distro/pinephone_modem_sdk/kirkstone/docs/img/qcboot1.jpg)

The files we're interested in are called **mcfg_hw.mbn** and **mcfg_sw.mbn**. This files are used by the AMSS (the baseband firmware, what makes the modem actually be a modem)

![Qualcomm boot process diagram simple](https://raw.githubusercontent.com/the-modem-distro/pinephone_modem_sdk/kirkstone/docs/img/qcboot2.jpg)

MCFG_SW files are just **profiles**. They are loaded on top of the Baseband firmware to fine tune specific settings to accomodate for carriers' specific configurations. They might contain from specific blocked settings for the GPS subsystem to IMS configuration data, subsidy locks and (probably for some older SoCs) even allowed screen brightness settings.

### OFFSET #0
MCFG_SW files are stored as ELF binaries. The header is a simple ELF with 3 Program headers, a hash section and (optionally) a signature. Luckily for us, signatures aren't enforced here, which allows us to dive into them and try to fix some stuff.
```
00000000  7f 45 4c 46 01 01 01 00  00 00 00 00 00 00 00 00  |.ELF............|
00000010  02 00 00 00 01 00 00 00  00 00 00 00 34 00 00 00  |............4...|
00000020  00 00 00 00 05 00 00 00  34 00 20 00 03 00 28 00  |........4. ...(.|
00000030  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000040  00 00 00 00 94 00 00 00  00 00 00 00 00 00 00 07  |................|
00000050  00 00 00 00 00 00 00 00  00 10 00 00 00 50 00 00  |.............P..|
00000060  00 50 00 00 88 00 00 00  00 10 00 00 00 00 20 02  |.P............ .|
00000070  00 10 00 00 01 00 00 00  00 20 00 00 00 00 00 00  |......... ......|
00000080  00 00 00 00 f8 49 00 00  f8 49 00 00 06 00 00 00  |.....I...I......|
00000090  04 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000000a0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
```
The ELF header tells the AMSS firmware where are the hashes for the file, where do the actual settings start inside it, and where are the signatures if there are any. 
```
00001000  00 00 00 00 03 00 00 00  00 00 00 00 28 50 00 00  |............(P..|
00001010  60 00 00 00 60 00 00 00  88 50 00 00 00 00 00 00  |`...`....P......|
00001020  88 50 00 00 00 00 00 00  dc 8b 6c 32 3a 86 2e 8f  |.P........l2:...|
00001030  c6 af 6b e0 21 ec f6 be  52 0a a6 42 8c da b5 5d  |..k.!...R..B...]|
00001040  0e de 70 b1 53 cb 2c 0d  00 00 00 00 00 00 00 00  |..p.S.,.........|
00001050  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00001060  00 00 00 00 00 00 00 00  a2 af 13 ff 44 ea e8 c3  |............D...|
00001070  13 95 59 44 77 e9 51 e6  e1 fc bc b2 f3 e7 d3 20  |..YDw.Q........ |
00001080  0d 61 2e 04 e2 bf df 01  00 00 00 00 00 00 00 00  |.a..............|
00001090  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
```
At 0x1000 we have the hash section. In our case, this contains a SHA256 for the header and another one for the contents of the profile itself. A good reference for this segment can be found [here](https://github.com/msm8916-mainline/qtestsign/blob/931247f65c0a0e581c96d3528a655bf6646d6936/hashseg.py#L17-L47)

### THE ACTUAL FILE
After the hashes, and if there aren't signatures in the file, we get to the actual MCFG_SW file. As with most of Qualcomm's binary formats, the configuration file has two headers, and after it, we get TLV (Type-Length-Value) data until we reach the footer.
```
00002000  4d 43 46 47 03 00 01 00  5f 00 00 00 08 00 00 00  |MCFG...._.......|
00002010  83 13 04 00 20 08 01 05  1a 00 00 00 01 19 00 00  |.... ...........|
```

```

00002000  4d 43 46 47 03 00 01 00  5f 00 00 00 08 00 00 00  |MCFG...._.......|
struct  mcfg_file_header {
unsigned  char  magic[4]; --> "MCFG"
uint16_t  format_version; --> Typically 2 or 3
uint16_t  config_type; --> HW or SW
uint32_t  no_of_items; --> Number of items inside the file
uint16_t  carrier_id; --> Some unique identifier for the specific carrier
uint16_t  padding; --> It's always 0
} __attribute__((packed));
```
We then have a second header with some more data
```
00002010  83 13 04 00 20 08 01 05  1a 00 00 00 01 19 00 00  |.... ...........|
struct  mcfg_sub_version_data {
uint16_t  magic; --> This is always 0x83 0x13 (4995)
uint16_t  len;  --> It's always 4 bytes
uint32_t  carrier_version;  --> Seems to be incremental
} __attribute__((packed));
```
After going through the header, we can start looping through the items and files. There are two main types that I know of:
* NV Items (Type 0x01)
* EFS Files (Type 0x02 or 0x04)
Before each item, we have a description of what we're going to get:
```
                                     ID   NV item  Attributes
          .... Part of the header. ___|______  |   | ____-> Padding
00002010  83 13 04 00 20 08 01 05  1a 00 00 00 01 19 00 00  |.... ...........|
  NV item ID    Content size       Data
          __|__ __|__ ______________|____________________
00002020  47 00 0e 00 07 52 4f 57  5f 47 65 6e 5f 33 47 50  |G....ROW_Gen_3GP|
          ____  |Next item...
00002030  50 00 10 00 00 00 01 39  00 00 50 03 04 00 07 00  |P......9..P.....|
```
For EFS files, the structure is similar, but with some specific sections to separate the file path and name and the contents of it:
```
                              ID  File type Att Pad.  Section 1: Filepath
.... previous item........  ___|_______  |   | __|__ __|__
00002180  af 1a 02 00 07 0a 36 00  00 00 02 19 00 00 01 00  |......6.........|
   filepath len               File name and path
         _|___  ____________________|____________________
00002190  24 00 2f 6e 76 2f 69 74  65 6d 5f 66 69 6c 65 73  |$./nv/item_files|
         ____________File name and path (cont)____________
000021a0  2f 6d 6f 64 65 6d 2f 6d  6d 6f 64 65 2f 73 6d 73  |/modem/mmode/sms|
            Section 2: Contents    size  Actual contents
          _________________ __|__ __|__ __|__ |--> Next item...
000021b0  5f 6f 6e 6c 79 00 02 00  02 00 07 00 3e 00 00 00  |_only.......>...|
```
We can see we have a common structure for each item:
```
struct mcfg_item {
uint32_t  id; 
uint8_t  type; --> 1 For NV "RAW" items, 2 or 4 for nv/efs files
uint8_t  attrib; --> Attributes for the item. Don't know which value is what but defines wether you can read them back or not
uint16_t  padding; --> 0x00 0x00
} __attribute__((packed));
```
And then the specific item type's structure:
**Simple NV Item**
```
struct  mcfg_nvitem {
uint16_t  id; --> NV Item ID
uint16_t  payload_size; --> Item size
uint8_t payload; --> Item data
} __attribute__((packed));
```
** NV / EFS File **
```
struct  mcfg_nvfile_part {
uint16_t  file_section; --> 0x01 for filename, 0x02 for file contents
uint16_t  section_len; --> size of this piece
uint8_t *payload[0];
} __attribute__((packed));
``` 

With this information we can loop through the entire file and extract its contents, but we're still missing a crucial piece, **the footer**

**THE FOOTER**
```
																			     Footer begin! 	Footer ID2
      Previous item.......................  __|________ __|
000069a0  44 45 20 3d 20 30 3b 4f  00 00 00 0a 00 00 00 a1  |DE = 0;O........|
								Magic string to identify it  Sect.0    Data
          __ _sz_   ____|__________________  | _len_ __|_
000069b0  00 3f 00 4d 43 46 47 5f  54 52 4c 00 02 00 00 01  |.?.MCFG_TRL.....|
  Section 1        Version    Sec.3       Display name
          | __sz__ ____|_____  |  __sz__ __|______________
000069c0  01 04 00 20 08 01 05 03  10 00 52 4f 57 5f 47 65  |... ......ROW_Ge|
                              Section 4 (Allowed SIM cards for this profile)
         _______________________________ |  __sz_ _data |-> Section 5 Carrier version
000069d0  6e 65 72 69 63 5f 33 47  50 50 04 02 00 01 00 05  |neric_3GPP......|
          _sz__ ____data___  |Section 6...
000069e0  04 00 20 08 01 05 06 02  00 01 00 07 04 00 04 00  |.. .............|
000069f0  00 00 00 00 51 00 00 00                           |....Q...|
```
I haven''t been able to determine all the possible "sections" that may exist in the footer, but some of them are:

- Section 0: Some kind of version / magic identifier, typically 256
- Section 1: Carrier version
- Section 2: MCC+MNC for this specific carrier (absent in the example as it's a generic profile)
- Section 3: Display name for this profile
- Section 4: Array of ICCIDs allowed for the profile. For example, you'll use this if you only want SIM cards starting with with ICC IDs starting with 893456 should use this profile
- Section 5: Again, carrier version. This one is optional
- Sections 6 onwards are unknown. They don't exist in all profiles and I haven't figured out what they have. Apparently, sections > 10 only exist in specific carriers

### FANTASTIC, WHAT DO WE DO WITH THIS?
I'm building 3 (WIP) tools:
- Extract_mcfg: You give it a mcfg_sw file and extracts its contents to the specified folder
- Convert_mcfg: You give it a mcfg_sw file and it recreates the headers so it matches what the EG25-G would expect
- Pack_mcfg: You give it a dumplist file created from extract_mcfg and repacks it with recreated headers.

Check out [MCFG_TOOLS](https://github.com/Biktorgj/mcfg_tools) to get the source code for these tools

Using extract_mcfg and pack_mcfg allows you to add, edit and remove specific NV items or EFS files from a specific configuration file. At this point we're in **testing** stage. Files can be unpacked, edited and repacked, and then uploaded to the modem with `mbnloader`. If correctly reworked, the files will be accepted by the modem, and can be selected with `AT+QMBNCFG`. So far I haven't seen the modem **activate** the profiles correctly, but I'm unsure if it's a problem with the profile, a carrier issue or something else.

The modem doesn't give any error message except for OK/ERROR/Crash and reboot if the file is malformed, so it's not really easy to debug if the file is good enough for it to load but then doesn't work in a specific provider.
