# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#     Wrapper to IOCTL calls.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@inline _ioctl(io::IOStream, args...) = _ioctl(fd(io), args...)

for (Tj, Tc) in (
    (Int8, Cchar),
    (Int16, Cshort),
    (Int32, Cint),
    (Int64, Clonglong),
    (UInt8, Cuchar),
    (UInt16, Cushort),
    (UInt32, Cuint),
    (UInt64, Culonglong),
    (Float32, Cfloat),
    (Float64, Cdouble)
)
    @eval function _ioctl(fd::Integer, request::Integer, arg::$Tj)
        ret = ccall(:ioctl, Cint, (Cint, Culong, $Tc), fd, request, arg)
        ret < 0 && throw(SystemError("Error in IOCTL call", Libc.errno()))
        return ret
    end

    @eval function _ioctl(fd::Integer, request::Integer, arg::Base.RefValue{$Tj})
        ret = ccall(:ioctl, Cint, (Cint, Culong, Ref{$Tc}), fd, request, arg)
        ret < 0 && throw(SystemError("Error in IOCTL call", Libc.errno()))
        return ret
    end

    @eval function _ioctl(fd::Integer, request::Integer, arg::AbstractVector{$Tj})
        ret = ccall(:ioctl, Cint, (Cint, Culong, Ref{$Tc}), fd, request, arg)
        ret < 0 && throw(SystemError("Error in IOCTL call", Libc.errno()))
        return ret
    end
end
