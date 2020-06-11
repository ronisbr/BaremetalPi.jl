SPI
===

## Initialization

Before any operations related to SPI, one the following function must be called
to initialize the system:

```julia
init_spi(devices::String; kwargs...); kwargs...
init_spi(devices::AbstractVector{String}; kwargs...
```

These functions initialize the SPI devices. `devices` can be a string with the
path to `spidev` or a vector of strings with a set of SPI devices that will be
initialized.

The following keywords are supported:

* `mode`: Set the mode of the SPI. (**Default** = 0)
* `max_speed_hz`: Maximum allowed speed in SPI communication [Hz].
                  (**Default** = 4000000)
* `bits_per_word`: Number of bits per word in SPI communication.
                   (**Default** = 8)

Notice that all keywords can be a `Integer`, when the configuration will be
applied to all SPI devices, or a `Vector` of `Integers`, when different
configurations can be applied to the initialized devices.

!!! note

    These functions open the device(s) `/dev/spidevX.X` passed to the argument
    `devices`. Thus, make sure that the user has permissions to read and write
    this file.

```julia-repl
julia> init_spi("/dev/spidev0.0")

julia> init_spi(["/dev/spiddev0.0", "/dev/spidev0.1"])

julia> init_spi("/dev/spidev0.0", max_speed_hz = 1000)

```

### Modes

The SPI mode can be selected using the following constants that were obtained
from `spidev.h` (Linux 4.19 tree):

```julia
BaremetalPi.SPI_CPHA      = 0x01
BaremetalPi.SPI_CPOL      = 0x02

BaremetalPi.SPI_MODE_0    = (0|0)
BaremetalPi.SPI_MODE_1    = (0|SPI_CPHA)
BaremetalPi.SPI_MODE_2    = (SPI_CPOL|0)
BaremetalPi.SPI_MODE_3    = (SPI_CPOL|SPI_CPHA)

BaremetalPi.SPI_CS_HIGH   = 0x04
BaremetalPi.SPI_LSB_FIRST = 0x08
BaremetalPi.SPI_3WIRE     = 0x10
BaremetalPi.SPI_LOOP      = 0x20
BaremetalPi.SPI_NO_CS     = 0x40
BaremetalPi.SPI_READY     = 0x80
```

```julia-repl
julia> init_spi("/dev/spidev0.0", mode = BaremetalPi.SPI_MODE_0 |
                                         BaremetalPi.SPI_CS_HIGH)
```

## Transfer

This package support full-duplex transfer using the functions `spi_transfer` and
`spi_transfer!` as follows.

```julia
spi_transfer!(devid, tx_buf, rx_buf; kwargs...)
```

Execute a full duplex transfer to SPI device `devid`. `devid` is the ID of the
SPI device considering the initialization order when the function `init_spi` was
called.

`tx_buf` can be a vector of `Integer`, in which only one message will be sent,
or a vector of vectors of `Integer`, in which multiple messages will be sent.

The received data will be stored in `rx_buf` that must have the same type of
`tx_buf` and enough size.

This function returns the number of bytes received.

The following keywords are available:

* `max_speed_hz`: If > 0, then override the default maximum transfer speed with
                  this value [Hz]. (**Default** = 0)
* `delay_usecs`: If ≥ 0, then override the default delay with this value.
                 (**Default** = -1)
* `bits_per_word`: If > 0, then override the number of bits per word with this
                   value. (**Default** = 0)
* `cs_change`: If `false`, the deselect the device at the end of the transfer.

```julia-repl
julia> tx_buf = [0x01, 0x80, 0x00]
3-element Array{UInt8,1}:
 0x01
 0x80
 0x00

julia> rx_buf = zeros(UInt8, 3)
3-element Array{UInt8,1}:
 0x00
 0x00
 0x00

julia> spi_transfer!(1, tx_buf, rx_buf)
3

julia> rx_buf
3-element Array{UInt8,1}:
 0x00
 0x01
 0xef

julia> tx_buf = [ [0x01, 0x80, 0x00] for i = 1:3 ]
3-element Array{Array{UInt8,1},1}:
 [0x01, 0x80, 0x00]
 [0x01, 0x80, 0x00]
 [0x01, 0x80, 0x00]

julia> rx_buf = zeros.(UInt8, length.(tx_buf))
3-element Array{Array{UInt8,1},1}:
 [0x00, 0x00, 0x00]
 [0x00, 0x00, 0x00]
 [0x00, 0x00, 0x00]

julia> spi_transfer!(1, tx_buf, rx_buf)
9

julia> rx_buf
3-element Array{Array{UInt8,1},1}:
 [0x00, 0x01, 0xef]
 [0xef, 0x00, 0x00]
 [0x00, 0x00, 0x00]
```

```julia
spi_transfer(devid, tx_buf; kwargs...)
```

Execute a full duplex transfer to SPI device `devid`. `devid` is the ID of the
SPI device considering the initialization order when the function `init_spi` was
called.

`tx_buf` can be a vector of `Integer`, in which only one message will be sent,
or a vector of vectors of `Integer`, in which multiple messages will be sent.

The result is returned in an object with the same type of `tx_buf` together with
the number of words received.

The same keywords of `spi_transfer!` can be used.

```julia-repl
julia> tx_buf = [0x01, 0x80, 0x00]
3-element Array{UInt8,1}:
 0x01
 0x80
 0x00

julia> spi_transfer(1, tx_buf)
(UInt8[0x00, 0x01, 0xf1], 3)

julia> spi_transfer(1, tx_buf)
(UInt8[0x00, 0x01, 0xf1], 3)

julia> tx_buf = [ [0x01, 0x80, 0x00] for i = 1:3 ]
3-element Array{Array{UInt8,1},1}:
 [0x01, 0x80, 0x00]
 [0x01, 0x80, 0x00]
 [0x01, 0x80, 0x00]

julia> spi_transfer(1, tx_buf)
(Array{UInt8,1}[[0x00, 0x01, 0xf2], [0x9f, 0x00, 0x00], [0x00, 0x00, 0x00]], 9)
```
