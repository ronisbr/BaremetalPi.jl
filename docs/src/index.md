BaremetalPi.jl
==============

This package has the purpose to create a Julia interface with the peripherals of
the Raspberry Pi without using any external libraries. Avoiding middlewares can
help to decrease latency for real-time applications.

## Status

This package should be considered alpha. It has been tested only against the
Raspberry Pi W Zero. Help is needed to improve the reliability of the package.

## Supported peripherals

The following peripherals are currently supported:

* GPIO (without PWM).
* SPI.
* I2C (SMBUS).

## Requirements

* Julia >= 1.0

## Installation

```julia-repl
julia> using Pkg
julia> Pkg.dev("https://github.com/ronisbr/BaremetalPi.jl")
```

## Manual outline

```@contents
Pages = [
    "man/gpio.md"
    "man/spi.md"
    "lib/library.md"
]
Depth = 2
```
