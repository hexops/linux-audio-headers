# linux-audio-headers packaged for the Zig build system

This is a Zig package which provides various Linux audio headers needed to develop and cross-compile e.g. sysaudio applications. It includes headers for:

* ALSA
* Jack
* PipeWire
* PulseAudio
* SPA

## Updating

To update this repository, we run the following:

```sh
./update-headers.sh
```

## Verifying repository contents

For supply chain security reasons (e.g. to confirm we made no patches to the code) you can verify the contents of this repository by comparing this repository contents with the result of `update-headers.sh`.
