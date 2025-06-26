# Arkm8c

Operating System for the R36S game console running only M8C

## Download link:
Armbianm8c.tar.xz 0.1 - 435.2 MB
- [Google Drive link](https://bit.ly/armbianm8c)

Arkm8c.tar.xz 2.1 - 892.3 MB
- [Google Drive link](https://bit.ly/arkm8c21)
- [MEGA link](https://bit.ly/arkm8c21M)


Use BalenaEtcher to write the tar.xz file to an SD card.
[Download BalenaEtcher](https://etcher.balena.io/)

## Controls:
- D-pad = Navigation
- B = Edit
- A = Options
- Y or L2 = Shift
- X or R2 = Play
- R3 + D-pad Up or Down = Brightness Up or Down
- Power Button = shut down

## Problems
If you get nothing but a black screen after booting, copy the `rk3326-r35s-linux.dtb` file from the original SD card's /boot partition that came with your device. Then replace/rename it to `rk3326-r36s-linux.dtb` in the /boot partition of your fresh Arkm8c SD card.

Headphone problems with the R36S? This adapter might solve it:
- [AliExpress link](https://bit.ly/43hYwXj)

- you can ssh into arkos to do some problem solving.

  User: ark

  Password: ark

## Changelog:
v2.1 - added auto-connect routine for 1 audio (2 -in 2 -out), and 1 midi device.
having everything connected to a powered usb-hub helps (connect before boot and cross your fingers)
- found out right channel is mirrored to the left. (R36S hardware issue????)

v2.0 - major update more responsive 
- removed all the x11 bloat (i3, lightdm, ect) 
- now uses jackd server
- midi support added in the ~/jjack.sh launch script
- boots-up and shuts down faster
- removed suspend power button behavior, now shuts down
- updated m8c to version 1.7.10

v1.6 - updated m8c to version 1.7.8
- added support for analog sticks in m8c
(Disable analog by renaming gamecontrollerdb.txtBAK to gamecontrollerdb.txt in  ~/.local/share/m8c)

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
- [v1.5](https://bit.ly/arkm8c15)
- [v1.6](https://bit.ly/arkm8c16)
## A very special thanks to:

- Trash80 - [Dirtywave](https://dirtywave.com/)

### and to the creators of:
- [M8C](https://github.com/laamaa/m8c)
- [EatPrilosec / Armbian for R36S](https://github.com/R36S-Stuff/R36S-Armbian)
- [arkos](https://github.com/christianhaitian/a...)
- [pishrink](https://github.com/Drewsif/PiShrink)
- and the entire FOSS Linux community.
