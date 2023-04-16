#!/bin/bash
set -ex

## alsa-lib
#rm -rf alsa-lib || true
#git clone --depth 1 'git://git.alsa-project.org/alsa-lib.git' _alsa-lib
#pushd _alsa-lib
#./gitcompile
#make DESTDIR="$(pwd)/out" install
#popd
#mkdir alsa-lib
#mv _alsa-lib/out/usr/include/* alsa-lib
#rm -rf _alsa-lib
#
## pulseaudio
#rm -rf pulse || true
#git clone --depth 1 'https://gitlab.freedesktop.org/pulseaudio/pulseaudio.git' _pulseaudio
#mkdir pulse
## list taken from https://gitlab.freedesktop.org/pulseaudio/pulseaudio/-/blob/master/src/pulse/meson.build#L37-67
#libpulse_headers=(
#	'cdecl.h'
#	'channelmap.h'
#	'context.h'
#	'def.h'
#	'direction.h'
#	'error.h'
#	'ext-device-manager.h'
#	'ext-device-restore.h'
#	'ext-stream-restore.h'
#	'format.h'
#	'gccmacro.h'
#	'introspect.h'
#	'mainloop-api.h'
#	'mainloop-signal.h'
#	'mainloop.h'
#	'operation.h'
#	'proplist.h'
#	'pulseaudio.h'
#	'rtclock.h'
#	'sample.h'
#	'scache.h'
#	'stream.h'
#	'subscribe.h'
#	'thread-mainloop.h'
#	'timeval.h'
#	'utf8.h'
#	'util.h'
#	'volume.h'
#	'xmalloc.h'
#)
#for header in "${libpulse_headers[@]}"; do
#	mv "_pulseaudio/src/pulse/$header" "pulse/$header"
#done
## generate version header
#pushd _pulseaudio
#pulseaudio_versions=($(./git-version-gen . |
#	sed -n 's/^\([0-9]\+\)\.\([0-9]\+\).*$/\1 \2/p'))
#
#pa_api_version="$(sed -n 's/pa_api_version = \([0-9]\+\)/\1/p' meson.build)"
#pa_protocol_version="$(sed -n 's/pa_protocol_version = \([0-9]\+\)/\1/p' meson.build)"
#popd
#sed \
#	-e "s/@PA_MAJOR@/${pulseaudio_versions[0]}/g" \
#	-e "s/@PA_MINOR@/${pulseaudio_versions[1]}/g" \
#	-e "s/@PA_API_VERSION@/${pa_api_version}/g" \
#	-e "s/@PA_PROTOCOL_VERSION@/${pa_protocol_version}/g" \
#	_pulseaudio/src/pulse/version.h.in >pulse/version.h
#rm -rf _pulseaudio
#
## jack2
#rm -rf jack || true
#git clone --depth 1 'https://github.com/jackaudio/jack2.git' _jack
#mv _jack/common/jack jack
#rm -rf _jack

# pipewire and SPA
rm -rf pipewire || true
rm -rf spa || true
git clone --depth 1 'https://gitlab.freedesktop.org/pipewire/pipewire.git' _pipewire
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
mv _pipewire/spa/include/spa spa
rm -rf _pipewire
