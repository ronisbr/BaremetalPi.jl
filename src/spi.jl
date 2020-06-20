# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#     Functions to manage the SPI.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export init_spi, spi_transfer, spi_transfer!

################################################################################
#                                Initialization
################################################################################

"""
    init_spi(devices; mode = 0, max_speed_hz = 4_000_000, bits_per_word = 8)

Initialize the SPI devices. `devices` can be a string with the path to `spidev`
or a vector of strings with a set of SPI devices that will be initialized.

# Keywords

* `mode`: Set the mode of the SPI. (**Default** = 0)
* `max_speed_hz`: Maximum allowed speed in SPI communication [Hz].
                  (**Default** = 4_000_000)
* `bits_per_word`: Number of bits per word in SPI communication.
                   (**Default** = 8)

Notice that all keywords can be a `Integer`, when the configuration will be
applied to all SPI devices, or a `Vector` of `Integers`, when different
configurations can be applied to the initialized devices.

"""
@inline init_spi(devices::String; kwargs...) = init_spi([devices]; kwargs...)

function init_spi(devices::AbstractVector{String};
                  mode::Union{Integer,Vector{Integer}} = 0,
                  max_speed_hz::Union{Integer,Vector{Integer}} = 4_000_000,
                  bits_per_word::Union{Integer,Vector{Integer}} = 8)

    # Number of devices that the user wants to initialize.
    num_init_devices = length(devices)

    # If the arguments are not vectors, then transform them to vectors
    # considering the size of `devices`.
    if !(typeof(mode) <: AbstractVector)
        mode = [mode for _ = 1:num_init_devices]
    end

    if !(typeof(max_speed_hz) <: AbstractVector)
        max_speed_hz = [max_speed_hz for _ = 1:num_init_devices]
    end

    if !(typeof(bits_per_word) <: AbstractVector)
        bits_per_word = [bits_per_word for _ = 1:num_init_devices]
    end

    # If we have already initialized, then close all the devices first.
    objects.spi_init && close_spi()

    # Initialize each device.
    spidev = Vector{SPIDEV}(undef, 0)

    @inbounds for i = 1:num_init_devices
        @assert (mode[i] ≥ 0) error("Invalid SPI mode.")
        @assert (max_speed_hz[i] > 0) error("Invalid maximum speed [Hz].")
        @assert (bits_per_word[i] > 0) error("Invalid number of bits per word.")

        try
            # Open the device
            # ==================================================================

            io = open(devices[i], "w+")

            # Configure SPI interface
            # ==================================================================

            _ioctl(io, SPI_IOC_WR_MODE, Ref(mode[i]))
            _ioctl(io, SPI_IOC_RD_MODE, Ref(mode[i]))

            _ioctl(io, SPI_IOC_WR_BITS_PER_WORD, Ref(bits_per_word[i]))
            _ioctl(io, SPI_IOC_RD_BITS_PER_WORD, Ref(bits_per_word[i]))

            _ioctl(io, SPI_IOC_WR_MAX_SPEED_HZ, Ref(max_speed_hz[i]))
            _ioctl(io, SPI_IOC_RD_MAX_SPEED_HZ, Ref(max_speed_hz[i]))

            # Pack values
            # ==================================================================
            spidev_i = SPIDEV(io, max_speed_hz[i], bits_per_word[i])
            push!(spidev, spidev_i)
        catch
            error("Could not open `$(devices[i])`. Make sure you have the required permissions.")
        end
    end

    # Get the size of SPI buffer.
    buffer_size = parse(Int, read("/sys/module/spidev/parameters/bufsiz", String))

    objects.spidev          = spidev
    objects.spi_buffer_size = buffer_size
    objects.spi_init        = true

    return nothing
end

"""
    close_spi()

Close all SPI connections.

"""
function close_spi()
    if objects.spi_init
        @inbounds for d in objects.spidev
            close(d.io)
        end
        objects.spidev = Vector{SPIDEV}(undef, 0)
        objects.spi_init = false
    end

    return nothing
end

################################################################################
#                                   Transfer
################################################################################

"""
    spi_transfer(devid, tx_buf; kwargs...)

Execute a full duplex transfer to SPI device `devid`. `devid` is the ID of the
SPI device considering the initialization order when the function `init_spi` was
called.

`tx_buf` can be a vector of `Integer`, in which only one message will be sent,
or a vector of vectors of `Integer`, in which multiple messages will be sent.

The result is returned in an object with the same type of `tx_buf` together with
the number of words received.

# Keywords

The same keywords of `spi_transfer!` can be used.

"""
function spi_transfer(devid::Integer, tx_buf::AbstractVector{T}; kwargs...) where
    T<:Integer

    # Allocate the vector that will hold the returned words.
    rx_buf = zeros(T, length(tx_buf))

    # Perform the transfer.
    ret = spi_transfer!(devid, tx_buf, rx_buf; kwargs...)

    return rx_buf, ret
end

