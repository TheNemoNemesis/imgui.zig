const std = @import("std");

// All platforms and renderers available in imgui
const Platform = enum {
    android,
    glfw,
    sdl2,
    sdl3,
    win32,
    glut,
    allegro5 // this is a high level framework that serves both pourposes

    // note: not supported osx build since dear_bindings doesnt provide bindings
    // osx,
};
const Renderer = enum {
    dx9,
    dx10,
    dx11,
    dx12,
    opengl2,
    opengl3,
    sdlgpu3,
    sdlrenderer2,
    sdlrenderer3,
    vulkan,
    wgpu,
    allegro5 // this is a high level framework that serves both pourposes

    // note: not supported metal build since dear_bindings doesnt provide bindings
    // metal,
};

const srcFileList = std.ArrayList([]const u8); 

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const platform = b.option(Platform, "platform", "Target platform");
    const renderer = b.option(Renderer, "renderer", "Target renderer");

    var sources = srcFileList.init(b.allocator);
    defer sources.deinit();

    // Create module
    const imgui_mod = b.createModule(.{
        .optimize = optimize,
        .target = target,
    });

    // Add C/C++ files
    addSourceFiles(b, sources);
    addBackendSourceFiles(b, sources, platform, renderer);
    imgui_mod.addIncludePath(b.path("dcimgui"));
    imgui_mod.addIncludePath(b.path("dcimgui/backends"));
    imgui_mod.addCSourceFiles(.{
        .root = b.path("dcimgui"),
        .files = sources.items,
    });

    // Build library
    const imgui_lib = b.addStaticLibrary(.{
        .name = "imgui",
        .root_module = imgui_mod,
    });
    b.installArtifact(imgui_lib);
}

fn addSourceFiles(b: *std.Build, sources: srcFileList) !void {
    var dir = try std.fs.cwd().openDir("dcimgui", .{ .iterate = true });
    defer dir.close();
    var walker = try dir.walk(b.allocator);
    defer walker.deinit();
    while (try walker.next()) |entry| {
        const ext = std.fs.path.extension(entry.basename);
        if (std.mem.eql(u8, ext, ".c") or std.mem.eql(u8, ext, ".cpp")) {
            try sources.append(b.dupe(entry.path));
        }
    }
}
fn addBackendSourceFiles(sources: srcFileList, platform: Platform, renderer: Renderer) !void {
    switch (platform) {
        .android => { try sources.append("dcimgui/backends/dcimgui_impl_android.cpp"); },
        .glfw => { try sources.append("dcimgui/backends/dcimgui_impl_glfw.cpp"); },
        .sdl2 => { try sources.append("dcimgui/backends/dcimgui_impl_sdl2.cpp"); },
        .sdl3 => { try sources.append("dcimgui/backends/dcimgui_impl_sdl3.cpp"); },
        .win32 => { try sources.append("dcimgui/backends/dcimgui_impl_win32.cpp"); },
        .glut => { try sources.append("dcimgui/backends/dcimgui_impl_glut.cpp"); },
        .allegro5 => { try sources.append("dcimgui/backends/dcimgui_impl_allegro5.cpp"); },
        else => {},
    }
    switch (renderer) {
        .dx9 => { try sources.append("dcimgui/backends/dcimgui_impl_dx9.cpp"); },
        .dx10 => { try sources.append("dcimgui/backends/dcimgui_impl_dx10.cpp"); },
        .dx11 => { try sources.append("dcimgui/backends/dcimgui_impl_dx11.cpp"); },
        .dx12 => { try sources.append("dcimgui/backends/dcimgui_impl_dx12.cpp"); },
        .opengl2 => { try sources.append("dcimgui/backends/dcimgui_impl_opengl2.cpp"); },
        .opengl3 => { try sources.append("dcimgui/backends/dcimgui_impl_opengl3.cpp"); },
        .sdlgpu3 => { try sources.append("dcimgui/backends/dcimgui_impl_sdlgpu3.cpp"); },
        .sdlrenderer2 => { try sources.append("dcimgui/backends/dcimgui_impl_sdlrenderer2.cpp"); },
        .sdlrenderer3 => { try sources.append("dcimgui/backends/dcimgui_impl_sdlrenderer3.cpp"); },
        .vulkan => { try sources.append("dcimgui/backends/dcimgui_impl_vulkan.cpp"); },
        .wgpu => { try sources.append("dcimgui/backends/dcimgui_impl_wgpu.cpp"); },
        .allegro5 => {}, // note: already added in platform, no need to do it here
        else => {},
    }
}
