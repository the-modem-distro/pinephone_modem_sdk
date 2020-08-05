"""
Tool for listing and extracting data from an UBI (Unsorted Block Image) image.

(C) 2017 by Willem Hengeveld <itsme@xs4all.nl>
"""
from __future__ import division, print_function
import crcmod.predefined
import argparse
import struct
from binascii import b2a_hex
import lzo
import zlib
import os
import errno
import datetime
import sys
from collections import defaultdict

import pkg_resources

if sys.version_info[0] == 2:
    stdin = sys.stdin
    stdout = sys.stdout
else:
    stdin = sys.stdin.buffer
    stdout = sys.stdout.buffer

if sys.version_info[0] == 2:
    reload(sys)
    sys.setdefaultencoding('utf-8')

dependencies = [
    'python-lzo>=1.11',
    'crcmod>=1.7'
]

pkg_resources.require(dependencies)


if sys.version_info[0] == 3:
    def cmp(a,b):
        return (a>b) - (a<b)

# using crcmod to generate the correct crc function.
crc32 = crcmod.predefined.mkPredefinedCrcFun('CrcJamCrc')


class SeekableStdout:
    """
    Wrapper for stdout, which allows forward seeking.
    """
    def __init__(self):
        self.pos = 0

    def seek(self, newpos, whence=os.SEEK_SET):
        if whence==os.SEEK_SET:
            if newpos < self.pos:
                print("WARNING: can't seek stdout backwards")
                return -1
            if newpos > self.pos:
                self.seekforward(newpos - self.pos)
            self.pos = newpos
        elif whence==os.SEEK_CUR:
            if newpos < 0:
                print("WARNING: can't seek stdout backwards")
                return -1
            if newpos > 0:
                self.seekforward(newpos)
            self.pos += newpos
        else:
            print("WARNING: can't seek stdout from EOF")
            return -1

    def seekforward(self, size):
        """
        Seek forward by writing NUL bytes.
        """
        sys.stdout.flush()
        chunk = b"\x00" * 0x10000
        while size > 0:
            if len(chunk) > size:
                chunk = chunk[:size]
            stdout.write(chunk)
            size -= len(chunk)

    def write(self, data):
        sys.stdout.flush()
        stdout.write(data)
        self.pos += len(data)

    def truncate(self, size):
        """
        Ignore this.
        """
        pass


########### block level objects ############

class UbiEcHeader:
    """
    The Erase count header
    """
    hdrsize = 16*4
    def __init__(self):
        self.magic = b'UBI#'
    def parse(self, data):
        self.magic, self.version, self.erasecount, self.vid_hdr_ofs, self.data_ofs, \
                self.image_seq, hdr_crc = struct.unpack(">4sB3xQLLL32xL", data)
        if self.magic != b'UBI#':
            raise Exception("magic num mismatch")
        if hdr_crc != crc32(data[:-4]):
            raise Exception("crc mismatch")
    def encode(self):
        data = struct.pack(">4sB3xQLLL32x", self.magic, self.version, self.erasecount, self.vid_hdr_ofs, self.data_ofs, \
                self.image_seq)
        return data + struct.pack(">L", crc32(data))
    def __repr__(self):
        return "EC: magic=%s, v%d, ec=%d, vidhdr=%x, data=%x, imgseq=%x" % ( 
                self.magic, self.version, self.erasecount, self.vid_hdr_ofs,
                self.data_ofs, self.image_seq)


VTBL_VOLID=0x7fffefff
class UbiVidHead:
    """
    The volume id header
    """
    hdrsize = 16*4
    def __init__(self):
        self.vol_id = VTBL_VOLID
        self.magic = b'UBI!'

    def parse(self, data):
        self.magic, self.version, self.vol_type, self.copy_flag, self.compat, self.vol_id, \
                self.lnum, self.data_size, self.used_ebs, self.data_pad, self.data_crc, \
                self.sqnum, hdr_crc = struct.unpack(">4s4BLL4x4L4xQ12xL", data)
        if self.magic != b'UBI!':
            raise Exception("magic num mismatch")
        if hdr_crc != crc32(data[:-4]):
            raise Exception("crc mismatch")

    def encode(self):
        data = struct.pack(">4s4BLL4x4L4xQ12x", self.magic, self.version, self.vol_type, self.copy_flag, self.compat, self.vol_id, \
                self.lnum, self.data_size, self.used_ebs, self.data_pad, self.data_crc, \
                self.sqnum)
        return data + struct.pack(">L", crc32(data))

    def __repr__(self):
        if hasattr(self, 'magic'):
            return "VID: magic=%s, v%d, vt=%d, cp=%d, compat=%d, volid=%x, lnum=[%d], " \
                    "dsize=%d, usedebs=%d, datapad=%d, datacrc=%x, sqnum=%d" % (
                            self.magic, self.version, self.vol_type, self.copy_flag, self.compat,
                            self.vol_id, self.lnum, self.data_size, self.used_ebs, self.data_pad,
                            self.data_crc, self.sqnum)
        else:
            return "VID"


class UbiVtblRecord:
    """
    A volume table record.
    """
    hdrsize = 4*4+128+24+4
    def __init__(self):
        self.reserved_pebs = 0
    def parse(self, data):
        self.reserved_pebs, self.alignment, self.data_pad, self.vol_type, self.upd_marker, \
                name_len, self.name, self.flags, crc = struct.unpack(">3LBBH128sB23xL", data)
        if crc != crc32(data[:-4]):
            raise Exception("crc mismatch")
        self.name = self.name[:name_len]
    def encode(self):
        data = struct.pack(">3LBBH128sB23x", self.reserved_pebs, self.alignment, self.data_pad, self.vol_type, self.upd_marker, \
                name_len, self.name, self.flags)
        return data + struct.pack(">L", crc32(data))
    def empty(self):
        if hasattr(self, 'name'):
            return self.reserved_pebs==0 and self.alignment==0 and self.data_pad==0 \
                    and self.vol_type==0 and self.upd_marker==0 and self.name==b'' and self.flags==0
        else:
            return True

    def __repr__(self):
        return "VREC: rsvpebs=%d, align=%d, datapad=%d, voltype=%d, updmark=%d, flags=%x, name=%s" % (
                self.reserved_pebs, self.alignment, self.data_pad, self.vol_type, 
                        self.upd_marker, self.flags, self.name)


class UbiVolume:
    """
    provides read access to a specific volume in an UBI image.
    """
    def __init__(self, blks, volid, dataofs):
        """
        takes an UbiBlocks object, a volumeid, and a baseoffset.
        """
        self.blks = blks
        self.volid = volid
        self.dataofs = dataofs

    def read(self, lnum, offs, size):
        return self.blks.readvolume(self.volid, lnum, self.dataofs+offs, size)

    def write(self, lnum, offs, data):
        return self.blks.writevolume(self.volid, lnum, self.dataofs+offs, data)

    def hexdump(self, lnum, offs, size):
        print("[%03d:0x%05x] %s" % (lnum, offs, b2a_hex(self.read(lnum, offs, size))))


