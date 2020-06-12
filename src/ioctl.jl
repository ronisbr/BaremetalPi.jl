# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#     Wrapper to IOCTL calls.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@inline _ioctl(io::IOStream, args...) = _ioctl(fd(io), args...)

@inline function _ioctl(fd::Cint, request::Integer, arg::Integer)
    ref_arg = Ref(arg)
    return _ioctl(fd, request, ref_arg)
end

function _ioctl(fd::Integer, request::Integer, arg::Base.RefValue{T}) where T
    ret = ccall(:ioctl, Cint, (Cint, Culong, Ref{T}), fd, request, arg)
    ret < 0 && throw(SystemError("Error in IOCTL call", Libc.errno()))
    return ret
end

function _ioctl(fd::Integer, request::Integer, arg::AbstractVector{T}) where T
    ret = ccall(:ioctl, Cint, (Cint, Culong, Ref{T}), fd, request, arg)
    ret < 0 && throw(SystemError("Error in IOCTL call", Libc.errno()))
    return ret
end
