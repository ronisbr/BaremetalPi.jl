# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#     Functions to manage the I2C.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export init_i2c, close_i2c, i2c_get_funcs, i2c_slave, i2c_slave_force
export i2c_smbus_read_byte, i2c_smbus_read_byte_data, i2c_smbus_read_word_data
export i2c_smbus_read_i2c_block_data!, i2c_smbus_read_i2c_block_data
export i2c_smbus_write_byte, i2c_smbus_write_byte_data
export i2c_smbus_write_word_data, i2c_smbus_write_i2c_block_data

################################################################################
#                                Initialization
################################################################################

"""
    init_i2c(devices)

Initialize the I2C devices. `devices` can be a string with the path to `i2cdev`
or a vector of strings with a set of I2C devices that will be initialized.
"""
@inline init_i2c(device::String) = init_i2c([device])

function init_i2c(devices::AbstractVector{String})
    # Number of devices that the user wants to initialize.
    num_init_devices = length(devices)

    # If we have already initialized, then close all the devices first.
    objects.i2c_init && close_i2c()

    # Initialize each device.
    i2cdev = Vector{I2CDEV}(undef, 0)

    @inbounds for i = 1:num_init_devices
        try
            # Open the device
            # ==================================================================

            io = open(devices[i], "w+")

            # Get the available functionality
            # ==================================================================

            funcs = _i2c_get_funcs(io)

            # Pack values
            # ==================================================================
            i2cdev_i = I2CDEV(io, funcs)
            push!(i2cdev, i2cdev_i)
        catch
            error("Could not open `$(devices[i])`. Make sure you have the required permissions.")
        end
    end

    objects.i2cdev   = i2cdev
    objects.i2c_init = true

    return nothing
end

"""
    close_i2c()

Close all I2C connections.
"""
function close_i2c()
    if objects.i2c_init
        @inbounds for d in objects.i2cdev
            close(d.io)
        end
        objects.i2cdev = Vector{SPIDEV}(undef, 0)
        objects.i2c_init = false
    end

    return nothing
end

################################################################################
#                                   Commands
################################################################################

"""
    i2c_get_funcs(devid::Int)

Return a vector with the available I2C functions in the device `devid`.

`devid` is the ID of the I2C device considering the initialization order when
the function `init_i2c` was called.
"""
@inline function i2c_get_funcs(devid::Int)
    @assert objects.i2c_init "I2C not initialized. Run init_i2c()."
    @assert (0 < devid ≤ length(objects.i2cdev)) "I2C device ID is out of bounds."

    return objects.i2cdev[devid].funcs
end

################################################################################
#                                    SMBUS
################################################################################

"""
    i2c_slave(devid::Integer, address::Integer)

Select the slave device in address `address` using I2C device `devid`.

`devid` is the ID of the I2C device considering the initialization order when
the function `init_i2c` was called.
"""
function i2c_slave(devid::Integer, address::Integer)
    @assert objects.i2c_init "I2C not initialized. Run init_i2c()."
    @assert (0 < devid ≤ length(objects.i2cdev)) "I2C device ID is out of bounds."

    i2cdev = objects.i2cdev[devid]

    _ioctl(fd(i2cdev.io), I2C_SLAVE, __u8(address))

    return nothing
end

"""
    i2c_slave_force(devid::Integer, address::Integer)

Force selection of slave device in address `address` using I2C device `devid`.

`devid` is the ID of the I2C device considering the initialization order when
the function `init_i2c` was called.
"""
function i2c_slave_force(devid::Integer, address::Integer)
    @assert objects.i2c_init "I2C not initialized. Run init_i2c()."
    @assert (0 < devid ≤ length(objects.i2cdev)) "I2C device ID is out of bounds."

    i2cdev = objects.i2cdev[devid]

    _ioctl(fd(i2cdev.io), I2C_SLAVE_FORCE, __u8(address))

    return nothing
end

# Read
# ==============================================================================

"""
    i2c_smbus_read_byte(devid::Integer)

Perform a SMBUS read byte using the I2C device `devid`. This functions returns
the read byte.

`devid` is the ID of the I2C device considering the initialization order when
the function `init_i2c` was called.
"""
function i2c_smbus_read_byte(devid::Integer)
    @assert objects.i2c_init "I2C not initialized. Run init_i2c()."
    @assert (0 < devid ≤ length(objects.i2cdev)) "I2C device ID is out of bounds."

    i2cdev = objects.i2cdev[devid]

    # Create the SMBUS IOCTL structure to issue the ioctl command.
    smbus = struct_i2c_smbus_ioctl_data(
        I2C_SMBUS_READ,
        0,
        I2C_SMBUS_BYTE,
        pointer(i2cdev.bbyte)
    )

    _ioctl(fd(i2cdev.io), I2C_SMBUS, Ref(smbus))

    return (@inbounds i2cdev.bbyte[1])