class RawVolume:
    """
    provides read access to a raw data volume
    """
    def __init__(self, fh):
        self.fh = fh
        self.leb_size = self.find_block_size()

    def read(self, lnum, offs, size):
        self.fh.seek(lnum*self.leb_size+offs)
        return self.fh.read(size)

    def write(self, lnum, offs, data):
        self.fh.seek(lnum*self.leb_size+offs)
        return self.fh.write(data)

    def find_block_size(self):
        self.fh.seek(0)
        data = self.fh.read(0x200)
        values = struct.unpack("<12L", data[:4*12])
        if values[0] == 0x06101831 and values[5] == 6:
            # is superblock
            return values[9]

    def hexdump(self, lnum, offs, size):
        print("[%03d:0x%05x] %s" % (lnum, offs, b2a_hex(self.read(lnum, offs, size))))


class UbiBlocks:
    """
    Block level access to an UBI image.
    """
    def __init__(self, fh):
        self.fh = fh
        self.lebsize = self.find_blocksize()

        fh.seek(0, os.SEEK_END)
        self.filesize = fh.tell()
        self.maxlebs = self.filesize // self.lebsize

        self.scanblocks()

        if not VTBL_VOLID in self.vmap:
            print("no volume directory, %d physical volumes" % len(self.vmap))
            return
        self.scanvtbls(self.vmap[VTBL_VOLID][0])

        print("%d named volumes found, %d physical volumes, blocksize=0x%x" % (self.nr_named, len(self.vmap), self.lebsize))

    def find_blocksize(self):
        self.fh.seek(0)
        magic = self.fh.read(4)
        if magic != b'UBI#':
            raise Exception("not an UBI image")
        for log_blocksize in range(10,20):
            self.fh.seek(1<<log_blocksize)
            magic = self.fh.read(4)
            if magic == b'UBI#':
                return 1<<log_blocksize
        raise Exception("Could not determine UBI image blocksize")

    def scanblocks(self):
        """
        creates map of volid + lnum => physical lnum
        """
        self.vmap = defaultdict(lambda : defaultdict(int))
        for lnum in range(self.maxlebs):

            try:
                ec = UbiEcHeader()
                hdr = self.readblock(lnum, 0, ec.hdrsize)
                ec.parse(hdr)

                vid = UbiVidHead()
                viddata = self.readblock(lnum, ec.vid_hdr_ofs, vid.hdrsize)
                vid.parse(viddata)

                self.vmap[vid.vol_id][vid.lnum] = lnum
            except:
                pass

    def readblock(self, lnum, offs, size):
        self.fh.seek(lnum * self.lebsize + offs)
        return self.fh.read(size)

    def writeblock(self, lnum, offs, data):
        self.fh.seek(lnum * self.lebsize + offs)
        return self.fh.write(data)

    def hexdump(self, lnum, offs, size):
        print("[%03d:0x%05x] %s" % (lnum, offs, b2a_hex(self.readblock(lnum, offs, size))))

    def scanvtbls(self, lnum):
        """
        reads the volume table
        """
        ec = UbiEcHeader()
        hdr = self.readblock(lnum, 0, ec.hdrsize)
        ec.parse(hdr)

        self.ec = ec

        try:
            vid = UbiVidHead()
            viddata = self.readblock(lnum, ec.vid_hdr_ofs, vid.hdrsize)
            vid.parse(viddata)

            self.vid = vid

            self.vtbl = []
            self.nr_named = 0

            if vid.vol_id == VTBL_VOLID:
                for i in range(128):
                    vrec = UbiVtblRecord()
                    vrecdata = self.readblock(lnum, self.ec.data_ofs + i * vrec.hdrsize, vrec.hdrsize)
                    vrec.parse(vrecdata)

                    self.vtbl.append(vrec)

                    if not vrec.empty():
                        self.nr_named += 1
        except:
            print(ec)
            print("viddata:%s" % b2a_hex(viddata))
            import traceback
            traceback.print_exc()

            self.vid = UbiVidHead()
            self.vtbl = [ UbiVtblRecord() ]

    def dumpvtbl(self):
        print("%s  %s" % (self.ec, self.vid))
        for v in self.vtbl:
            if not v.empty():
                print("  %s" % v)

        for volid, lmap in self.vmap.items():
            print("volume %x : %d lebs" % (volid, len(lmap)))

    def nr_named(self):
        return self.nr_named

    def getvrec(self, volid):
        return self.vtbl[volid]

    def getvolume(self, volid):
        return UbiVolume(self, volid, self.ec.data_ofs)

    def readvolume(self, volid, lnum, offs, size):
        physlnum = self.vmap[volid].get(lnum, None)
        if physlnum is None:
            raise Exception("volume does not contain lnum")
        return self.readblock(physlnum, offs, size)

    def writevolume(self, volid, lnum, offs, data):
        physlnum = self.vmap[volid].get(lnum, None)
        if physlnum is None:
            raise Exception("volume does not contain lnum")
        return self.writeblock(physlnum, offs, data)



################ filesytem level objects ##################

UBIFS_INO_KEY = 0
UBIFS_DATA_KEY = 1
UBIFS_DENT_KEY = 2
UBIFS_XENT_KEY = 3

"""
key format:  (inum, (type<<29) | value)
   
key types: UBIFS_*_KEY: INO, DATA, DENT, XENT

inode:  <inum>  + 0
dirent:  <inum>  + hash
xent:  <inum>  + hash
data:  <inum + blocknum
trunc:  <inum>  + 0

"""
def unpackkey(key):
    if len(key)==16 and key[8:]!=b'\x00'*8:
        print("key has more than 8 bytes: %s" % b2a_hex(key))
    inum, value = struct.unpack("<LL", key[:8])
    return (inum, value>>29, value&0x1FFFFFFF)


def packkey(key):
    inum, ityp, value = key
    return struct.pack("<LL", inum, (ityp<<29) | value)


def formatkey(key):
    if key is None:
        return "None"
    if type(key) != tuple:
        key = unpackkey(key)
    return "%05d:%d:%08x" % key


def comparekeys(lhs, rhs):
    return cmp(unpackkey(lhs), unpackkey(rhs))


def namehash(name):
    a = 0
    for b in name:
        if type(b)==str: b = ord(b)
        a += b<<4
        a += b>>4
        a &= 0xFFFFFFFF
        a *= 11
        a &= 0xFFFFFFFF
    a &= 0x1FFFFFFF
    if a <= 2: a += 3
    return a


COMPR_NONE = 0
COMPR_LZO = 1
COMPR_ZLIB = 2
def decompress(data, buflen, compr_type):
    if compr_type==COMPR_NONE:
        return data
    elif compr_type==COMPR_LZO:
        return lzo.decompress(data, False, buflen)
    elif compr_type==COMPR_ZLIB:
        return zlib.decompress(data, -zlib.MAX_WBITS)
    else:
        raise Exception("unknown compression type")


