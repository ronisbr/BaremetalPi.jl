GPIO
====

## Initialization

Before any operations related to GPIOs, the following function must be called to
initialize the system:

```julia-repl
julia> init_gpio()
```

!!! note

    This function opens the device `/dev/gpiomem`. Thus, make sure that the user
    has permissions to read and write this file.

## GPIO mode

The mode of a GPIO can be set by the function `gpio_set_mode`, which has the
following signatures:

```julia
gpio_set_mode(gpio::Int, mode::Symbol)
gpio_set_mode(gpio::AbstractVector{Int}, mode::Symbol)
```

In the former, the GPIO `gpio` will be set to `mode`, and, in the later, all
the GPIOs in the vector `gpio` will be set to `mode`.

`mode` must be one of the following symbols:

* `:out`: GPIO direction will be set to out.
* `:in`: GPIO direction will be set to in.
* `:alt0`: GPIO will be set to alternate function 0.
* `:alt1`: GPIO will be set to alternate function 1.
* `:alt2`: GPIO will be set to alternate function 2.
* `:alt3`: GPIO will be set to alternate function 3.
* `:alt4`: GPIO will be set to alternate function 4.
* `:alt5`: GPIO will be set to alternate function 5.

The current GPIO mode can be retrieved by the function `gpio_get_mode`, which
has the following signature:

```julia
gpio_get_mode(gpio::Int)
```

This function returns symbol with the current mode of `gpio` using the same
convention as shown before.

```julia-repl
julia> gpio_set_mode(9, :out)

julia> gpio_get_mode(9)
:out

julia> gpio_set_mode(9, :alt0)

julia> gpio_get_mode(9)
:alt0

julia> gpio_set_mode(9:11, :alt0)

julia> gpio_get_mode.(9:11)
3-element Array{Symbol,1}:
 :alt0
 :alt0
 :alt0
```

## GPIO functions

The following functions can be used to set a GPIO, *i.e.*, change it to the
logic level 1.

```julia
gpio_set(gpio::Int)
gpio_set(gpio::AbstractVector{Int})
```

The former set the GPIO `gpio`, whereas the later set all GPIOs in the vector `gpio`.

```julia-repl
julia> gpio_set(5)

julia> gpio_set(1:10)

```

!!! note

    No check is performed to verify which is the current mode of the GPIO. The
    user must take care to set those GPIOs mode to `:out`.

The input from a GPIO can be read by the function `gpio_read`, which has the
following signature:

```julia
gpio_read(gpio::Int)
```

It returns `true` if the GPIO `gpio` is in high logic level, or `false` otherwise.

```julia-repl
julia> gpio_read(5)
true

julia> gpio_read(5)
false

```

It is also possible to use the function `gpio_value` to set all the GPIOs to a
specific value:

```julia
gpio_value(v::Integer)
```

where the bits that are `0` will be cleared, and the bits that are `1` will be
set. Another possibility is to pass to `gpio_value` a `BitVector`, which will
perform the same operation considering the values on the vector.

```julia
gpio_value(v::BitVector)
```

```julia
julia> gpio_value(0)        # ................................ Clears all GPIOs.

julia> gpio_set(0xFFFFFFFF) # .................................. Sets all GPIOs.

julia> gpio_set(0xAAAAAAAA) # .... Sets the even GPIOs and clears the odd GPIOs.
```

!!! note

    The bits higher than 27, which are the number of GPIOs, are just ignored.
