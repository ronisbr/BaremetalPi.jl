BaremetalPi.jl Changelog
========================

Version 0.1.2
-------------

- ![Bug][badge-bugfix] BaremetalPi.jl is now compatible with Julia 1.7.

Version 0.1.1
-------------

- ![Enhancement][badge-enhancement] The transfers using SPI do not allocate
  anymore if the in-place version `spi_transfer!` is used, and if the number of
  messages is lower than `BaremetalPi._SPI_BUFFER_SIZE`. This constant is
  currently set to 16.
- ![Enhancement][badge-enhancement] The transfers using I2C (read and write) do
  not allocate anymore if the in-place version of the functions are used
  (`i2c_smbus_*!`).

Version 0.1.0
-------------

- Initial version.

[badge-breaking]: https://img.shields.io/badge/BREAKING-red.svg
[badge-deprecation]: https://img.shields.io/badge/Deprecation-orange.svg
[badge-feature]: https://img.shields.io/badge/Feature-green.svg
[badge-enhancement]: https://img.shields.io/badge/Enhancement-blue.svg
[badge-bugfix]: https://img.shields.io/badge/Bugfix-purple.svg
[badge-info]: https://img.shields.io/badge/Info-gray.svg