function spi_transfer(devid::Integer, tx_buf::AbstractVector{T}; kwargs...) where
    T<:Vector{U} where U<:Integer

    # Allocate the vectors that will hold the returned words.
    rx_buf = zeros.(U, length.(tx_buf))

    # Perform the transfer.
    ret = spi_transfer!(devid, tx_buf, rx_buf; kwargs...)

    return rx_buf, ret
end

"""
    spi_transfer!(devid, tx_buf, rx_buf; kwargs...)

Execute a full duplex transfer to SPI device `devid`. `devid` is the ID of the
SPI device considering the initialization order when the function `init_spi` was
called.

`tx_buf` can be a vector of `Integer`, in which only one message will be sent,
or a vector of vectors of `Integer`, in which multiple messages will be sent.

The received data will be stored in `rx_buf` that must have the same type of
`tx_buf` and enough size.

This function returns the number of bytes received.

!!! warning

    When only one message is transmitted, then this function does not allocate.
    On the other hand, if multiple messages are transmitted, then this function
    must allocate a vector of `struct_spi_ioc_transfer`.

# Keywords

* `max_speed_hz`: If > 0, then override the default maximum transfer speed with
                  this value [Hz]. (**Default** = 0)
* `delay_usecs`: If ≥ 0, then override the default delay with this value.
                 (**Default** = -1)
* `bits_per_word`: If > 0, then override the number of bits per word with this
                   value. (**Default** = 0)
* `cs_change`: If `false`, the deselect the device at the end of the transfer.

"""
function spi_transfer!(devid::Integer,
                       tx_buf::AbstractVector{T},
                       rx_buf::AbstractVector{T};
                       max_speed_hz::Integer = 0,
                       delay_usecs::Integer = -1,
                       bits_per_word::Integer = 8,
                       cs_change::Bool = false) where T<:Vector{U} where U <:Integer

    @assert objects.spi_init "SPI not initialized. Run init_spi()."
    @assert (0 < devid ≤ length(objects.spidev)) "SPI device ID is out of bounds."

    spidev = objects.spidev[devid]

    # Number of messages to be transmitted.
    num_msgs = length(tx_buf)

    @assert (length(rx_buf) ≥ num_msgs) "The number of buffers in `rx_buf` must be equal or bigger than the number of buffers in `tx_buf`."

    # Check default parameters.
    max_speed_hz  ≤ 0 && (max_speed_hz  = spidev.max_speed_hz)
    delay_usecs   < 0 && (delay_usecs   = 0)
    bits_per_word ≤ 0 && (bits_per_word = spidev.bits_per_word)

    # Allocate the vector with the description of the transfer.
    descs = Vector{struct_spi_ioc_transfer}(undef, num_msgs)

    @inbounds for i = 1:num_msgs
        msg_size = length(tx_buf[i])

        @assert (msg_size*bits_per_word ≤ objects.spi_buffer_size*8) "The message to be transmitted is larger than the SPI buffer."
        @assert (length(rx_buf[i]) ≥ msg_size) "The length of `rx_buf[i]` must be equal or bigger than that of `tx_buf[i]`."

        # Create the structure that contains the information of the SPI transfer.
        descs[i] = struct_spi_ioc_transfer(pointer(tx_buf[i]),
                                           pointer(rx_buf[i]),
                                           # In SPI, the number of transmitted
                                           # and received words are always the
                                           # same.
                                           msg_size*sizeof(U),
                                           max_speed_hz,
                                           delay_usecs,
                                           bits_per_word,
                                           cs_change)

    end

    # Execute the transfer.
    return _ioctl(fd(spidev.io), SPI_IOC_MESSAGE(num_msgs), descs)
end

function spi_transfer!(devid::Integer,
                       tx_buf::AbstractVector{T},
                       rx_buf::AbstractVector{T};
                       max_speed_hz::Integer = 0,
                       delay_usecs::Integer = -1,
                       bits_per_word::Integer = 8,
                       cs_change::Bool = false) where T<:Integer

    @assert objects.spi_init "SPI not initialized. Run init_spi()."
    @assert (0 < devid ≤ length(objects.spidev)) "SPI device ID is out of bounds."

    spidev = objects.spidev[devid]

    # Check default parameters.
    max_speed_hz  ≤ 0 && (max_speed_hz  = spidev.max_speed_hz)
    delay_usecs   < 0 && (delay_usecs   = 0)
    bits_per_word ≤ 0 && (bits_per_word = spidev.bits_per_word)

    msg_size = length(tx_buf)

    @assert (msg_size*bits_per_word ≤ objects.spi_buffer_size*8) "The message to be transmitted is larger than the SPI buffer."
    @assert (length(rx_buf) ≥ msg_size) "The length of `rx_buf` must be equal or bigger than that of `tx_buf`."

    # Create the structure that contains the information of the SPI transfer.
    desc = struct_spi_ioc_transfer(pointer(tx_buf),
                                   pointer(rx_buf),
                                   # In SPI, the number of transmitted and
                                   # received words are always the same.
                                   msg_size*sizeof(T),
                                   max_speed_hz,
                                   delay_usecs,
                                   bits_per_word,
                                   cs_change)

    # Execute the transfer.
    return _ioctl(fd(spidev.io), SPI_IOC_MESSAGE(1), Ref(desc))
end