end

"""
    i2c_smbus_read_byte_data(devid::Integer, command::Integer)

Perform a SMBUS read byte with command `command` using the I2C device `devid`.
This function return the read byte.

`devid` is the ID of the I2C device considering the initialization order when
the function `init_i2c` was called.
"""
function i2c_smbus_read_byte_data(devid::Integer, command::Integer)
    @assert objects.i2c_init "I2C not initialized. Run init_i2c()."
    @assert (0 < devid ≤ length(objects.i2cdev)) "I2C device ID is out of bounds."

    i2cdev = objects.i2cdev[devid]

    # Create the SMBUS IOCTL structure to issue the ioctl command.
    smbus = struct_i2c_smbus_ioctl_data(
        I2C_SMBUS_READ,
        command,
        I2C_SMBUS_BYTE_DATA,
        pointer(i2cdev.bbyte)
    )

    _ioctl(fd(i2cdev.io), I2C_SMBUS, Ref(smbus))

    return (@inbounds i2cdev.bbyte[1])
end

"""
    i2c_smbus_read_word_data(devid::Integer, command::Integer)

Perform a SMBUS read word with command `command` using the I2C device `devid`.
This function return the read word.

`devid` is the ID of the I2C device considering the initialization order when
the function `init_i2c` was called.
"""
function i2c_smbus_read_word_data(devid::Integer, command::Integer)
    @assert objects.i2c_init "I2C not initialized. Run init_i2c()."
    @assert (0 < devid ≤ length(objects.i2cdev)) "I2C device ID is out of bounds."

    i2cdev = objects.i2cdev[devid]

    # Create the SMBUS IOCTL structure to issue the ioctl command.
    smbus = struct_i2c_smbus_ioctl_data(
        I2C_SMBUS_READ,
        command,
        I2C_SMBUS_WORD_DATA,
        pointer(i2cdev.bword)
    )

    _ioctl(fd(i2cdev.io), I2C_SMBUS, Ref(smbus))

    return (@inbounds i2cdev.bword[1])
end

"""
    i2c_smbus_read_i2c_block_data(devid::Integer, command::Integer, size::Integer)

Perform a SMBUS read block with command `command` and length `length` using the
I2C device `devid`. The read data will be returned in an array of `UInt8` with
size `size + 1`. This array is a view of the buffer that was allocated at the
initialization of the I2C device. Notice that the first element of the array is
always `size`.

`devid` is the ID of the I2C device considering the initialization order when
the function `init_i2c` was called.

!!! warning

    The returned array is a view of the buffer `bblock` created for each I2C
    device. This buffer is modified by other functions like
    `i2c_smbus_write_i2c_block_data`. Hence, before performing another I2C
    transfer that will modify this buffer, be sure to copy the returned value to
    another place.

!!! note "Allocations"

    Due to the view returned by this functions, it performs one allocation. If
    this is not wanted, then use the in-place version
    `i2c_smbus_read_i2c_block_data!`.
"""
function i2c_smbus_read_i2c_block_data(
    devid::Integer,
    command::Integer,
    size::Integer
)
    @assert objects.i2c_init "I2C not initialized. Run init_i2c()."
    @assert (0 < devid ≤ length(objects.i2cdev)) "I2C device ID is out of bounds."
    @assert (size > 0) "The `size` must be larger than 0."
    @assert (size ≤ I2C_SMBUS_BLOCK_MAX) "I2C block data cannot read more than $(I2C_SMBUS_BLOCK_MAX) bytes."

    i2cdev = objects.i2cdev[devid]
    data = i2cdev.bblock

    # The first parameters is the length of the block we want to read.
    @inbounds data[1] = size

    # Create the SMBUS IOCTL structure to issue the ioctl command.
    smbus = struct_i2c_smbus_ioctl_data(
        I2C_SMBUS_READ,
        command,
        I2C_SMBUS_I2C_BLOCK_DATA,
        pointer(data)
    )

    _ioctl(fd(i2cdev.io), I2C_SMBUS, Ref(smbus))

    return view(data, 1:(size + 1))
end

