# linux-audio-headers packaged for the Zig build system

This is a Zig package which provides various Linux audio headers needed to develop and cross-compile e.g. sysaudio applications. It includes headers for:

* ALSA
* Jack
* PipeWire
* PulseAudio
* SPA

## Updating

To update this repository, run `./update.sh` followed by `./verify.sh` to verify the repository contents.

## Verifying repository contents

For supply chain security reasons (e.g. to confirm we made no patches to the code) we provide a `git diff` command you can run to verify the contents of this repository:

```sh
./verify.sh
```

If nothing is printed, there is no diff. Deleted files, and changes to `README.md`, `build.zig`, `.github` CI files and `.gitignore` are ignored.

## Issues

Issues are tracked in the [main Mach repository](https://github.com/hexops/mach/issues?q=is%3Aissue+is%3Aopen+label%3Alinux-audio-headers).