def compress(data, compr_type):
    if compr_type==COMPR_NONE:
        return data
    elif compr_type==COMPR_LZO:
        return lzo.compress(data, False)
    elif compr_type==COMPR_ZLIB:
        return zlib.compress(data, -zlib.MAX_WBITS)
    else:
        raise Exception("unknown compression type")


# the blocksize is a fixed value, independent of the underlying device.
UBIFS_BLOCKSIZE = 4096

########### objects for the various node types ########### 
class UbiFsInode:
    """
    Leafnode in the B-tree, contains information for a specific file or directory.

    It's b-tree key is formatted like this:
       * 32 bit inode number
       * the 3 bit node type: 0 for inode
       * a 29 bit zero value.
    """
    nodetype = 0
    hdrsize = 16 + 5*8 + 11*4 + 2*4 + 28

    # note: these values are like the posix stat values,
    # the UbiFsDirEntry uses a different set of values for the same types.
    ITYPE_FIFO      =  1  # S_IFIFO 
    ITYPE_CHARDEV   =  2  # S_IFCHR 
    ITYPE_DIRECTORY =  4  # S_IFDIR 
    ITYPE_BLOCKDEV  =  6  # S_IFBLK 
    ITYPE_REGULAR   =  8  # S_IFREG 
    ITYPE_SYMLINK   = 10  # S_IFLNK 
    ITYPE_SOCKET    = 12  # S_IFSOCK

    def __init__(self):
        pass
    def parse(self, data):
        (
        self.key,          # 16s
        self.creat_sqnum,  # Q
        self.size,         # Q
        self.atime_sec,    # Q
        self.ctime_sec,    # Q
        self.mtime_sec,    # Q
        self.atime_nsec,   # L
        self.ctime_nsec,   # L
        self.mtime_nsec,   # L
        self.nlink,        # L
        self.uid,          # L
        self.gid,          # L
        self.mode,         # L
        self.flags,        # L
        self.data_len,     # L
        self.xattr_cnt,    # L
        self.xattr_size,   # L
                           # 4x
        self.xattr_names,  # L
        self.compr_type    # H
                           # 26x
        ) = struct.unpack("<16s5Q11L4xLH26x", data[:self.hdrsize])

        # data contains the symlink string for symbolic links
        self.data = data[self.hdrsize:]
        if len(self.data) != self.data_len:
            raise Exception("inode data size mismatch")

    def encode(self):
        return struct.pack("<16s5Q11L4xLH26x", \
                self.key, self.creat_sqnum, self.size, self.atime_sec, self.ctime_sec, self.mtime_sec, \
                self.atime_nsec, self.ctime_nsec, self.mtime_nsec, self.nlink, self.uid, self.gid, \
                self.mode, self.flags, self.data_len, self.xattr_cnt, self.xattr_size, \
                self.xattr_names, self.compr_type)

    def inodedata_repr(self):
        types = ["0", "FIFO", "CHAR", "3", "DIRENT", "5", "BLOCK", "7", "FILE", "9", "LINK", "11", "SOCK", "13", "14", "15"]
        typ = self.nodetype()
        if typ in (self.ITYPE_CHARDEV, self.ITYPE_BLOCKDEV):  # CHAR or BLOCK
            return types[typ] + ":" + b2a_hex(self.data).decode('ascii')
        return types[typ] + ":%s" % self.data

    def __repr__(self):
        return "INODE: key=%s, sq=%04x, size=%5d, n=%3d, uid:gid=%d:%d, mode=%06o, fl=%x, dl=%3d, " \
                "xattr=%d:%d, xanames=%d, comp=%d -- %s" % (formatkey(self.key), self.creat_sqnum, 
                        self.size, self.nlink, self.uid, self.gid, self.mode, self.flags, self.data_len, 
                        self.xattr_cnt, self.xattr_size, self.xattr_names, self.compr_type,  self.inodedata_repr())
        # todo: self.atime_sec, self.ctime_sec, self.mtime_sec, self.atime_nsec, self.ctime_nsec, self.mtime_nsec, 
    def atime(self):
        return self.atime_sec + self.atime_nsec / 1000000000.0
    def mtime(self):
        return self.mtime_sec + self.mtime_nsec / 1000000000.0
    def ctime(self):
        return self.ctime_sec + self.ctime_nsec / 1000000000.0
    def devnum(self):
        ma, mi = struct.unpack("BB", self.data[:2])
        return (ma, mi)
    def nodetype(self):
        return (self.mode >> 12) & 0xF


class UbiFsData:
    """
    Leafnode in the B-tree, contains a datablock

    It's b-tree key is formatted like this:
       * 32 bit inode number
       * the 3 bit node type: 1 for data
       * a 29 bit file blocknumber
    """
    nodetype = 1
    hdrsize = 16 + 4 + 4
    def __init__(self):
        pass
    def parse(self, data):
        self.key, self.size, self.compr_type = struct.unpack("<16sLH2x", data[:self.hdrsize])
        self.data = decompress(data[self.hdrsize:], self.size, self.compr_type)
        if len(self.data) != self.size:
            raise Exception("data size mismatch")

    def encode(self):
        return struct.pack("<16sLH2x", self.key, len(self.data), self.compr_type) + compress(self.data, self.compr_type)

    def __repr__(self):
        return "DATA: key=%s, size=%d, comp=%d" % (formatkey(self.key), self.size, self.compr_type)


class UbiFsDirEntry:
    """
    Leafnode in the B-tree, contains a directory entry.

    Properties:
      * key
      * inum
      * type
      * name

    It's b-tree key is formatted like this:
       * 32 bit inode number ( of the directory containing this dirent )
       * the 3 bit node type: 2 for dirent
       * a 29 bit name hash
    """
    TYPE_REGULAR = 0
    TYPE_DIRECTORY = 1
    TYPE_SYMLINK = 2
    TYPE_BLOCKDEV = 3
    TYPE_CHARDEV = 4
    TYPE_FIFO = 5
    TYPE_SOCKET = 6

    ALL_TYPES = 127

    nodetype = 2
    hdrsize = 16 + 8+4+4

    def __init__(self):
        pass
    def parse(self, data):
        self.key, self.inum, self.type, nlen = struct.unpack("<16sQxBH4x", data[:self.hdrsize])
        self.name = data[self.hdrsize:-1]
        if len(self.name) != nlen:
            raise Exception("name length mismatch")
    def encode(self):
        return struct.pack("<16sQxBH4x", self.key, self.inum, self.type, nlen)
    def __repr__(self):
        typenames = [ 'reg', 'dir', 'lnk', 'blk', 'chr', 'fifo', 'sock' ]
        # type: UBIFS_ITYPE_REG, UBIFS_ITYPE_DIR, etc
        return "DIRENT: key=%s, inum=%05d, type=%d:%s -- %s" % (formatkey(self.key), self.inum, self.type, typenames[self.type], self.name)


