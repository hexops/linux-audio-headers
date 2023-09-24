#!/usr/bin/env bash
set -euo pipefail
set -x

ALSA_REV=81a7a93636d9472fcb0c2ff32d9bfdf6ed10763d
PULSEAUDIO_REV=13ef02da1bc55b8a36ff35ca5f9d15cf7495932a
JACK_REV=250420381b1a6974798939ad7104ab1a4b9a9994
PIPEWIRE_REV=8b807ded354d8c2888de3204f386f31b64ad3170
SNDIO_REV=3e280d53174253156dd38d0defdb4d774aa8f501

# `git clone --depth 1` but at a specific revision
git_clone_rev() {
    repo=$1
    rev=$2
    dir=$3

    rm -rf "$dir"
    mkdir "$dir"
    pushd "$dir"
    git init -q
    git fetch "$repo" "$rev" --depth 1
    git checkout -q FETCH_HEAD
    popd
}

# alsa-lib
rm -rf alsa-lib
git_clone_rev git://git.alsa-project.org/alsa-lib.git "$ALSA_REV" _alsa-lib
pushd _alsa-lib
./gitcompile
make DESTDIR="$PWD/out" install
popd
mkdir alsa-lib
mv _alsa-lib/COPYING alsa-lib/LICENSE
mv _alsa-lib/out/usr/include/* alsa-lib
rm -rf _alsa-lib

# pulseaudio
rm -rf pulse
# pulseaudio requires a slightly deeper git history + tags to be able to compute the version number
rm -rf _pulseaudio
mkdir _pulseaudio
pushd _pulseaudio
git init -q
# change this depth if the script stops working when updating the rev
git fetch https://gitlab.freedesktop.org/pulseaudio/pulseaudio.git "$PULSEAUDIO_REV" --depth 10 --tags
git checkout -q FETCH_HEAD
popd
mkdir pulse
# list taken from https://gitlab.freedesktop.org/pulseaudio/pulseaudio/-/blob/master/src/pulse/meson.build#L37-67
libpulse_headers=(
    'cdecl.h'
    'channelmap.h'
    'context.h'
    'def.h'
    'direction.h'
    'error.h'
    'ext-device-manager.h'
    'ext-device-restore.h'
    'ext-stream-restore.h'
    'format.h'
    'gccmacro.h'
    'introspect.h'
    'mainloop-api.h'
    'mainloop-signal.h'
    'mainloop.h'
    'operation.h'
    'proplist.h'
    'pulseaudio.h'
    'rtclock.h'
    'sample.h'
    'scache.h'
    'stream.h'
    'subscribe.h'
    'thread-mainloop.h'
    'timeval.h'
    'utf8.h'
    'util.h'
    'volume.h'
    'xmalloc.h'
    # additional optional headers listed in that same mson.build file
    'glib-mainloop.h'
    'simple.h'
)
for header in "${libpulse_headers[@]}"; do
    mv "_pulseaudio/src/pulse/$header" "pulse/$header"
done
mv _pulseaudio/LICENSE pulse
# generate version header
pushd _pulseaudio
pulseaudio_versions=($(./git-version-gen . |
    sed -n 's/^\([0-9]\+\)\.\([0-9]\+\).*$/\1 \2/p'))

pa_api_version="$(sed -n 's/pa_api_version = \([0-9]\+\)/\1/p' meson.build)"
pa_protocol_version="$(sed -n 's/pa_protocol_version = \([0-9]\+\)/\1/p' meson.build)"
popd
sed \
    -e "s/@PA_MAJOR@/${pulseaudio_versions[0]}/g" \
    -e "s/@PA_MINOR@/${pulseaudio_versions[1]}/g" \
    -e "s/@PA_API_VERSION@/${pa_api_version}/g" \
    -e "s/@PA_PROTOCOL_VERSION@/${pa_protocol_version}/g" \
    _pulseaudio/src/pulse/version.h.in >pulse/version.h
rm -rf _pulseaudio

# jack2
rm -rf jack
git_clone_rev https://github.com/jackaudio/jack2.git "$JACK_REV" _jack
mv _jack/common/jack jack
mv _jack/COPYING jack/LICENSE
rm -rf _jack

# pipewire and SPA
rm -rf pipewire spa
git_clone_rev https://gitlab.freedesktop.org/pipewire/pipewire.git "$PIPEWIRE_REV" _pipewire
mkdir -p pipewire/extensions/session-manager
# Taken from pipewire's meson.build files
pipewire_headers=(
    'array.h'
    'buffers.h'
    'impl-core.h'
    'impl-client.h'
    'client.h'
    'conf.h'
    'context.h'
    'control.h'
    'core.h'
    'device.h'
    'impl-device.h'
    'data-loop.h'
    'factory.h'
    'impl-factory.h'
    'filter.h'
    'global.h'
    'keys.h'
    'impl.h'
    'i18n.h'
    'impl-link.h'
    'link.h'
    'log.h'
    'loop.h'
    'main-loop.h'
    'map.h'
    'mem.h'
    'impl-metadata.h'
    'impl-module.h'
    'module.h'
    'impl-node.h'
    'node.h'
    'permission.h'
    'pipewire.h'
    'impl-port.h'
    'port.h'
    'properties.h'
    'protocol.h'
    'proxy.h'
    'resource.h'
    'stream.h'
    'thread.h'
    'thread-loop.h'
    'type.h'
    'utils.h'
    'work-queue.h'

    'extensions/session-manager/impl-interfaces.h'
    'extensions/session-manager/interfaces.h'
    'extensions/session-manager/introspect.h'
    'extensions/session-manager/introspect-funcs.h'
    'extensions/session-manager/keys.h'

    'extensions/client-node.h'
    'extensions/metadata.h'
    'extensions/profiler.h'
    'extensions/protocol-native.h'
    'extensions/session-manager.h'
)
for header in "${pipewire_headers[@]}"; do
    mv "_pipewire/src/pipewire/$header" "pipewire/$header"
done
# generate version header
pw_versions=($(sed -n 's/^ *version : '\''\([0-9]\+\)\.\([0-9]\+\)\.\([0-9]\+\)'\'',$/\1 \2 \3/p' _pipewire/meson.build))
pw_api_version="$(sed -n 's/^apiversion = '\''\(.*\)'\''$/\1/p' _pipewire/meson.build)"
sed \
    -e "s/@PIPEWIRE_VERSION_MAJOR@/${pw_versions[0]}/g" \
    -e "s/@PIPEWIRE_VERSION_MINOR@/${pw_versions[1]}/g" \
    -e "s/@PIPEWIRE_VERSION_MICRO@/${pw_versions[2]}/g" \
    -e "s/@PIPEWIRE_VERSION_NANO@/0/g" \
    -e "s/@PIPEWIRE_API_VERSION@/${pw_api_version}/g" \
    _pipewire/src/pipewire/version.h.in >pipewire/version.h
cp _pipewire/LICENSE pipewire
mv _pipewire/spa/include/spa spa
rm -f spa/utils/cleanup.h # see https://gitlab.freedesktop.org/pipewire/pipewire/-/blob/master/spa/include/meson.build
mv _pipewire/LICENSE spa
rm -rf _pipewire

#sndio
rm -rf sndio
mkdir sndio
git_clone_rev https://github.com/ratchov/sndio.git "$SNDIO_REV" _sndio
mv _sndio/libsndio/sndio.h sndio
mv _sndio/LICENSE sndio
rm -rf _sndio
