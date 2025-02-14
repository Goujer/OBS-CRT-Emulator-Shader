# OBS-CRT-Emulator-Shader
A shader for obs-shaderfilter that emulates how a CRT electron gun moves.

Can do both interlaced and progressive scanning.

Emulates an Apeture Grille with 10pixels per TVL.
8pixel per TVL version also available. (At 1920 wide that gives you 240TVL)

Each 3rd of the screen vertically has a 10% dim to mimic the support wire found in trinitron displays.

Compared to other scanline filters/shaders this one not only creates horizontal lines but it also tracks the "beam"'s horizontal movement on each line.
Strives more for accuracy rather than looking good.

Requires using: https://github.com/exeldro/obs-shaderfilter