class UbiFsExtendedAttribute:
    """
    Leafnode in the B-tree, contains extended attributes.

    It's b-tree key is formatted like this:
       * 32 bit inode number ( of the directory containing this dirent )
       * the 3 bit node type: 3 for xent
       * a 29 bit hash of the attribute name.
    """
    nodetype = 3
    hdrsize = 0
    def __init__(self):
        pass
    def parse(self, data):
        # TODO
        pass
    def __repr__(self):
        return "EA"


class UbiFsTruncation:
    """
    Used only in the journal
    """
    nodetype = 4
    hdrsize = 4+12+2*8
    def __init__(self):
        pass
    def parse(self, data):
        self.inum, self.old_size, self.new_size = struct.unpack("<L12xQQ", data)
    def encode(self):
        return struct.pack("<L12xQQ", self.inum, self.old_size, self.new_size)
    def __repr__(self):
        return "TRUNC: inum:%05d, size:%d->%d" % (self.inum, self.old_size, self.new_size)


class UbiFsPadding:
    """
    """
    nodetype = 5
    hdrsize = 4
    def __init__(self):
        pass
    def parse(self, data):
        self.pad_len, = struct.unpack_from("<L", data, 0)
    def encode(self):
        return struct.pack("<L", self.pad_len)
    def __repr__(self):
        return "PAD: padlen=%d" % self.pad_len


class UbiFsSuperblock:
    """
    This object can be referenced via UbiFs.sb
    """
    nodetype = 6
    hdrsize = 6*4+8+7*4+3*4+8+4+16+4
    def __init__(self):
        pass
    def parse(self, data):
        self.key_hash, self.key_fmt, self.flags, self.min_io_size, self.leb_size, self.leb_cnt, \
                self.max_leb_cnt, self.max_bud_bytes, self.log_lebs, self.lpt_lebs, self.orph_lebs, \
                self.jhead_cnt, self.fanout, self.lsave_cnt, self.fmt_version, self.default_compr, \
                self.rp_uid, self.rp_gid, self.rp_size, self.time_gran, self.uuid, self.ro_compat_version \
            = struct.unpack("<2xBB5LQ7LH2xLLQL16sL", data[:self.hdrsize])
        if len(data) != self.hdrsize + 3968:
            raise Exception("invalid superblock padding size")
    def encode(self):
        return struct.pack("<2xBB5LQ7LH2xLLQL16sL", 
                self.key_hash, self.key_fmt, self.flags, self.min_io_size, self.leb_size, self.leb_cnt, \
                self.max_leb_cnt, self.max_bud_bytes, self.log_lebs, self.lpt_lebs, self.orph_lebs, \
                self.jhead_cnt, self.fanout, self.lsave_cnt, self.fmt_version, self.default_compr, \
                self.rp_uid, self.rp_gid, self.rp_size, self.time_gran, self.uuid, self.ro_compat_version)
    def __repr__(self):
        return "SUPER: kh:%d, fmt:%d, flags=%x, minio=%d, lebsize=0x%x, lebcount=%d, maxleb=%d, " \
                "maxbud=%d, loglebs=%d, lptlebs=%d, orphlebs=%d, jheads=%d, fanout=%d, lsave=%d, " \
                "fmt=v%d, compr=%d, rp=%d:%d, rpsize=%d, timegran=%d, uuid=%s, rocompat=%d" % (
                        self.key_hash, self.key_fmt, self.flags, self.min_io_size, self.leb_size,
                        self.leb_cnt, self.max_leb_cnt, self.max_bud_bytes, self.log_lebs, self.lpt_lebs,
                        self.orph_lebs, self.jhead_cnt, self.fanout, self.lsave_cnt, self.fmt_version,
                        self.default_compr, self.rp_uid, self.rp_gid, self.rp_size, self.time_gran,
                        b2a_hex(self.uuid), self.ro_compat_version)


class UbiFsMaster:
    """
    This object can be referenced via UbiFs.mst
    """
    nodetype = 7
    hdrsize = 2*8+8*4+6*8+12*4
    def __init__(self):
        pass
    def parse(self, data):
        self.highest_inum, self.cmt_no, self.flags, self.log_lnum, self.root_lnum, self.root_offs, \
                self.root_len, self.gc_lnum, self.ihead_lnum, self.ihead_offs, self.index_size, \
                self.total_free, self.total_dirty, self.total_used, self.total_dead, \
                self.total_dark, self.lpt_lnum, self.lpt_offs, self.nhead_lnum, self.nhead_offs, \
                self.ltab_lnum, self.ltab_offs, self.lsave_lnum, self.lsave_offs, self.lscan_lnum, \
                self.empty_lebs, self.idx_lebs, self.leb_cnt = struct.unpack("<QQ8L6Q12L", data[:self.hdrsize])
        if len(data) != self.hdrsize + 344:
            raise Exception("invalid master padding size")

    def encode(self):
        return struct.pack("<QQ8L6Q12L", self.highest_inum, self.cmt_no, self.flags, self.log_lnum, self.root_lnum, self.root_offs, \
                self.root_len, self.gc_lnum, self.ihead_lnum, self.ihead_offs, self.index_size, \
                self.total_free, self.total_dirty, self.total_used, self.total_dead, \
                self.total_dark, self.lpt_lnum, self.lpt_offs, self.nhead_lnum, self.nhead_offs, \
                self.ltab_lnum, self.ltab_offs, self.lsave_lnum, self.lsave_offs, self.lscan_lnum, \
                self.empty_lebs, self.idx_lebs, self.leb_cnt)

    def __repr__(self):
        return "MST: max_inum=%05d, cmtno=%d, flags=%x, loglnum=[%03d], root=[%03d:0x%05x], rootlen=%d, " \
                "gc_lnum=[%03d], ihead=[%03d:0x%05x], ixsize=%d, total(free:%d, dirty:%d, used:%d, " \
                "dead:%d, dark:%d), lpt=[%03d:0x%05x], nhead=[%03d:0x%05x], ltab=[%03d:0x%05x], " \
                "lsave=[%03d:0x%05x], lscan=[%03d], empty=%d, idx=%d, nleb=%d" % (
                        self.highest_inum, self.cmt_no, self.flags, self.log_lnum,
                        self.root_lnum, self.root_offs, self.root_len,
                        self.gc_lnum, self.ihead_lnum, self.ihead_offs,
                        self.index_size, self.total_free, self.total_dirty, self.total_used, self.total_dead,
                        self.total_dark, self.lpt_lnum, self.lpt_offs, self.nhead_lnum, self.nhead_offs,
                        self.ltab_lnum, self.ltab_offs, self.lsave_lnum, self.lsave_offs, self.lscan_lnum,
                        self.empty_lebs, self.idx_lebs, self.leb_cnt)


class UbiFsLEBReference:
    nodetype = 8
    hdrsize = 12+28
    def __init__(self):
        pass
    def parse(self, data):
        self.lnum, self.offs, self.jhead = struct.unpack("<3L28x", data)
    def encode(self):
        return struct.pack("<3L28x", self.lnum, self.offs, self.jhead)
    def __repr__(self):
        return "REF: ref=[%03d:0x%05x], jhead=%d" % (self.lnum, self.offs, self.jhead)


