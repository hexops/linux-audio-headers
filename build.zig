const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "linux-audio-headers",
        .root_source_file = .{ .path = "stub.c" },
        .target = target,
        .optimize = optimize,
    });

    lib.installHeadersDirectory("alsa-lib", ".");
    lib.installHeadersDirectory("jack", "jack");
    lib.installHeadersDirectory("pipewire", "pipewire");
    lib.installHeadersDirectory("pulse", "pulse");
    lib.installHeadersDirectory("spa", "spa");

    b.installArtifact(lib);
}
