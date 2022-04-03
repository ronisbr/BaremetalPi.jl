# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#     Define the types.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

################################################################################
#                                     I2C
################################################################################

mutable struct I2CDEV
    io::IOStream
    funcs::Vector{Symbol}

    # Buffers used when reading from or writing to the I2C to avoid allocations.
    bbyte::Vector{UInt8}
    bword::Vector{UInt16}
    bblock::Vector{UInt8}

    function I2CDEV(io, funcs)
        return new(
            io,
            funcs,
            UInt8[0x00],
            UInt16[0x00],
            zeros(UInt8, I2C_SMBUS_BLOCK_MAX + 1)
        )
    end
end

struct struct_i2c_smbus_ioctl_data{T}
    read_write::__u8
    command::__u8
    size::__u32
    data::T

    function struct_i2c_smbus_ioctl_data(read_write, command, size, data::T) where T
        return new{T}(__u8(read_write), __u8(command), __u32(size), data)
    end
end

################################################################################
#                                     SPI
################################################################################

struct struct_spi_ioc_transfer
    tx_buf::__u64
    rx_buf::__u64

    len::__u32
    speed_hz::__u32

    delay_usecs::__u16
    bits_per_word::__u8
    cs_change::__u8
    tx_nbits::__u8
    rx_nbits::__u8
    pad::__u16
end

function struct_spi_ioc_transfer(
    tx_buf,
    rx_buf,
    len,
    speed_hz,
    delay_usecs,
    bits_per_word,
    cs_change
)
    return struct_spi_ioc_transfer(
        __u64(tx_buf),
        __u64(rx_buf),
        __u32(len),
        __u32(speed_hz),
        __u16(delay_usecs),
        __u8(bits_per_word),
        __u8(cs_change),
        __u8(0),
        __u8(0),
        __u16(0)
    )
end

mutable struct SPIDEV
    io::IOStream
    max_speed_hz::Int
    bits_per_word::Int

    # Buffers to reduce the allocation.
    bdescs::Vector{struct_spi_ioc_transfer}
end

function SPIDEV(io, max_speed_hz, bits_per_word)
    return SPIDEV(
        io,
        max_speed_hz,
        bits_per_word,
        Vector{struct_spi_ioc_transfer}(undef, _SPI_BUFFER_SIZE)
    )
end

################################################################################
#                                    Global
################################################################################

"""
    Objects

This structure stores global objects, such as the IO file and the memory
mappings.
"""
mutable struct Objects
    # GPIO
    # ==========================================================================
    gpio_init::Bool
    gpiomem_io::IOStream
    gpiomem_map::Vector{UInt32}

    # I2C
    # ==========================================================================
    i2c_init::Bool
    i2cdev::Vector{I2CDEV}

    # SPI
    # ==========================================================================
    spi_init::Bool
    spidev::Vector{SPIDEV}
    spi_buffer_size::Int
end

const objects = Objects(
    false,
    IOStream(""),
    Vector{UInt32}(undef, 0),
    false,
    Vector{I2CDEV}(undef, 0),
    false,
    Vector{SPIDEV}(undef, 0),
    4096
)
