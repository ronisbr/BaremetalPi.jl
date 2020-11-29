BaremetalPi.jl
==============

[![Build status](https://github.com/ronisbr/BaremetalPi.jl/workflows/CI/badge.svg)](https://github.com/ronisbr/BaremetalPi.jl/actions)
[![](https://img.shields.io/badge/docs-stable-blue.svg)][docs-stable-url]
[![](https://img.shields.io/badge/docs-dev-blue.svg)][docs-dev-url]

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

[docs-dev-url]: https://ronisbr.github.io/BaremetalPi.jl/dev
[docs-stable-url]: https://ronisbr.github.io/BaremetalPi.jl/stable
