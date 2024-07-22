# Arkm8c

Operating System for the R36S game console running only M8C

Download link:

Arkm8c.tar.xz 1.5 - 909 MB
- [Google Drive link](https://bit.ly/arkm8c15)
- [MEGA link](https://bit.ly/arkm8c15M)

Use BalenaEtcher to write the tar.xz file to an SD card.
[Download BalenaEtcher](https://etcher.balena.io/)

For version 1.3 and up, there is no need to uncompress it first.

You can find and change gamepad and other settings related to M8C or i3 in the /boot partition in a folder called "m8c-settings".

❗❗❗ If you experience latency after starting your device, put it in standby mode by pressing the power button and wake it up again. Your device will appear unresponsive for a couple of seconds, but after a short wait, it should work fine. ❗❗❗

Controls:
- D-pad = Navigation
- B = Edit
- A = Options
- Y or L2 = Shift
- X or R2 = Play
- R3 + Up or Down = Brightness Up or Down
- FN + Select = Shutdown

If you get nothing but a black screen after booting, copy the `rk3326-r35s-linux.dtb` file from the original SD card's /boot partition that came with your device. Then replace/rename it to `rk3326-r36s-linux.dtb` in the /boot partition of your fresh Arkm8c SD card.

Headphone problems with the R36S? This adapter might solve it:
- [AliExpress link](https://bit.ly/43hYwXj)

Changelog:

v1.5 - updated M8C to version 1.7.6
- removed support for analog sticks in M8C

v1.4 - updated M8C to version 1.7.1

v1.3 - lowered latency even further
- cleaned up the status bar & added battery status (FN button)
- shrunk the image to 4GB (908MB compressed)
- doesn't expand filesystem anymore after the first boot.
- pavucontrol doesn't start at boot as default
- added settings folder with symlinks to M8C and i3 configs in /boot partition

v1.2 - we don't talk about version 1.2

v1.1 - lowered buffer size from 1024 to 256

Older versions:
- [v1.0](https://bit.ly/arkm8cxz)
- [v1.1](https://bit.ly/arkm8c1xz)
- [v1.3](https://bit.ly/arkm8c13)
- [v1.4](https://bit.ly/arkm8c14)

A very special thanks to:

Trash80 - [Dirtywave](https://dirtywave.com/)

and to the creators of:
- [M8C](https://github.com/laamaa/m8c)
- [arkos](https://github.com/christianhaitian/a...)
- [pishrink](https://github.com/Drewsif/PiShrink)
- and the entire FOSS Linux community.