class UbiFsIndex:
    """
    Part if the B-tree structure, referenced via UbiFs.root.
    """
    nodetype = 9
    hdrsize = 4

    class Branch:
        hdrsize = 12
        def __init__(self):
            pass
        def parse(self, data):
            self.lnum, self.offs, self.len = struct.unpack("<3L", data[:self.hdrsize])
            self.key = data[self.hdrsize:]
        def encode(self):
            return struct.pack("<3L", self.lnum, self.offs, self.len) + self.key
        def __repr__(self):
            return "BRANCH: ref=[%03d:0x%05x] len=%4d -- key=%s" % (self.lnum, self.offs, self.len, formatkey(self.key))

    def __init__(self):
        pass
    def parse(self, data):
        self.child_cnt, self.level = struct.unpack("<HH", data[:self.hdrsize])
        self.branches = []
        o = self.hdrsize
        for _ in range(self.child_cnt):
            if o >= len(data):
                raise Exception("parse error")
            branch = self.Branch()
            branch.parse(data[o:o+branch.hdrsize])  ; o += branch.hdrsize
            branch.key = data[o:o+8]     ; o += 8
            self.branches.append(branch)
    def encode(self):
        data = struct.pack("<HH", self.child_cnt, self.level)
        for _ in self.branches:
            data += _.encode()
        return data

    def __repr__(self):
        return "INDEX: nchild=%d, level=%d" % (self.child_cnt, self.level)

    def find(self, key):
        """
        searches index for a branch.key >= key, returns relation to the key

        these are all possibilities with 1 branches

            key < b0    -> 'lt', 0
            key == b0   -> 'eq', 0
            b0 < key    -> 'gt', 0

        these are all possibilities with 2 branches
            key < b0 < b1   -> 'lt', 0
            key == b0 < b1  -> 'eq', 0
            b0 < key < b1   -> 'gt', 0
            b0 < key == b1  -> 'eq', 1
            b0 < b1 < key   -> 'gt', 1

        add two more options for every next branch.

        """
        for i, b in enumerate(self.branches):
            c = comparekeys(key, b.key)
            if c<0:
                if i==0:
                    # before first item
                    return ('lt', i)
                else:
                    # between prev and this item
                    return ('gt', i-1)
            elif c==0:
                # found item
                return ('eq', i)
            # else c>0 -> continue searching

        # after last item
        return ('gt', i)



class UbiFsCommitStart:
    nodetype = 10
    hdrsize = 8
    def __init__(self):
        pass
    def parse(self, data):
        self.cmt_no, = struct.unpack("<Q", data[:self.hdrsize])
    def encode(self):
        return struct.pack("<Q", self.cmt_no)
    def __repr__(self):
        return "COMMIT: cmt=%d" % self.cmt_no


class UbiFsOrphan:
    nodetype = 11
    hdrsize = 8
    def __init__(self):
        pass
    def parse(self, data):
        self.cmt_no, = struct.unpack("<Q", data[:self.hdrsize])
        # todo: inos
    def encode(self):
        return struct.pack("<Q", self.cmt_no)
    def __repr__(self):
        return "ORPHAN: cmt=%d" % self.cmt_no


class UbiFsCommonHeader:
    """
    Header common to all node types.
    """
    hdrsize = 16+8
    _classmap = [
            UbiFsInode,                 #  0
            UbiFsData,                  #  1
            UbiFsDirEntry,              #  2
            UbiFsExtendedAttribute,     #  3
            UbiFsTruncation,            #  4
            UbiFsPadding,               #  5
            UbiFsSuperblock,            #  6
            UbiFsMaster,                #  7
            UbiFsLEBReference,          #  8
            UbiFsIndex,                 #  9
            UbiFsCommitStart,           # 10
            UbiFsOrphan,                # 11
    ]
    def __init__(self):
        self.magic = 0x06101831
        self.crc = 0
        self.sqnum = 0
    def parse(self, data):
        self.magic, self.crc, self.sqnum, self.len, self.node_type, self.group_type = struct.unpack("<LLQLBB2x", data)
        if self.magic != 0x06101831:
            raise Exception("magic num mismatch")
    def encode(self):
        return struct.pack("<LLQLBB2x", self.magic, self.crc, self.sqnum, self.len, self.node_type, self.group_type)

    def getnode(self):
        """
        create node object for current node type.
        """
        if 0 <= self.node_type < len(self._classmap):
            cls = self._classmap[self.node_type]

            node = cls()
            node.hdr = self

            return node
        raise Exception("invalid node type")
    def __repr__(self):
        return "%08x %08x %08x %08x %2d %2d" % (self.magic, self.crc, self.sqnum, self.len, self.node_type, self.group_type)


