module BaremetalPi

using Mmap

################################################################################
#                                  Constants
################################################################################

include("./constants.jl")

################################################################################
#                                    Types
################################################################################

include("./types.jl")

################################################################################
#                                   Includes
################################################################################

include("./cmacros.jl")
include("./ioctl.jl")
include("./gpio.jl")
include("./i2c.jl")
include("./spi.jl")

################################################################################
#                                Initialization
################################################################################

end # module