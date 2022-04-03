# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#     Functions to manage the GPIOs.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export init_gpio, gpio_get_mode, gpio_set_mode, gpio_read, gpio_clear, gpio_set
export gpio_value

################################################################################
#                                Initialization
################################################################################

"""
    init_gpio()

Initialize the GPIO.
"""
function init_gpio()
    # Open and map /dev/gpiomem.
    try
        gpiomem_io  = open("/dev/gpiomem", "w+")
        gpiomem_map = Mmap.mmap(
            gpiomem_io,
            Vector{UInt32},
            (GPIOMEM_SIZE,),
            0,
            grow = false
        )

        objects.gpiomem_io  = gpiomem_io
        objects.gpiomem_map = gpiomem_map
        objects.gpio_init   = true
    catch
        error("Could not map `/dev/gpiomem`. Make sure you have the required permissions.")
    end

    return nothing
end

################################################################################
#                                  GPIO State
################################################################################

"""
    gpio_get_mode(gpio::Int)

Return the state of the GPIO `gpio`.
"""
function gpio_get_mode(gpio::Int)
    !objects.gpio_init && error("GPIO not initialized. Run init_gpio().")
    !(0 ≤ gpio ≤ 27) && error("GPIO out of range.")

    map = objects.gpiomem_map

    @inbounds begin
        ind   = div(gpio, 10) + 1
        g     = 3 * (gpio % 10)
        mask  = 7 << g
        state = (map[ind] & mask) >> g

        if haskey(GPIO_MODE_GET, state)
            return GPIO_MODE_GET[state]
        else
            return :undef
        end
    end
end

"""
    gpio_set_mode(gpio, mode::Symbol)

Set the mode of the GPIO `gpio` to `mode`. `gpio` can be an integer of an
`AbstractVector` with the list of GPIOs that will be set.

`mode` can be:

* `:out`: GPIO direction will be set to out.
* `:in`: GPIO direction will be set to in.
* `:alt0`: GPIO will be set to alternate function 0.
* `:alt1`: GPIO will be set to alternate function 1.
* `:alt2`: GPIO will be set to alternate function 2.
* `:alt3`: GPIO will be set to alternate function 3.
* `:alt4`: GPIO will be set to alternate function 4.
* `:alt5`: GPIO will be set to alternate function 5.
"""
function gpio_set_mode(gpio::Int, mode::Symbol)
    !objects.gpio_init && error("GPIO not initialized. Run init_gpio().")
    !(0 ≤ gpio ≤ 27) && error("GPIO out of range.")

    if !haskey(GPIO_MODE_SET, mode)
        error("Unknown GPIO mode.")
    end

    map = objects.gpiomem_map

    @inbounds begin
        ind  = div(gpio, 10) + 1
        g    = 3 * (gpio % 10)

        # We must always clear the GPIO mode before setting the new mode. This
        # is done by temporarily setting the GPIO to `:in`.
        map[ind] &= ~(7 << g)

        if (mode != :in)
            code = GPIO_MODE_SET[mode]
            map[ind] |= (UInt32(code) << g)
        end
    end

    return nothing
end

function gpio_set_mode(gpio::AbstractVector{Int}, mode::Symbol)
    for g ∈ gpio
        gpio_set_mode(g, mode)
    end

    return nothing
end

################################################################################
#                                     Read
################################################################################

"""
    gpio_read(gpio::Int)

Read the GPIO `gpio`. The returned value is boolean.
"""
function gpio_read(gpio::Int)
    !objects.gpio_init && error("GPIO not initialized. Run init_gpio().")
    !(0 ≤ gpio ≤ 27) && error("GPIO out of range.")

    @inbounds begin
        if (objects.gpiomem_map[13 + 1] & (1 << gpio)) > 0
            return true
        else
            return false
        end
    end
end

################################################################################
#                                Set and clear
################################################################################

"""
    gpio_clear(gpio::Int)

Clear GPIO `gpio`.
"""
@inline function gpio_clear(gpio::Int)
    !objects.gpio_init && error("GPIO not initialized. Run init_gpio().")
    !(0 ≤ gpio ≤ 27) && error("GPIO out of range.")

    @inbounds begin
        objects.gpiomem_map[10 + 1] = 1 << gpio
    end

    return nothing
end

@inline function gpio_clear(gpio::AbstractVector{Int})
    for g in gpio
        gpio_clear(g)
    end

    return nothing
end

"""
    gpio_set(gpio::Int)

Set GPIO `gpio`.
"""
@inline function gpio_set(gpio::Int)
    !objects.gpio_init && error("GPIO not initialized. Run init_gpio().")
    !(0 ≤ gpio ≤ 27) && error("GPIO out of range.")

    @inbounds begin
        objects.gpiomem_map[7 + 1] = 1 << gpio
    end

    return nothing
end

@inline function gpio_set(gpio::AbstractVector{Int})
    for g in gpio
        gpio_set(g)
    end

    return nothing
end

"""
    gpio_value(v::Integer)

Apply the value `v` to all GPIOs. The bits that are `0` will be cleared, and the
bits that are `1` will be set.

    gpio_value(v::BitVector)

Convert the bit array `v` to `Int` and call `gpio_value(::Int)`.
"""
function gpio_value(v::Integer)
    !objects.gpio_init && error("GPIO not initialized. Run init_gpio().")
    (v < 0) && error("`v` cannot be negative.")

    @inbounds begin
        # Set the GPIO.
        objects.gpiomem_map[7 + 1]  = v & 0xFFFFFFF

        # Clear the GPIOs.
        objects.gpiomem_map[10 + 1] = (~UInt32(v)) & 0xFFFFFFF
    end

    return nothing
end

gpio_value(v::BitVector) = gpio_value(v.chunks[1])
