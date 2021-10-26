<p align="center">
[![🚀 docs-publish](https://github.com/caubut-charter/matter-rpi4-nRF52840-dongle/actions/workflows/docs-publish.yml/badge.svg)](https://github.com/caubut-charter/matter-rpi4-nRF52840-dongle/actions/workflows/docs-publish.yml)

[![🌠 nightly](https://github.com/caubut-charter/matter-rpi4-nRF52840-dongle/actions/workflows/nightly.yml/badge.svg)](https://github.com/caubut-charter/matter-rpi4-nRF52840-dongle/actions/workflows/nightly.yml)

[![✅ shellcheck](https://github.com/caubut-charter/matter-rpi4-nRF52840-dongle/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/caubut-charter/matter-rpi4-nRF52840-dongle/actions/workflows/shellcheck.yml)
</p>

# matter-rpi4-nRF52840-dongle

This project is a bootstrap guide for setting up a runnable example of [building with Matter](https://buildwithmatter.com/) on a [Raspberry Pi 4B](https://www.raspberrypi.org/products/) using low-cost [nRF52840 Dongles](https://www.nordicsemi.com/Products/Development-hardware/nRF52840-Dongle/GetStarted).  The walk-through is published on this project's [GitHub Pages](http://caubut-charter.github.io/matter-rpi4-nRF52840-dongle/).  The reader is assumed to have some outside understanding of Matter.  Instructions include how to build everything from scratch.  Containers are used when possible.  Build steps are executed via scripts in this repository which perform some minimal patching so everything works through the Raspberry Pi and to reduce container image sizes by sharing reusable dependencies as mounted volumes.  CI/CD pipelines are setup on this project to generate nightly builds of container images and various build artifacts as an alternative option to building from scratch.
