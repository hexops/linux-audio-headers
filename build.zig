const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "linux-audio-headers",
        .root_source_file = b.addWriteFiles().add("empty.c", ""),
        .target = target,
        .optimize = optimize,
    });

    installHeadersDirectoryExcludeLicenseFiles(lib, "alsa-lib", ".");
    installHeadersDirectoryExcludeLicenseFiles(lib, "jack", "jack");
    installHeadersDirectoryExcludeLicenseFiles(lib, "pipewire", "pipewire");
    installHeadersDirectoryExcludeLicenseFiles(lib, "pulse", "pulse");
    installHeadersDirectoryExcludeLicenseFiles(lib, "sndio", ".");
    installHeadersDirectoryExcludeLicenseFiles(lib, "spa", "spa");

    b.installArtifact(lib);
}

fn installHeadersDirectoryExcludeLicenseFiles(
    lib: *std.build.Step.Compile,
    src_dir_path: []const u8,
    dest_rel_path: []const u8,
) void {
    lib.installHeadersDirectoryOptions(.{
        .source_dir = .{ .path = src_dir_path },
        .install_dir = .header,
        .install_subdir = dest_rel_path,
        .exclude_extensions = &.{ "COPYING", "LICENSE" },
    });
}
