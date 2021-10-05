# matter-rpi4-nRF52840-dongle

This project is a walk-through of [building with Matter](https://buildwithmatter.com/)!  The walk-through is available on this project's [GitHub Pages](http://caubut-charter.github.io/matter-rpi4-nRF52840-dongle/).

## Introduction

This project is an introductory step-by-step walk-through for building, commissioning, and testing your first Matter_ components.  It is meant as a bootstrap guide for anyone interested in Matter that wants to quickly setup a runnable example.  [nRF52840 Dongles](https://www.nordicsemi.com/Products/Development-hardware/nRF52840-Dongle/GetStarted) are used as low-cost radios and microcontrollers.  A [Raspberry Pi 4B](https://www.raspberrypi.org/products/) is used for building artifacts and running services.  Theoretically, an x64 Linux Desktop can be used for any step, and in some cases it is desirable (e.g. building firmware), but it is not tested as frequently.  *Every* stage is containerized to prevent dependency issues on the host.