class UbiFs:
    """
    Filesystem level access to an UBI image volume.

    the filesystem consists of a b-tree containing inodes, direntry and data nodes.
    """
    def __init__(self, vol, masteroffset):
        """
        The constructor takes a UbiVolume or RawVolume object
        """
        self.vol = vol

        self.load(masteroffset)

    def find_most_recent_master(self):
        o = 0
        mst = None
        while True:
            try:
                mst = self.readnode(1, o)
                o += 0x1000   # Fixed value ... do i need to configure this somewhere?
            except:
                return mst

    def load(self, masteroffset):
        self.sb = self.readnode(0, 0)
        if masteroffset:
            self.mst = self.readnode(*masteroffset)
            print("using mst from 0x%x, seq: %08x/%08x" % (masteroffset, self.mst.hdr.sqnum, self.mst.cmt_no))
        else:
            self.mst = self.find_most_recent_master()

        # todo: check that the 2nd master node matches the first.
        #mst2 = self.readnode(2, 0)

        self.root = self.readnode(self.mst.root_lnum, self.mst.root_offs)

    def dumpfs(self):
        print("[%03d:0x%05x-0x%05x] %s" % (self.sb.hdr.lnum, self.sb.hdr.offs, self.sb.hdr.offs+self.sb.hdr.len, self.sb))
        print("[%03d:0x%05x-0x%05x] %s" % (self.mst.hdr.lnum, self.mst.hdr.offs, self.mst.hdr.offs+self.mst.hdr.len, self.mst))

    def readnode(self, lnum, offs):
        """
        read a node from a lnum + offset.
        """
        ch = UbiFsCommonHeader()
        hdrdata = self.vol.read(lnum, offs, ch.hdrsize)
        ch.parse(hdrdata)

        ch.lnum = lnum
        ch.offs = offs

        node = ch.getnode()
        nodedata = self.vol.read(lnum, offs + ch.hdrsize, ch.len - ch.hdrsize)

        if crc32(hdrdata[8:] + nodedata) != ch.crc:
            node.parse(nodedata)
            print(ch, node)
            print(" %s + %s = %08x -> want = %08x" % ( b2a_hex(hdrdata), b2a_hex(nodedata), crc32(hdrdata[8:] + nodedata), ch.crc))
            raise Exception("invalid node crc")
        node.parse(nodedata)

        return node

    def writenode(self, node):
        """
        Write a node from a lnum + offset.

        TODO
        """

        nodedata = node.encode()

        node.hdr.len = len(nodedata) + node.hdr.hdrsize
        hdrdata = node.hdr.encode()

        node.hdr.crc = crc32(hdrdata[8:] + nodedata)
        hdrdata = node.hdr.encode()

        self.vol.write(node.hdr.lnum, node.hdr.offs, hdrdata+nodedata)

    def dumpnode(self, lnum, offs):
        node = self.readnode(lnum, offs)
        print("[%03d:0x%05x-0x%05x] %s" % (lnum, offs, offs+node.hdr.len, node))

    def printrecursive(self, idx):
        """
        Recursively dump all b-tree nodes.
        """
        print("[%03d:0x%05x-0x%05x] %s" % (idx.hdr.lnum, idx.hdr.offs, idx.hdr.offs+idx.hdr.len, idx))
        if not hasattr(idx, 'branches'):
            #print(idx)
            return
        for i, b in enumerate(idx.branches):
            print("%s %d %s -> " % ("  " * (6-idx.level), i, b), end=" ")
            try:
                n = self.readnode(b.lnum, b.offs)
                self.printrecursive(n)
            except Exception as e:
                print("ERROR %s" % e)

    def printmbitems(self):
        print("--log [%03d] .. [%03d]" % (self.mst.log_lnum, self.mst.log_lnum+self.sb.log_lebs-1))
        try:
            self.dumpnode(self.mst.log_lnum, 0)
            self.vol.hexdump(self.mst.log_lnum, 0, 0x100)
        except Exception as e:
            print(e)
        print("--root")
        try:
            self.dumpnode(self.mst.root_lnum, self.mst.root_offs)
            self.vol.hexdump(self.mst.root_lnum, self.mst.root_offs, self.mst.root_len)
        except Exception as e:
            print(e)
        print("--gc [%03d]" % (self.mst.gc_lnum))
        try:
            self.vol.hexdump(self.mst.gc_lnum, 0, 0x100)
        except Exception as e:
            print(e)
        print("--ihead")
        try:
            self.vol.hexdump(self.mst.ihead_lnum, self.mst.ihead_offs, self.mst.index_size)
        except Exception as e:
            print(e)
        print("--lpt [%03d] .. [%03d]" % (self.mst.lpt_lnum, self.mst.lpt_lnum+self.sb.lpt_lebs-1))
        try:
            self.vol.hexdump(self.mst.lpt_lnum, self.mst.lpt_offs, 0x100)
        except Exception as e:
            print(e)
        print("--nhead")
        try:
            self.vol.hexdump(self.mst.nhead_lnum, self.mst.nhead_offs, 0x100)
        except Exception as e:
            print(e)
        print("--ltab")
        try:
            self.vol.hexdump(self.mst.ltab_lnum, self.mst.ltab_offs, 0x100)
        except Exception as e:
            print(e)
        print("--lsave")
        try:
            self.vol.hexdump(self.mst.lsave_lnum, self.mst.lsave_offs, 0x100)
            self.dumpnode(self.mst.lsave_lnum, self.mst.lsave_offs)
        except Exception as e:
            print(e)
        print("--lscan")
        try:
            self.vol.hexdump(self.mst.lscan_lnum, 0, 0x100)
            self.dumpnode(self.mst.lscan_lnum, 0)
        except Exception as e:
            print(e)

    class Cursor:
        """
        The Cursor represents a position in the b-tree.
        """
        def __init__(self, fs, stack):
            self.fs = fs
            self.stack = stack

        def next(self):
            """ move cursor to next entry """
            if not self.stack:
                # starting at 'eof'
                page = self.fs.root
                ix = 0
            else:
                page, ix = self.stack.pop()
                while self.stack and ix==len(page.branches)-1:
                    page, ix = self.stack.pop()
                if ix==len(page.branches)-1:
                    return
                ix += 1
            self.stack.append( (page, ix) )
            while page.level:
                page = self.fs.readnode(page.branches[ix].lnum, page.branches[ix].offs)
                ix = 0
                self.stack.append( (page, ix) )

        def prev(self):
            """ move cursor to next entry """
            if not self.stack:
                # starting at 'eof'
                page = self.fs.root
                ix = len(page.branches)-1
            else:
                page, ix = self.stack.pop()
                while self.stack and ix==0:
                    page, ix = self.stack.pop()
                if ix==0:
                    return
                ix -= 1
            self.stack.append( (page, ix) )
            while page.level:
                page = self.fs.readnode(page.branches[ix].lnum, page.branches[ix].offs)
                ix = len(page.branches)-1
                self.stack.append( (page, ix) )
        def eof(self):
            return len(self.stack)==0
        def __repr__(self):
            return "[%s]" % (",".join(str(_[1]) for _ in self.stack))

        def getkey(self):
            """
            Returns the key tuple for the current item
            """
            if self.stack:
                page, ix = self.stack[-1]
                return unpackkey(page.branches[ix].key)

        def getnode(self):
            """
            Returns the node object for the current item
            """
            if self.stack:
                page, ix = self.stack[-1]
                return self.fs.readnode(page.branches[ix].lnum, page.branches[ix].offs)


    def find(self, rel, key, root=None):
        """
        returns a cursor for the relation + key.

        ('lt', searchkey) searches for the highest ordered node with a key less than `searchkey`
        ('ge', searchkey) searches for the lowest ordered node with a key greater or equal to `searchkey`
        etc...

        """
        stack = []
        page = self.root if root is None else root

        while len(stack)<32:
            act, ix = page.find(packkey(key))
            stack.append( (page, ix) )
            if page.level==0:
                break
            page = self.readnode(page.branches[ix].lnum, page.branches[ix].offs)

        if len(stack)==32:
            raise Exception("tree too deep")

        cursor = self.Cursor(self, stack)

        """
        act                  rel:  | lt       le      eq        ge       gt
        (lt, 0)  key < 0           | None     None   None      pass     pass
        (eq, ix) key == ix         |  --      pass   pass      pass      ++
        (gt, ix) ix < key < ix+1   | pass     pass   None       ++       ++
        """

        if (act+rel) in ('gtlt', 'gtle', 'eqle', 'eqeq', 'eqge', 'ltge', 'ltgt'):
            return cursor
        if (act+rel) in ('ltlt', 'ltle', 'lteq', 'gteq'):
            return None
        if (act+rel) == 'eqlt':
            cursor.prev()
            return cursor
        if (act+rel) in ('eqgt', 'gtge', 'gtgt'):
            cursor.next()
            return cursor

        raise Exception("unexpected case")

    def setkey(self, key, node):
        pass
        #todo - adding a 


    def recursefiles(self, inum, path, filter = 1<<UbiFsDirEntry.TYPE_REGULAR, root=None):
        """
        Recursively yield all files below the directory with inode `inum`
        """
        startkey = (inum, UBIFS_DENT_KEY, 0)
        endkey = (inum, UBIFS_DENT_KEY+1, 0)
        if root is None:
            root = self.root
        c = self.find('ge', startkey, root)
        while not c.eof() and c.getkey() < endkey:
            ent = c.getnode()

            if filter & (1<<ent.type):
                yield ent.inum, path + [ent.name]
            if ent.type==ent.TYPE_DIRECTORY:
                # recurse into subdirs
                for x in self.recursefiles(ent.inum, path + [ent.name], filter, root):
                    yield x

            c.next()

    def exportfile(self, inum, fh, ubiname):
        """
        save file data from inode `inum` to the filehandle `fh`.

        the `ubiname` argument is not needed, except for printing useful error messages.
        """
        startkey = (inum, UBIFS_DATA_KEY, 0)
        endkey = (inum, UBIFS_DATA_KEY+1, 0)
        c = self.find('ge', startkey)

        savedlen = 0
        while not c.eof() and c.getkey() < endkey:
            dat = c.getnode()
            _, _, blocknum = c.getkey()

            fh.seek(UBIFS_BLOCKSIZE * blocknum)

            fh.write(dat.data)
            savedlen += len(dat.data)

            c.next()

        c = self.find('eq', (inum, UBIFS_INO_KEY, 0))
        inode = c.getnode()
        if savedlen > inode.size:
            print("WARNING: found more (%d bytes) for inode %05d, than specified in the inode(%d bytes) -- %s" % (savedlen, inum, inode.size, ubiname))
        elif savedlen < inode.size:
            # padding file with zeros
            fh.seek(inode.size)
            fh.truncate(inode.size)

    def findfile(self, path, inum = 1):
        """
        find the inode of the given `path`, starting in the directory specified by `inum`

        `path` must be a list of path elements. ( so not a '/' separated path string )
        """
        itype = UbiFsDirEntry.TYPE_DIRECTORY
        for part in path:
            if itype!=UbiFsDirEntry.TYPE_DIRECTORY:
                # not a directory
                return None
            c = self.find('eq', (inum, UBIFS_DENT_KEY, namehash(part)))
            if not c or c.eof():
                # not found
                return None
            dirent = c.getnode()
            inum, itype = dirent.inum, dirent.type
        return inum


