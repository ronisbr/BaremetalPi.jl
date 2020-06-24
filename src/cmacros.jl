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

_IOW(type,nr,size) = _IOC(_IOC_WRITE, type, nr, size)
_IOR(type,nr,size) = _IOC(_IOC_READ,  type, nr, size)

################################################################################
#                                     I2C
################################################################################

# Constants and macros obtained from `linux/include/uapi/linux/i2c-dev.h` tag
# v4.19.

const I2C_SLAVE       = 0x0703
const I2C_SLAVE_FORCE = 0x0706
const I2C_TENBIT      = 0x0704
const I2C_FUNCS       = 0x0705
const I2C_RDWR        = 0x0707
const I2C_PEC         = 0x0708
const I2C_SMBUS       = 0x0720

# Functionality
# ==============================================================================

# Constants and macros obtained from `linux/include/uapi/linux/i2c.h` tag v4.19.

const I2C_FUNC_I2C                    = 0x00000001
const I2C_FUNC_10BIT_ADDR             = 0x00000002
const I2C_FUNC_PROTOCOL_MANGLING      = 0x00000004
const I2C_FUNC_SMBUS_PEC              = 0x00000008
const I2C_FUNC_NOSTART                = 0x00000010
const I2C_FUNC_SLAVE                  = 0x00000020
const I2C_FUNC_SMBUS_BLOCK_PROC_CALL  = 0x00008000
const I2C_FUNC_SMBUS_QUICK            = 0x00010000
const I2C_FUNC_SMBUS_READ_BYTE        = 0x00020000
const I2C_FUNC_SMBUS_WRITE_BYTE       = 0x00040000
const I2C_FUNC_SMBUS_READ_BYTE_DATA   = 0x00080000
const I2C_FUNC_SMBUS_WRITE_BYTE_DATA  = 0x00100000
const I2C_FUNC_SMBUS_READ_WORD_DATA   = 0x00200000
const I2C_FUNC_SMBUS_WRITE_WORD_DATA  = 0x00400000
const I2C_FUNC_SMBUS_PROC_CALL        = 0x00800000
const I2C_FUNC_SMBUS_READ_BLOCK_DATA  = 0x01000000
const I2C_FUNC_SMBUS_WRITE_BLOCK_DATA = 0x02000000
const I2C_FUNC_SMBUS_READ_I2C_BLOCK   = 0x04000000
const I2C_FUNC_SMBUS_WRITE_I2C_BLOCK  = 0x08000000
const I2C_FUNC_SMBUS_HOST_NOTIFY      = 0x10000000

const  I2C_FUNC_SMBUS_BYTE       = (I2C_FUNC_SMBUS_READ_BYTE |
                                    I2C_FUNC_SMBUS_WRITE_BYTE)
const  I2C_FUNC_SMBUS_BYTE_DATA  = (I2C_FUNC_SMBUS_READ_BYTE_DATA |
                                    I2C_FUNC_SMBUS_WRITE_BYTE_DATA)
const  I2C_FUNC_SMBUS_WORD_DATA  = (I2C_FUNC_SMBUS_READ_WORD_DATA |
                                    I2C_FUNC_SMBUS_WRITE_WORD_DATA)
const  I2C_FUNC_SMBUS_BLOCK_DATA = (I2C_FUNC_SMBUS_READ_BLOCK_DATA |
                                    I2C_FUNC_SMBUS_WRITE_BLOCK_DATA)
const  I2C_FUNC_SMBUS_I2C_BLOCK  = (I2C_FUNC_SMBUS_READ_I2C_BLOCK |
                                    I2C_FUNC_SMBUS_WRITE_I2C_BLOCK)

const I2C_FUNC_SMBUS_EMUL = (I2C_FUNC_SMBUS_QUICK |
                             I2C_FUNC_SMBUS_BYTE |
                             I2C_FUNC_SMBUS_BYTE_DATA |
                             I2C_FUNC_SMBUS_WORD_DATA |
                             I2C_FUNC_SMBUS_PROC_CALL |
                             I2C_FUNC_SMBUS_WRITE_BLOCK_DATA |
                             I2C_FUNC_SMBUS_I2C_BLOCK |
                             I2C_FUNC_SMBUS_PEC)

const I2C_SMBUS_BLOCK_MAX        = UInt8(32)

const I2C_SMBUS_READ             = 0x01
const I2C_SMBUS_WRITE            = 0x00

const I2C_SMBUS_QUICK            = UInt32(0)
const I2C_SMBUS_BYTE             = UInt32(1)
const I2C_SMBUS_BYTE_DATA        = UInt32(2)
const I2C_SMBUS_WORD_DATA        = UInt32(3)
const I2C_SMBUS_PROC_CALL        = UInt32(4)
const I2C_SMBUS_BLOCK_DATA       = UInt32(5)
const I2C_SMBUS_I2C_BLOCK_BROKEN = UInt32(6)
const I2C_SMBUS_BLOCK_PROC_CALL  = UInt32(7)
const I2C_SMBUS_I2C_BLOCK_DATA   = UInt32(8)

################################################################################
#                                     SPI
################################################################################

# Constants and macros obtained from `linux/include/uapi/linux/spi/spidev.h` tag
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

# In the past, we were using `NTuple{SPI_MSGSIZE(N), Cchar}` to create a type so
# that the function `_IOC_TYPECHECK(t) = sizeof(t)` could retrieve the correct
# size. However, this was causing 3 allocations. Thus, the system was simplified
# to avoid this. Now, the functions `_IOR` and `_IOW` must receive the size
# instead of the type as it was coded in the Kernel source.
SPI_IOC_MESSAGE(N) = _IOW(SPI_IOC_MAGIC, 0, sizeof(Cchar)*SPI_MSGSIZE(N))

const SPI_IOC_RD_MODE = _IOR(SPI_IOC_MAGIC, 1, sizeof(__u8))
const SPI_IOC_WR_MODE = _IOW(SPI_IOC_MAGIC, 1, sizeof(__u8))

const SPI_IOC_RD_LSB_FIRST = _IOR(SPI_IOC_MAGIC, 2, sizeof(__u8))
const SPI_IOC_WR_LSB_FIRST = _IOW(SPI_IOC_MAGIC, 2, sizeof(__u8))

const SPI_IOC_RD_BITS_PER_WORD = _IOR(SPI_IOC_MAGIC, 3, sizeof(__u8))
const SPI_IOC_WR_BITS_PER_WORD = _IOW(SPI_IOC_MAGIC, 3, sizeof(__u8))

const SPI_IOC_RD_MAX_SPEED_HZ = _IOR(SPI_IOC_MAGIC, 4, sizeof(__u32))
const SPI_IOC_WR_MAX_SPEED_HZ = _IOW(SPI_IOC_MAGIC, 4, sizeof(__u32))
