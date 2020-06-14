LED
===

This example shows how to use **BaremetalPi.jl** to blink a LED. First, connect
a LED to the GPIO #4 of the Raspberry Pi as shown in the following figure.

!!! warning

    We are using the Raspberry Pi Zero W as an example. You **must** modify it
    according to your model.

```@raw html
<img src="../../../assets/Schematic_example_LED.png" width="65%"/>
```

After that, the following code turn on the LED during 0.5s and then turn it off
during another 0.5s indefinitely:

```julia
using BaremetalPi

# Initialize the GPIOs.
init_gpio()

# Make sure that the GPIO #4 is set as output.
gpio_set_mode(4, :out)

# Blink the LED indefinitely.
while(true)
    gpio_set(4)
    sleep(0.5)
    gpio_clear(4)
    sleep(0.5)
end
```