def modestring(mode):
    """
    return a "-rw-r--r--" style mode string
    """
    # 4 bits type
    # 3 bits suid/sgid/sticky
    # 3 bits owner perm
    # 3 bits group perm
    # 3 bits other perm
    typechar = "?pc?d?b?-?l?s???"

    def rwx(bits, extra, xchar):
        rflag = "-r"[(bits>>2)&1]
        wflag = "-w"[(bits>>1)&1]
        xflag = ("-x" + xchar.upper() + xchar.lower())[(bits&1)+2*extra]

        return rflag + wflag + xflag

    return typechar[(mode>>12)&15] + rwx((mode>>6)&7, (mode>>11)&1, 's') + rwx((mode>>3)&7, (mode>>10)&1, 's') + rwx(mode&7, (mode>>9)&1, 't')


def timestring(t):
    return datetime.datetime.utcfromtimestamp(t).strftime("%Y-%m-%d %H:%M:%S")


def processvolume(vol, volumename, args):
    """
    Perform actions specified by `args` on `vol`.

    `vol` can be either a RawVolume ( an image file containing only the filesystem,
    no flash block management layer.

    Or a UbiVolume, with the block management layer.
    """
    fs = UbiFs(vol, args.masteroffset)
    if args.verbose:
        fs.dumpfs()

    root = fs.root
    if args.root:
        lnum, offset = args.root.split(':', 1)
        lnum = int(lnum, 16)
        offset = int(offset, 16)
        root = fs.readnode(lnum, offset)

    if args.hexdump and isinstance(vol, RawVolume):
        vol.hexdump(*args.hexdump)
    if args.nodedump:
        fs.dumpnode(*args.nodedump)

    if args.dumptree:
        fs.printrecursive(root)
        if args.verbose:
            fs.printmbitems()
    if args.savedir:
        savedir = args.savedir.encode(args.encoding)

        count = 0
        for inum, path in fs.recursefiles(1, [], UbiFsDirEntry.ALL_TYPES, root=root):
            c = fs.find('eq', (inum, UBIFS_INO_KEY, 0))
            inode = c.getnode()
            typ = inode.nodetype()

            fullpath = os.path.join(*[savedir, volumename] + path)
            try:
                if typ ==  inode.ITYPE_FIFO:
                    os.mkfifo(fullpath)
                elif typ ==  inode.ITYPE_SOCKET:
                    import socket as s
                    sock = s.socket(s.AF_UNIX)
                    sock.bind(fullpath)
                elif typ == inode.ITYPE_SYMLINK:
                    os.symlink(inode.data, fullpath)
                elif typ == inode.ITYPE_DIRECTORY:
                    os.makedirs(fullpath)
                elif typ == inode.ITYPE_REGULAR:
                    with open(fullpath, "wb") as fh:
                        fs.exportfile(inum, fh, os.path.join(*path))
                elif typ in (inode.ITYPE_BLOCKDEV, inode.ITYPE_CHARDEV):
                    try:
                        devnum = os.makedev(*inode.devnum())
                        if devnum < 0:
                            devnum += 0x100000000
                        os.mknod(fullpath, inode.mode, devnum)
                    except PermissionError as e:
                        # silently ignoring permission error
                        pass
                else:
                    if args.verbose:
                        print("UNKNOWN inode type: %d" % typ)
                    continue
            except OSError as e:
                if e.errno != errno.EEXIST:
                    raise

            if args.preserve and typ != inode.ITYPE_SYMLINK:
                # note: we have to do this after closing the file, since the close after exportfile
                # will update the last-modified time.
                os.utime(fullpath, (inode.atime(), inode.mtime()))
                os.chmod(fullpath, inode.mode)

            count += 1
        print("saved %d files" % count)

    if args.listfiles:
        for inum, path in fs.recursefiles(1, [], UbiFsDirEntry.ALL_TYPES, root=root):
            c = fs.find('eq', (inum, UBIFS_INO_KEY, 0))
            inode = c.getnode()

            if inode.nodetype() in (inode.ITYPE_CHARDEV, inode.ITYPE_BLOCKDEV):   # char or block dev.
                sizestr = "%d,%4d" % inode.devnum()
            else:
                sizestr = str(inode.size)

            if inode.nodetype() == inode.ITYPE_SYMLINK:
                linkdata = inode.data
                if args.encoding:
                    linkdata = linkdata.decode(args.encoding, 'ignore')
                linkstr = " -> %s" % linkdata
            else:
                linkstr = ""

            filename = b"/".join(path)
            if args.encoding:
                filename = filename.decode(args.encoding, 'ignore')
            print("%s %2d %-5d %-5d %10s %s %s%s" % (modestring(inode.mode), inode.nlink, inode.uid, inode.gid, sizestr, timestring(inode.mtime_sec), filename, linkstr))

    for srcfile in args.cat:
        if len(args.cat)>1:
            print("==>", srcfile, "<==")
        inum = fs.findfile(srcfile.lstrip('/').split('/'))
        if inum:
            fs.exportfile(inum, SeekableStdout(), srcfile)
            if len(args.cat)>1:
                print()
        else:
            print("Not found")


