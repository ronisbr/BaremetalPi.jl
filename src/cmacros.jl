# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#     Define the functions that replica some required C macros.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

################################################################################
#                                    IOCTL
################################################################################

# Constants and macros obtained from `linux/include/uapi/asm-generic/ioctl.h`
# tag 4.19.

const _IOC_NRBITS   = 8
const _IOC_TYPEBITS = 8

const _IOC_SIZEBITS = 14
const _IOC_DIRBITS  = 2

const _IOC_NRMASK   = ((1 << _IOC_NRBITS)-1)
const _IOC_TYPEMASK = ((1 << _IOC_TYPEBITS)-1)
const _IOC_SIZEMASK = ((1 << _IOC_SIZEBITS)-1)
const _IOC_DIRMASK  = ((1 << _IOC_DIRBITS)-1)

const _IOC_NRSHIFT   = 0
const _IOC_TYPESHIFT = (_IOC_NRSHIFT+_IOC_NRBITS)
const _IOC_SIZESHIFT = (_IOC_TYPESHIFT+_IOC_TYPEBITS)
const _IOC_DIRSHIFT  = (_IOC_SIZESHIFT+_IOC_SIZEBITS)

const _IOC_WRITE = UInt32(1)
const _IOC_READ  = UInt32(2)

_IOC(dir,type,nr,size) = (dir  << _IOC_DIRSHIFT)  |
                         (type << _IOC_TYPESHIFT) |
                         (nr   << _IOC_NRSHIFT)   |
                         (size << _IOC_SIZESHIFT)

_IOC_TYPECHECK(t)  = sizeof(t)
_IOW(type,nr,size) = _IOC(_IOC_WRITE, type, nr, _IOC_TYPECHECK(size))
_IOR(type,nr,size) = _IOC(_IOC_READ,  type, nr, _IOC_TYPECHECK(size))

################################################################################
#                                     SPI
################################################################################

# Constants and macros obtained from `linux/include/linux/spi/spidev.h` tag
# v4.19.

const SPI_CPHA      = 0x01
const SPI_CPOL      = 0x02

const SPI_MODE_0    = (0|0)
const SPI_MODE_1    = (0|SPI_CPHA)
const SPI_MODE_2    = (SPI_CPOL|0)
const SPI_MODE_3    = (SPI_CPOL|SPI_CPHA)

const SPI_CS_HIGH   = 0x04
const SPI_LSB_FIRST = 0x08
const SPI_3WIRE     = 0x10
const SPI_LOOP      = 0x20
const SPI_NO_CS     = 0x40
const SPI_READY     = 0x80

const SPI_IOC_MAGIC = UInt('k')

SPI_MSGSIZE(N) =
    ( N*sizeof(struct_spi_ioc_transfer) < (1 << _IOC_SIZEBITS) ) ?
        N*sizeof(struct_spi_ioc_transfer) : 0

SPI_IOC_MESSAGE(N) = _IOW(SPI_IOC_MAGIC, 0, NTuple{SPI_MSGSIZE(N), Cchar})

const SPI_IOC_RD_MODE = _IOR(SPI_IOC_MAGIC, 1, __u8)
const SPI_IOC_WR_MODE = _IOW(SPI_IOC_MAGIC, 1, __u8)

const SPI_IOC_RD_LSB_FIRST = _IOR(SPI_IOC_MAGIC, 2, __u8)
const SPI_IOC_WR_LSB_FIRST = _IOW(SPI_IOC_MAGIC, 2, __u8)

const SPI_IOC_RD_BITS_PER_WORD = _IOR(SPI_IOC_MAGIC, 3, __u8)
const SPI_IOC_WR_BITS_PER_WORD = _IOW(SPI_IOC_MAGIC, 3, __u8)

const SPI_IOC_RD_MAX_SPEED_HZ = _IOR(SPI_IOC_MAGIC, 4, __u32)
const SPI_IOC_WR_MAX_SPEED_HZ = _IOW(SPI_IOC_MAGIC, 4, __u32)
