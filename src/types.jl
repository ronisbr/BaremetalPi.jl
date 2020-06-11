# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#     Define the types.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

################################################################################
#                                     SPI
################################################################################

mutable struct SPIDEV
    io::IOStream
    max_speed_hz::Int
    bits_per_word::Int
end

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

struct_spi_ioc_transfer(tx_buf, rx_buf, len, speed_hz, delay_usecs,
                        bits_per_word, cs_change) =
    struct_spi_ioc_transfer(__u64(tx_buf), __u64(rx_buf), __u32(len),
                            __u32(speed_hz), __u16(delay_usecs),
                            __u8(bits_per_word), __u8(cs_change), __u8(0),
                            __u8(0), __u16(0))

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

    # SPI
    # ==========================================================================
    spi_init::Bool
    spidev::Vector{SPIDEV}
    spi_buffer_size::Int
end

const objects = Objects(false, IOStream(""), Vector{UInt32}(undef,0),
                        false, Vector{SPIDEV}(undef, 0), 4096)