"""
    i2c_smbus_read_i2c_block_data!(devid::Integer, command::Integer, data::Vector{UInt8})

Perform a SMBUS read block with command `command` using the I2C device `devid`.
The read data will be written to `data`. Notice that the first element of the
array is always `size`. Hence, the number of read bytes will be equal to the
length of `data` minus 1.

`devid` is the ID of the I2C device considering the initialization order when
the function `init_i2c` was called.
"""
function i2c_smbus_read_i2c_block_data!(
    devid::Integer,
    command::Integer,
    data::Vector{UInt8}
)
    @assert objects.i2c_init "I2C not initialized. Run init_i2c()."
    @assert (0 < devid ≤ length(objects.i2cdev)) "I2C device ID is out of bounds."

    size = length(data)

    @assert (size ≤ I2C_SMBUS_BLOCK_MAX + 1) "I2C block data cannot read more than $(I2C_SMBUS_BLOCK_MAX) bytes."
    @assert (size > 1) "The `data` array must have at least 2 elements."

    i2cdev = objects.i2cdev[devid]

    # The first parameters is the length of the block we want to read.
    @inbounds data[1] = size - 1

    # Create the SMBUS IOCTL structure to issue the ioctl command.
    smbus = struct_i2c_smbus_ioctl_data(
        I2C_SMBUS_READ,
        command,
        I2C_SMBUS_I2C_BLOCK_DATA,
        pointer(data)
    )

    _ioctl(fd(i2cdev.io), I2C_SMBUS, Ref(smbus))

    return nothing
end

# Write
# ==============================================================================

"""
    i2c_smbus_write_byte(devid::Integer, value::Integer)

Perform a SMBUS write byte with value `value` using the I2C device `devid`.

`devid` is the ID of the I2C device considering the initialization order when
the function `init_i2c` was called.
"""
function i2c_smbus_write_byte(devid::Integer, value::Integer)
    @assert objects.i2c_init "I2C not initialized. Run init_i2c()."
    @assert (0 < devid ≤ length(objects.i2cdev)) "I2C device ID is out of bounds."

    i2cdev = objects.i2cdev[devid]

    # Create the SMBUS IOCTL structure to issue the ioctl command.
    smbus = struct_i2c_smbus_ioctl_data(
        I2C_SMBUS_WRITE,
        value,
        I2C_SMBUS_BYTE,
        C_NULL
    )

    _ioctl(fd(i2cdev.io), I2C_SMBUS, Ref(smbus))

    return nothing
end

"""
    i2c_smbus_write_byte_data(devid::Integer, command::Integer, value::Integer)

Perform a SMBUS write byte with command `command` and value `value` using the
I2C device `devid`.

`devid` is the ID of the I2C device considering the initialization order when
the function `init_i2c` was called.
"""
function i2c_smbus_write_byte_data(
    devid::Integer,
    command::Integer,
    value::Integer
)
    @assert objects.i2c_init "I2C not initialized. Run init_i2c()."
    @assert (0 < devid ≤ length(objects.i2cdev)) "I2C device ID is out of bounds."

    i2cdev = objects.i2cdev[devid]

    # Create the SMBUS IOCTL structure to issue the ioctl command.
    data = i2cdev.bbyte
    @inbounds data[1] = value

    smbus = struct_i2c_smbus_ioctl_data(
        I2C_SMBUS_WRITE,
        command,
        I2C_SMBUS_BYTE_DATA,
        pointer(data)
    )

    _ioctl(fd(i2cdev.io), I2C_SMBUS, Ref(smbus))

    return nothing
end

"""
    i2c_smbus_write_word_data(devid::Integer, command::Integer, value::Integer)

Perform a SMBUS write word with command `command` and value `value` using the
I2C device `devid`.

`devid` is the ID of the I2C device considering the initialization order when
the function `init_i2c` was called.
"""
function i2c_smbus_write_word_data(
    devid::Integer,
    command::Integer,
    value::Integer
)
    @assert objects.i2c_init "I2C not initialized. Run init_i2c()."
    @assert (0 < devid ≤ length(objects.i2cdev)) "I2C device ID is out of bounds."

    i2cdev = objects.i2cdev[devid]

    # Create the SMBUS IOCTL structure to issue the ioctl command.
    data = i2cdev.bword
    @inbounds data[1] = value

    smbus = struct_i2c_smbus_ioctl_data(
        I2C_SMBUS_WRITE,
        command,
        I2C_SMBUS_WORD_DATA,
        pointer(data)
    )

    _ioctl(fd(i2cdev.io), I2C_SMBUS, Ref(smbus))

    return nothing
end

"""
    i2c_smbus_write_i2c_block_data(devid::Integer, command::Integer, values::Vector{UInt8})

Perform a SMBUS write I2C block data with command `command` and data in `values`
using the I2C device `devid`.

`devid` is the ID of the I2C device considering the initialization order when
the function `init_i2c` was called.
"""
function i2c_smbus_write_i2c_block_data(
    devid::Integer,
    command::Integer,
    values::Vector{UInt8}
)
    @assert objects.i2c_init "I2C not initialized. Run init_i2c()."
    @assert (0 < devid ≤ length(objects.i2cdev)) "I2C device ID is out of bounds."

    size = length(values)

    @assert (size ≤ I2C_SMBUS_BLOCK_MAX) "I2C block data cannot write more than $(I2C_SMBUS_BLOCK_MAX) bytes."

    i2cdev = objects.i2cdev[devid]

    # Create copy the data to the buffer.
    data = i2cdev.bblock
    @inbounds data[1] = size

    # If we use a slice here, then one allocation will be performed because of
    # the required `view` that will be created.
    @inbounds for i = 1:size
        data[i + 1] = values[i]
    end

    # Create the SMBUS IOCTL structure to issue the ioctl command.
    smbus = struct_i2c_smbus_ioctl_data(
        I2C_SMBUS_WRITE,
        command,
        I2C_SMBUS_I2C_BLOCK_DATA,
        pointer(data)
    )

    _ioctl(fd(i2cdev.io), I2C_SMBUS, Ref(smbus))

    return nothing
