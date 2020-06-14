using Documenter
using BaremetalPi

makedocs(
    modules = [BaremetalPi],
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        canonical = "https://ronisbr.github.io/BaremetalPi.jl/stable/",
    ),
    sitename = "BaremetalPi",
    authors = "Ronan Arraes Jardim Chagas",
    pages = [
        "Home"            => "index.md",
        "GPIO"            => "man/gpio.md",
        "SPI"             => "man/spi.md",
        "Examples"        => Any[
            "LED"         => "man/examples/led.md",
            "Temperature" => "man/examples/temperature.md",
        ],
        "Library"  => "lib/library.md",
    ]
)

deploydocs(
    repo = "github.com/ronisbr/BaremetalPi.jl.git",
    target = "build",
)