def processblocks(fh, args):
    """
    Perform operations on a UbiBlocks type image: starting with bytes 'UBI#'
    """
    blks = UbiBlocks(fh)
    if args.verbose:
        print("===== block =====")
        blks.dumpvtbl()
    if args.hexdump:
        if args.volume is None:
            blks.hexdump(*args.hexdump)
        else:
            vol = blks.getvolume(args.volume)
            vol.hexdump(*args.hexdump)

    for volid in range(128):
        vrec = blks.getvrec(volid)
        if vrec.empty():
            continue
        vol = blks.getvolume(volid)

        try:
            print("== volume %s ==" % vrec.name)

            processvolume(vol, vrec.name, args)
        except Exception as e:
            print("E: %s" % e)
            if args.debug:
                raise

##################################################
#     raw hexdumper
def findpattern(data, pattn, blocksize):
    o = 0
    while o<len(data):
        p = data.find(pattn, o)
        if p==-1:
            break
        if (p % blocksize)==0:
            yield p
        else:
            print("%08x: %x  - %s" % (p, p % blocksize, data[p:p+4]))
        o = p+1


def raw_ec_dump(o, data):
    # note: ec blocks should be all the same.
    data = data.rstrip(b'\xff')

    if len(data)!=64:
        print("%08x: %s" % (o, b2a_hex(data.rstrip(b'\xff'))))
        return
    m, v, ec, vidofs, datofs, iseq, zero, crc = struct.unpack(">4sLQLLL32sL", data)
    print("%08x: %s %08x %010x  %08x %08x %08x %s %08x" % (o, m, v, ec, vidofs, datofs, iseq, zero, crc))


def raw_vid_dump(o, data):
    i = 0
    while i < len(data):
        print("%08x:   %s" % (o+i, data[i:i+0xAC]))
        i += 0xAC


def raw_vhdr_dump(o, data):
    data = data.rstrip(b'\xff')
    data2 = b''
    o2 = 0
    if len(data)!=64:
        data2 = data[64:].lstrip(b'\xff')
        o2 = o + data.find(data2)
        data = data[:64]

    m,  v, vt, cf, compat,  volid, lnum, zero1, dsize, usedebs, pad, dcrc, zero2, sqnum, zero3, hcrc = struct.unpack(">4s4BLL4s4L4sQ12sL", data)

    print("%08x: %s %d %d %d %d %08x %08x %s %08x %08x %08x %08x %s %010x %s %08x" % (o, m,  v, vt, cf, compat,  volid, lnum, zero1, dsize, usedebs, pad, dcrc, zero2, sqnum, zero3, hcrc))
    if len(data2)==0xAC*0x80:
        raw_vid_dump(o2, data2)


def raw_node_dump(o, data):
    ch = UbiFsCommonHeader()
    ch.parse(data[:24])

    node = ch.getnode()
    try:
        node.parse(data[24:])
    except Exception as e:
        pass

    try:
        print("%08x: %s - %s" % (o, repr(ch), repr(node)))
    except Exception as e:
        print("%08x: %s" % (o, b2a_hex(data)))


def rawhexdump(fh, args):
    data = fh.read()
   
    ofs = []
    for pattn, bs in ((b'UBI#', 64), (b'UBI!', 64), (b'\x31\x18\x10\x06', 8)):
        for o in findpattern(data, pattn, bs):
            ofs.append( (o, pattn) )

    ofs = sorted(ofs, key=lambda o: o[0])
    print("found %d magic numbers" % len(ofs))

    ofs.append( (len(data), None) )

    for (o0, p), (o1, _) in zip(ofs, ofs[1:]):
        if p==b'UBI#':
            raw_ec_dump(o0, data[o0:o1])
        elif p==b'UBI!':
            raw_vhdr_dump(o0, data[o0:o1])
        elif p==b'\x31\x18\x10\x06':
            raw_node_dump(o0, data[o0:o1])
        else:
            print("%08x: %s" % (o0, b2a_hex(data[o0:o1])))
       

##################################################
def processfile(fn, args):
    with open(fn, "rb") as fh:
        if args.rawdump:
            rawhexdump(fh, args)
        else:
            magic = fh.read(4)
            if magic == b'UBI#':
                processblocks(fh, args)
            elif magic == b'\x31\x18\x10\x06':
                processvolume(RawVolume(fh), b"raw", args)
            else:
                print("Unknown file type")


def main():
    parser = argparse.ArgumentParser(description='UBIFS dumper.')
    parser.add_argument('--savedir', '-s',  type=str, help="save files in all volumes to the specified directory", metavar='DIRECTORY')
    parser.add_argument('--preserve', '-p',  action='store_true', help="preserve permissions and timestamps")
    parser.add_argument('--cat', '-c',  type=str, action="append", help="extract a single file to stdout", metavar='FILE', default=[])
    parser.add_argument('--listfiles', '-l',  action='store_true', help="list directory contents")
    parser.add_argument('--dumptree', '-d',  action='store_true', help="dump the filesystem b-tree contents")
    parser.add_argument('--verbose', '-v',  action='count', help="print extra info")
    parser.add_argument('--debug',  action='store_true', help="abort on exceptions")
    parser.add_argument('--encoding', '-e',  type=str, help="filename encoding, default=utf-8", default='utf-8')
    parser.add_argument('--masteroffset', '-m',  type=str, help="Which master node to use.")
    parser.add_argument('--root', '-R',  type=str, help="Which Root node to use (hexlnum:hexoffset).")
    parser.add_argument('--rawdump', action='store_true', help="Raw hexdump of entire volume.") 
    parser.add_argument('--volume', type=str, help="which volume to hexdump")
    parser.add_argument('--hexdump', type=str, help="hexdump part of a volume/leb[/ofs[/size]]", metavar="LEB:OFF:N") 
    parser.add_argument('--nodedump', type=str, help="dump specific node at volume/leb[/ofs]", metavar="LEB:OFF") 
    parser.add_argument('FILES',  type=str, nargs='+', help="list of ubi images to use")
    args = parser.parse_args()

    if args.masteroffset:
        args.masteroffset = [int(_,0) for _ in args.masteroffset.split(':')]
    if args.volume:
        args.volume = int(args.volume, 0)
    if args.hexdump:
        args.hexdump = [int(_, 0) for _ in args.hexdump.split(":")]
        if len(args.hexdump) == 1:
            args.hexdump.append(0)
        if len(args.hexdump) == 2:
            args.hexdump.append(0x100)

    if args.nodedump:
        args.nodedump = [int(_, 0) for _ in args.nodedump.split(":")]
        if len(args.nodedump) == 1:
            args.nodedump.append(0)

    for fn in args.FILES:
        print("==>", fn, "<==")
        try:
            processfile(fn, args)
        except Exception as e:
            print("ERROR", e)
            if args.debug:
                raise


if __name__ == '__main__':
    main()
