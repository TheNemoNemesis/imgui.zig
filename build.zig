const std = @import("std");

// all platforms and renderers available in imgui
const Platform = enum {};
const Renderer = enum {};

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // create module
    const imgui_mod = b.createModule(.{
        .optimize = optimize,
        .target = target,
    });

    // include c/c++ files
    // ...

    // build library
    const imgui_lib = b.addStaticLibrary(.{
        .name = "imgui",
        .root_module = imgui_mod,
    });
    b.installArtifact(imgui_lib);
}
