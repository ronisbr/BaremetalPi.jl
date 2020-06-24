using Test
using BaremetalPi

################################################################################
#                                  C Macros
################################################################################

# Test if the C Macros for the SPI protocol are being computed correctly.
@testset "C Macros - SPI" begin
    @test BaremetalPi.SPI_IOC_RD_MODE          == 0x80016b01
    @test BaremetalPi.SPI_IOC_WR_MODE          == 0x40016b01
    @test BaremetalPi.SPI_IOC_RD_LSB_FIRST     == 0x80016b02
    @test BaremetalPi.SPI_IOC_WR_LSB_FIRST     == 0x40016b02
    @test BaremetalPi.SPI_IOC_RD_BITS_PER_WORD == 0x80016b03
    @test BaremetalPi.SPI_IOC_WR_BITS_PER_WORD == 0x40016b03
    @test BaremetalPi.SPI_IOC_RD_MAX_SPEED_HZ  == 0x80046b04
    @test BaremetalPi.SPI_IOC_WR_MAX_SPEED_HZ  == 0x40046b04
    @test BaremetalPi.SPI_IOC_MESSAGE(1)       == 0x40206b00
    @test BaremetalPi.SPI_IOC_MESSAGE(2)       == 0x40406b00
    @test BaremetalPi.SPI_IOC_MESSAGE(3)       == 0x40606b00
    @test BaremetalPi.SPI_IOC_MESSAGE(4)       == 0x40806b00
    @test BaremetalPi.SPI_IOC_MESSAGE(5)       == 0x40a06b00
    @test BaremetalPi.SPI_IOC_MESSAGE(6)       == 0x40c06b00
    @test BaremetalPi.SPI_IOC_MESSAGE(7)       == 0x40e06b00
    @test BaremetalPi.SPI_IOC_MESSAGE(8)       == 0x41006b00
    @test BaremetalPi.SPI_IOC_MESSAGE(9)       == 0x41206b00
    @test BaremetalPi.SPI_IOC_MESSAGE(10)      == 0x41406b00
end
