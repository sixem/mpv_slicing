## Fork

This fork changes the script to re-encode the clipped fragments as compressed `.webm` files instead. This is done with the intention of quickly creating clips for using online, for example. The quality and options can be easily adjusted by changing the parameters in the script yourself.

It also fixes an issue with `ffmpeg` outputs not being Windows friendly and causing errors when clipping. The `:` in the filename is the cause of this, so this fork will use hyphens instead to be more OS-agnostic.

---

`slicing-h264.lua` is an alternative script that creates clips from a video source, functioning in the same way as the original script. However, this script simply copies the audio (if toggled) and video, and outputs them to a H264-encoded file. This is just a way of creating raw clips from a video quickly, without affecting the source quality in any big way.

## README
`slicing.lua` is a Lua script for mpv to cut fragments of the video in uncompressed RGB format which might be useful for video editing.

#### Usage

Make sure you have FFmpeg installed. Put `slicing.lua` to `~/.config/mpv/scripts/` or `~/.mpv/scripts/` directory to autoload the script or load it manually with `--script=<path>`.

Press `c` first time to mark the start of the fragment. Press it again to mark the end of the fragment and write it to the disk. Press `a` to toggle uncompressed audio capturing (default on). By default output videos will be placed in the home directory.

You could change key bindings and all parameters of the output video by editing your `input.conf` and `lua-settings/slicing.conf`, see [slicing.lua](https://github.com/Kagami/mpv_slicing/blob/master/slicing.lua) for details.

#### License

mpv_slicing - Cut video fragments with mpv

Written in 2015 by Kagami Hiiragi <kagami@genshiken.org>

To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this software to the public domain worldwide. This software is distributed without any warranty.

You should have received a copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
