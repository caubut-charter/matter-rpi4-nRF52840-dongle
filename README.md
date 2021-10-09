# matter-rpi4-nRF52840-dongle

This project is a walk-through of [building with Matter](https://buildwithmatter.com/)!  The walk-through is published on this project's [GitHub Pages](http://caubut-charter.github.io/matter-rpi4-nRF52840-dongle/).

## Introduction

This project is a bootstrap guide for anyone interested in Matter_ who wants to quickly setup some runnable examples.  The reader is assumed to have outside familiarity with the Matter specification, but they are struggling to get the examples to work.  [nRF52840 Dongles](https://www.nordicsemi.com/Products/Development-hardware/nRF52840-Dongle/GetStarted) are used as low-cost radios and microcontrollers.  A [Raspberry Pi 4B](https://www.raspberrypi.org/products/) ("RPi" in this guide) is used for building artifacts and running services.  Theoretically, an x64 Linux Desktop can be used for any step, and in some cases is desirable (e.g. building firmware), but not all components are tested as frequently.  *Every* stage is containerized to prevent dependency issues on the host.