end

################################################################################
#                                   Private
################################################################################

function _i2c_get_funcs(i2cdev_io)
    # Create the ioctl that will return the functionality mask.
    pfuncs = Ref(Culong(0))
    _ioctl(fd(i2cdev_io), I2C_FUNCS, pfuncs)
    funcs = pfuncs.x

    # Check the existing functionality.
    translated_funcs = Vector{Symbol}(undef, 0)
    (I2C_FUNC_I2C & funcs) > 0                    && push!(translated_funcs, :i2c)
    (I2C_FUNC_10BIT_ADDR & funcs) > 0             && push!(translated_funcs, :tenbit_addr)
    (I2C_FUNC_PROTOCOL_MANGLING & funcs) > 0      && push!(translated_funcs, :protocol_mangling)
    (I2C_FUNC_SMBUS_PEC & funcs) > 0              && push!(translated_funcs, :smbus_pec)
    (I2C_FUNC_NOSTART & funcs) > 0                && push!(translated_funcs, :nostart)
    (I2C_FUNC_SLAVE & funcs) > 0                  && push!(translated_funcs, :slave)
    (I2C_FUNC_SMBUS_BLOCK_PROC_CALL & funcs) > 0  && push!(translated_funcs, :smbus_block_proc_call)
    (I2C_FUNC_SMBUS_QUICK & funcs) > 0            && push!(translated_funcs, :smbus_quick)
    (I2C_FUNC_SMBUS_READ_BYTE & funcs) > 0        && push!(translated_funcs, :smbus_read_byte)
    (I2C_FUNC_SMBUS_WRITE_BYTE & funcs) > 0       && push!(translated_funcs, :smbus_write_byte)
    (I2C_FUNC_SMBUS_READ_BYTE_DATA & funcs) > 0   && push!(translated_funcs, :smbus_read_byte_data)
    (I2C_FUNC_SMBUS_WRITE_BYTE_DATA & funcs) > 0  && push!(translated_funcs, :smbus_write_byte_data)
    (I2C_FUNC_SMBUS_READ_WORD_DATA & funcs) > 0   && push!(translated_funcs, :smbus_read_word_data)
    (I2C_FUNC_SMBUS_WRITE_WORD_DATA & funcs) > 0  && push!(translated_funcs, :smbus_write_word_data)
    (I2C_FUNC_SMBUS_PROC_CALL & funcs) > 0        && push!(translated_funcs, :smbus_proc_call)
    (I2C_FUNC_SMBUS_READ_BLOCK_DATA & funcs) > 0  && push!(translated_funcs, :smbus_read_block_data)
    (I2C_FUNC_SMBUS_WRITE_BLOCK_DATA & funcs) > 0 && push!(translated_funcs, :smbus_write_block_data)
    (I2C_FUNC_SMBUS_READ_I2C_BLOCK & funcs) > 0   && push!(translated_funcs, :smbus_read_i2c_block)
    (I2C_FUNC_SMBUS_WRITE_I2C_BLOCK & funcs) > 0  && push!(translated_funcs, :smbus_write_i2c_block)
    (I2C_FUNC_SMBUS_HOST_NOTIFY & funcs) > 0      && push!(translated_funcs, :smbus_host_notify)
    (I2C_FUNC_SMBUS_BYTE & funcs) > 0             && push!(translated_funcs, :smbus_byte)
    (I2C_FUNC_SMBUS_BYTE_DATA & funcs) > 0        && push!(translated_funcs, :smbus_byte_data)
    (I2C_FUNC_SMBUS_WORD_DATA & funcs) > 0        && push!(translated_funcs, :smbus_word_data)
    (I2C_FUNC_SMBUS_BLOCK_DATA & funcs) > 0       && push!(translated_funcs, :smbus_block_data)
    (I2C_FUNC_SMBUS_I2C_BLOCK & funcs) > 0        && push!(translated_funcs, :smbus_i2c_block)
    (I2C_FUNC_SMBUS_EMUL & funcs) > 0             && push!(translated_funcs, :smbus_emul)

    return translated_funcs
end
