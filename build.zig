const std = @import("std");

// All platforms and renderers available in imgui
pub const Platform = enum {
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
pub const Renderer = enum {
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
    const platform_option = b.option(Platform, "platform", "Target platform");
    const renderer_option = b.option(Renderer, "renderer", "Target renderer");

    // Check for platform and renderer to be defined
    var platform: Platform = undefined;
    var renderer: Renderer = undefined;
    if (platform_option) |result| { platform = result; }
    else {
        std.log.err("Platform not selected", .{}); 
        return error.Platform_NOT_Selected;
    }
    if (renderer_option) |result| { renderer = result; }
    else {
        std.log.err("Renderer not selected", .{});
        return error.Renderer_NOT_Selected;
    }

    var sources = srcFileList.init(b.allocator);
    defer sources.deinit();

    // Create module
    const imgui_mod = b.createModule(.{
        .optimize = optimize,
        .target = target,
    });

    // Add C/C++ files
    try addSourceFiles(&sources);
    try addBackendSourceFiles(&sources, platform, renderer);
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
    imgui_lib.linkLibCpp();
    imgui_lib.linkLibC();
    // install headers
    imgui_lib.installHeadersDirectory(b.path("dcimgui"), ".", .{.include_extensions = &.{ ".h" }});
    imgui_lib.installHeadersDirectory(b.path("dcimgui/backends"), ".", .{.include_extensions = &.{ ".h" }});
    b.installArtifact(imgui_lib);
}

fn addSourceFiles(sources: *srcFileList) !void {
    try sources.appendSlice(&.{
        "dcimgui.cpp",
        "dcimgui_internal.cpp",
        "imgui.cpp",
        "imgui_demo.cpp",
        "imgui_draw.cpp",
        "imgui_tables.cpp",
        "imgui_widgets.cpp",
    });
}
fn addBackendSourceFiles(sources: *srcFileList, platform: Platform, renderer: Renderer) !void {
    switch (platform) {
        .android => { try sources.appendSlice(&.{ "backends/imgui_impl_android.cpp", "backends/dcimgui_impl_android.cpp" }); },
        .glfw => { try sources.appendSlice(&.{ "backends/imgui_impl_glfw.cpp", "backends/dcimgui_impl_glfw.cpp" }); },
        .sdl2 => { try sources.appendSlice(&.{ "backends/imgui_impl_sdl2.cpp", "backends/dcimgui_impl_sdl2.cpp" }); },
        .sdl3 => { try sources.appendSlice(&.{ "backends/imgui_impl_sdl3.cpp", "backends/dcimgui_impl_sdl3.cpp" }); },
        .win32 => { try sources.appendSlice(&.{ "backends/imgui_impl_win32.cpp", "backends/dcimgui_impl_win32.cpp" }); },
        .glut => { try sources.appendSlice(&.{ "backends/imgui_impl_glut.cpp", "backends/dcimgui_impl_glut.cpp" }); },
        .allegro5 => { try sources.appendSlice(&.{ "backends/imgui_impl_allegro5.cpp", "backends/dcimgui_impl_allegro5.cpp" }); },
    }
    switch (renderer) {
        .dx9 => { try sources.appendSlice(&.{ "backends/imgui_impl_dx9.cpp", "backends/dcimgui_impl_dx9.cpp" }); },
        .dx10 => { try sources.appendSlice(&.{ "backends/imgui_impl_dx10.cpp", "backends/dcimgui_impl_dx10.cpp" }); },
        .dx11 => { try sources.appendSlice(&.{ "backends/imgui_impl_dx11.cpp", "backends/dcimgui_impl_dx11.cpp" }); },
        .dx12 => { try sources.appendSlice(&.{ "backends/imgui_impl_dx12.cpp", "backends/dcimgui_impl_dx12.cpp" }); },
        .opengl2 => { try sources.appendSlice(&.{ "backends/imgui_impl_opengl2.cpp", "backends/dcimgui_impl_opengl2.cpp" }); },
        .opengl3 => { try sources.appendSlice(&.{ "backends/imgui_impl_opengl3.cpp", "backends/dcimgui_impl_opengl3.cpp" }); },
        .sdlgpu3 => { try sources.appendSlice(&.{ "backends/imgui_impl_sdlgpu3.cpp", "backends/dcimgui_impl_sdlgpu3.cpp" }); },
        .sdlrenderer2 => { try sources.appendSlice(&.{ "backends/imgui_impl_sdlrenderer2.cpp", "backends/dcimgui_impl_sdlrenderer2.cpp" }); },
        .sdlrenderer3 => { try sources.appendSlice(&.{ "backends/imgui_impl_sdlrenderer3.cpp", "backends/dcimgui_impl_sdlrenderer3.cpp" }); },
        .vulkan => { try sources.appendSlice(&.{ "backends/imgui_impl_vulkan.cpp", "backends/dcimgui_impl_vulkan.cpp" }); },
        .wgpu => { try sources.appendSlice(&.{ "backends/imgui_impl_wgpu.cpp", "backends/dcimgui_impl_wgpu.cpp" }); },
        .allegro5 => {}, // note: already added in platform, no need to do it here
    }
}
