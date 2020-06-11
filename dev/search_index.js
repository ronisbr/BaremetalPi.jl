var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "#BaremetalPi.jl-1",
    "page": "Home",
    "title": "BaremetalPi.jl",
    "category": "section",
    "text": "This package has the purpose to create a Julia interface with the peripherals of the Raspberry Pi without using any external libraries. Avoiding middlewares can help to decrease latency for real-time applications."
},

{
    "location": "#Status-1",
    "page": "Home",
    "title": "Status",
    "category": "section",
    "text": "This package should be considered alpha. It has been tested only against the Raspberry Pi W Zero. Help is needed to improve the reliability of the package."
},

{
    "location": "#Supported-peripherals-1",
    "page": "Home",
    "title": "Supported peripherals",
    "category": "section",
    "text": "The following peripherals are currently supported:GPIO.\nSPI."
},

{
    "location": "#Requirements-1",
    "page": "Home",
    "title": "Requirements",
    "category": "section",
    "text": "Julia >= 1.0"
},

{
    "location": "#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "julia> using Pkg\njulia> Pkg.dev(\"https://github.com/ronisbr/BaremetalPi.jl\")"
},

{
    "location": "#Manual-outline-1",
    "page": "Home",
    "title": "Manual outline",
    "category": "section",
    "text": "Pages = [\n    \"man/gpio.md\"\n    \"man/spi.md\"\n    \"lib/library.md\"\n]\nDepth = 2"
},

{
    "location": "man/gpio/#",
    "page": "GPIO",
    "title": "GPIO",
    "category": "page",
    "text": ""
},

{
    "location": "man/gpio/#GPIO-1",
    "page": "GPIO",
    "title": "GPIO",
    "category": "section",
    "text": ""
},

{
    "location": "man/gpio/#Initialization-1",
    "page": "GPIO",
    "title": "Initialization",
    "category": "section",
    "text": "Before any operations related to GPIOs, the following function must be called to initialize the system:julia> init_gpio()note: Note\nThis function opens the device /dev/gpiomem. Thus, make sure that the user has permissions to read and write this file."
},

{
    "location": "man/gpio/#GPIO-mode-1",
    "page": "GPIO",
    "title": "GPIO mode",
    "category": "section",
    "text": "The mode of a GPIO can be set by the function gpio_set_mode, which has the following signatures:gpio_set_mode(gpio::Int, mode::Symbol)\ngpio_set_mode(gpio::AbstractVector{Int}, mode::Symbol)In the former, the GPIO gpio will be set to mode, and, in the later, all the GPIOs in the vector gpio will be set to mode.mode must be one of the following symbols::out: GPIO direction will be set to out.\n:in: GPIO direction will be set to in.\n:alt0: GPIO will be set to alternate function 0.\n:alt1: GPIO will be set to alternate function 1.\n:alt2: GPIO will be set to alternate function 2.\n:alt3: GPIO will be set to alternate function 3.\n:alt4: GPIO will be set to alternate function 4.\n:alt5: GPIO will be set to alternate function 5.The current GPIO mode can be retrieved by the function gpio_get_mode, which has the following signature:gpio_get_mode(gpio::Int)This function returns symbol with the current mode of gpio using the same convention as shown before.julia> gpio_set_mode(9, :out)\n\njulia> gpio_get_mode(9)\n:out\n\njulia> gpio_set_mode(9, :alt0)\n\njulia> gpio_get_mode(9)\n:alt0\n\njulia> gpio_set_mode(9:11, :alt0)\n\njulia> gpio_get_mode.(9:11)\n3-element Array{Symbol,1}:\n :alt0\n :alt0\n :alt0"
},

{
    "location": "man/gpio/#GPIO-functions-1",
    "page": "GPIO",
    "title": "GPIO functions",
    "category": "section",
    "text": "The following functions can be used to set a GPIO, i.e., change it to the logic level 1.gpio_set(gpio::Int)\ngpio_set(gpio::AbstractVector{Int})The former set the GPIO gpio, whereas the later set all GPIOs in the vector gpio.julia> gpio_set(5)\n\njulia> gpio_set(1:10)\nnote: Note\nNo check is performed to verify which is the current mode of the GPIO. The user must take care to set those GPIOs mode to :out.The input from a GPIO can be read by the function gpio_read, which has the following signature:gpio_read(gpio::Int)It returns true if the GPIO gpio is in high logic level, or false otherwise.julia> gpio_read(5)\ntrue\n\njulia> gpio_read(5)\nfalse\nIt is also possible to use the function gpio_value to set all the GPIOs to a specific value:gpio_value(v::Integer)where the bits that are 0 will be cleared, and the bits that are 1 will be set. Another possibility is to pass to gpio_value a BitVector, which will perform the same operation considering the values on the vector.gpio_value(v::BitVector)julia> gpio_value(0)        # ................................ Clears all GPIOs.\n\njulia> gpio_set(0xFFFFFFFF) # .................................. Sets all GPIOs.\n\njulia> gpio_set(0xAAAAAAAA) # .... Sets the even GPIOs and clears the odd GPIOs.note: Note\nThe first bit the v is related to the GPIO #1 instead of the GPIO #0.note: Note\nThe bits higher than 27, which are the number of GPIOs, are just ignored."
},

{
    "location": "man/spi/#",
    "page": "SPI",
    "title": "SPI",
    "category": "page",
    "text": ""
},

{
    "location": "man/spi/#SPI-1",
    "page": "SPI",
    "title": "SPI",
    "category": "section",
    "text": ""
},

{
    "location": "man/spi/#Initialization-1",
    "page": "SPI",
    "title": "Initialization",
    "category": "section",
    "text": "Before any operations related to SPI, one the following function must be called to initialize the system:init_spi(devices::String; kwargs...); kwargs...\ninit_spi(devices::AbstractVector{String}; kwargs...These functions initialize the SPI devices. devices can be a string with the path to spidev or a vector of strings with a set of SPI devices that will be initialized.The following keywords are supported:mode: Set the mode of the SPI. (Default = 0)\nmax_speed_hz: Maximum allowed speed in SPI communication [Hz].                 (Default = 4000000)\nbits_per_word: Number of bits per word in SPI communication.                  (Default = 8)Notice that all keywords can be a Integer, when the configuration will be applied to all SPI devices, or a Vector of Integers, when different configurations can be applied to the initialized devices.note: Note\nThese functions open the device(s) /dev/spidevX.X passed to the argument devices. Thus, make sure that the user has permissions to read and write this file.julia> init_spi(\"/dev/spidev0.0\")\n\njulia> init_spi([\"/dev/spiddev0.0\", \"/dev/spidev0.1\"])\n\njulia> init_spi(\"/dev/spidev0.0\", max_speed_hz = 1000)\n"
},

{
    "location": "man/spi/#Modes-1",
    "page": "SPI",
    "title": "Modes",
    "category": "section",
    "text": "The SPI mode can be selected using the following constants that were obtained from spidev.h (Linux 4.19 tree):BaremetalPi.SPI_CPHA      = 0x01\nBaremetalPi.SPI_CPOL      = 0x02\n\nBaremetalPi.SPI_MODE_0    = (0|0)\nBaremetalPi.SPI_MODE_1    = (0|SPI_CPHA)\nBaremetalPi.SPI_MODE_2    = (SPI_CPOL|0)\nBaremetalPi.SPI_MODE_3    = (SPI_CPOL|SPI_CPHA)\n\nBaremetalPi.SPI_CS_HIGH   = 0x04\nBaremetalPi.SPI_LSB_FIRST = 0x08\nBaremetalPi.SPI_3WIRE     = 0x10\nBaremetalPi.SPI_LOOP      = 0x20\nBaremetalPi.SPI_NO_CS     = 0x40\nBaremetalPi.SPI_READY     = 0x80julia> init_spi(\"/dev/spidev0.0\", mode = BaremetalPi.SPI_MODE_0 |\n                                         BaremetalPi.SPI_CS_HIGH)"
},

{
    "location": "man/spi/#Transfer-1",
    "page": "SPI",
    "title": "Transfer",
    "category": "section",
    "text": "This package support full-duplex transfer using the functions spi_transfer and spi_transfer! as follows.spi_transfer!(devid, tx_buf, rx_buf; kwargs...)Execute a full duplex transfer to SPI device devid. devid is the ID of the SPI device considering the initialization order when the function init_spi was called.tx_buf can be a vector of Integer, in which only one message will be sent, or a vector of vectors of Integer, in which multiple messages will be sent.The received data will be stored in rx_buf that must have the same type of tx_buf and enough size.This function returns the number of bytes received.The following keywords are available:max_speed_hz: If > 0, then override the default maximum transfer speed with                 this value [Hz]. (Default = 0)\ndelay_usecs: If ≥ 0, then override the default delay with this value.                (Default = -1)\nbits_per_word: If > 0, then override the number of bits per word with this                  value. (Default = 0)\ncs_change: If false, the deselect the device at the end of the transfer.julia> tx_buf = [0x01, 0x80, 0x00]\n3-element Array{UInt8,1}:\n 0x01\n 0x80\n 0x00\n\njulia> rx_buf = zeros(UInt8, 3)\n3-element Array{UInt8,1}:\n 0x00\n 0x00\n 0x00\n\njulia> spi_transfer!(1, tx_buf, rx_buf)\n3\n\njulia> rx_buf\n3-element Array{UInt8,1}:\n 0x00\n 0x01\n 0xef\n\njulia> tx_buf = [ [0x01, 0x80, 0x00] for i = 1:3 ]\n3-element Array{Array{UInt8,1},1}:\n [0x01, 0x80, 0x00]\n [0x01, 0x80, 0x00]\n [0x01, 0x80, 0x00]\n\njulia> rx_buf = zeros.(UInt8, length.(tx_buf))\n3-element Array{Array{UInt8,1},1}:\n [0x00, 0x00, 0x00]\n [0x00, 0x00, 0x00]\n [0x00, 0x00, 0x00]\n\njulia> spi_transfer!(1, tx_buf, rx_buf)\n9\n\njulia> rx_buf\n3-element Array{Array{UInt8,1},1}:\n [0x00, 0x01, 0xef]\n [0xef, 0x00, 0x00]\n [0x00, 0x00, 0x00]spi_transfer(devid, tx_buf; kwargs...)Execute a full duplex transfer to SPI device devid. devid is the ID of the SPI device considering the initialization order when the function init_spi was called.tx_buf can be a vector of Integer, in which only one message will be sent, or a vector of vectors of Integer, in which multiple messages will be sent.The result is returned in an object with the same type of tx_buf together with the number of words received.The same keywords of spi_transfer! can be used.julia> tx_buf = [0x01, 0x80, 0x00]\n3-element Array{UInt8,1}:\n 0x01\n 0x80\n 0x00\n\njulia> spi_transfer(1, tx_buf)\n(UInt8[0x00, 0x01, 0xf1], 3)\n\njulia> spi_transfer(1, tx_buf)\n(UInt8[0x00, 0x01, 0xf1], 3)\n\njulia> tx_buf = [ [0x01, 0x80, 0x00] for i = 1:3 ]\n3-element Array{Array{UInt8,1},1}:\n [0x01, 0x80, 0x00]\n [0x01, 0x80, 0x00]\n [0x01, 0x80, 0x00]\n\njulia> spi_transfer(1, tx_buf)\n(Array{UInt8,1}[[0x00, 0x01, 0xf2], [0x9f, 0x00, 0x00], [0x00, 0x00, 0x00]], 9)"
},

{
    "location": "lib/library/#",
    "page": "Library",
    "title": "Library",
    "category": "page",
    "text": ""
},

{
    "location": "lib/library/#BaremetalPi.gpio_clear-Tuple{Int64}",
    "page": "Library",
    "title": "BaremetalPi.gpio_clear",
    "category": "method",
    "text": "gpio_clear(gpio)\n\nClear GPIO gpio.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#BaremetalPi.gpio_get_mode-Tuple{Int64}",
    "page": "Library",
    "title": "BaremetalPi.gpio_get_mode",
    "category": "method",
    "text": "gpio_get_mode(gpio::Int, dir::Symbol)\n\nReturn the state of the GPIO gpio.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#BaremetalPi.gpio_read-Tuple{Int64}",
    "page": "Library",
    "title": "BaremetalPi.gpio_read",
    "category": "method",
    "text": "gpio_read(gpio::Int)\n\nRead the GPIO gpio. The returned value is boolean.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#BaremetalPi.gpio_set-Tuple{Int64}",
    "page": "Library",
    "title": "BaremetalPi.gpio_set",
    "category": "method",
    "text": "gpio_set(gpio)\n\nSet GPIO gpio.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#BaremetalPi.gpio_set_mode-Tuple{Int64,Symbol}",
    "page": "Library",
    "title": "BaremetalPi.gpio_set_mode",
    "category": "method",
    "text": "gpio_set_mode(gpio, dir::Symbol)\n\nSet the mode of the GPIO gpio to mode. gpio can be an integer of an AbstractVector with the list of GPIOs that will be set.\n\nmode can be:\n\n:out: GPIO direction will be set to out.\n:in: GPIO direction will be set to in.\n:alt0: GPIO will be set to alternate function 0.\n:alt1: GPIO will be set to alternate function 1.\n:alt2: GPIO will be set to alternate function 2.\n:alt3: GPIO will be set to alternate function 3.\n:alt4: GPIO will be set to alternate function 4.\n:alt5: GPIO will be set to alternate function 5.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#BaremetalPi.gpio_value-Tuple{Integer}",
    "page": "Library",
    "title": "BaremetalPi.gpio_value",
    "category": "method",
    "text": "gpio_value(v::Integer)\n\nApply the value v to all GPIOs. The bits that are 0 will be cleared, and the bits that are 1 will be set.\n\ngpio_value(v::BitVector)\n\nConvert the bit array v to Int and call gpio_value(::Int).\n\n\n\n\n\n"
},

{
    "location": "lib/library/#BaremetalPi.init_gpio-Tuple{}",
    "page": "Library",
    "title": "BaremetalPi.init_gpio",
    "category": "method",
    "text": "init_gpio()\n\nInitialize the GPIO.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#BaremetalPi.init_spi-Tuple{String}",
    "page": "Library",
    "title": "BaremetalPi.init_spi",
    "category": "method",
    "text": "init_spi(devices; mode = 0, max_speed_hz = 4_000_000, bits_per_word = 8)\n\nInitialize the SPI devices. devices can be a string with the path to spidev or a vector of strings with a set of SPI devices that will be initialized.\n\nKeywords\n\nmode: Set the mode of the SPI. (Default = 0)\nmax_speed_hz: Maximum allowed speed in SPI communication [Hz].                 (Default = 4000000)\nbits_per_word: Number of bits per word in SPI communication.                  (Default = 8)\n\nNotice that all keywords can be a Integer, when the configuration will be applied to all SPI devices, or a Vector of Integers, when different configurations can be applied to the initialized devices.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#BaremetalPi.spi_transfer!-Union{Tuple{T}, Tuple{U}, Tuple{Integer,AbstractArray{T,1},AbstractArray{T,1}}} where T<:Array{U,1} where U<:Integer",
    "page": "Library",
    "title": "BaremetalPi.spi_transfer!",
    "category": "method",
    "text": "spi_transfer!(devid, tx_buf, rx_buf; kwargs...)\n\nExecute a full duplex transfer to SPI device devid. devid is the ID of the SPI device considering the initialization order when the function init_spi was called.\n\ntx_buf can be a vector of Integer, in which only one message will be sent, or a vector of vectors of Integer, in which multiple messages will be sent.\n\nThe received data will be stored in rx_buf that must have the same type of tx_buf and enough size.\n\nThis function returns the number of bytes received.\n\nKeywords\n\nmax_speed_hz: If > 0, then override the default maximum transfer speed with                 this value [Hz]. (Default = 0)\ndelay_usecs: If ≥ 0, then override the default delay with this value.                (Default = -1)\nbits_per_word: If > 0, then override the number of bits per word with this                  value. (Default = 0)\ncs_change: If false, the deselect the device at the end of the transfer.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#BaremetalPi.spi_transfer-Union{Tuple{T}, Tuple{Integer,AbstractArray{T,1}}} where T<:Integer",
    "page": "Library",
    "title": "BaremetalPi.spi_transfer",
    "category": "method",
    "text": "spi_transfer(devid, tx_buf; kwargs...)\n\nExecute a full duplex transfer to SPI device devid. devid is the ID of the SPI device considering the initialization order when the function init_spi was called.\n\ntx_buf can be a vector of Integer, in which only one message will be sent, or a vector of vectors of Integer, in which multiple messages will be sent.\n\nThe result is returned in an object with the same type of tx_buf together with the number of words received.\n\nKeywords\n\nThe same keywords of spi_transfer! can be used.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#BaremetalPi.Objects",
    "page": "Library",
    "title": "BaremetalPi.Objects",
    "category": "type",
    "text": "Objects\n\nThis structure stores global objects, such as the IO file and the memory mappings.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#BaremetalPi.close_spi-Tuple{}",
    "page": "Library",
    "title": "BaremetalPi.close_spi",
    "category": "method",
    "text": "close_spi()\n\nClose all SPI connections.\n\n\n\n\n\n"
},

{
    "location": "lib/library/#Library-1",
    "page": "Library",
    "title": "Library",
    "category": "section",
    "text": "Documentation for BaremetalPi.jl.Modules = [BaremetalPi]"
},

]}
