ImGui.zig
===

## What is ImGui.zig?
ImGui with c bindings and zig build system. This repo should be updated anytime there is a new imgui tag.
The minimum zig version required is "1.14.1".

## How to use it

Fetch imgui.zig
```sh
zig fetch --save git+https://github.com/TheNemoNemesis/imgui.zig.git
```

Than import it as a dependency into your build.zig 

```diff
const std = @import("std");
+ const imgui = @import("imgui_zig");

pub fn build(b: *std.Build) {
    // ...
    
+    const imgui_dep = b.dependency("imgui_zig", .{
+        .target = target,
+        .optimize = optimize,
+        .platform = imgui.Platform.sdl3,
+        .renderer = imgui.Platform.sdlrenderer3,
+    });

    // "exe" represents your executable/library
+    exe.linkLibrary(imgui_dep.artifact("imgui"));

    // ...
}
```

## Backends
ImGui.zig supports almost every imgui backend, with the exception of osx and metal. 
Most of the backends are not tested (only sdl3, sdlrender3 and opengl3 were tested), so feel free to add suggestions to improve this project.

## Dependencies
ImGui.zig is dependency free, you can add the platform and backend libraries independently from "imgui.zig".

## Credits
Thanks to [orconut/imgui](https://github.com/ocornut/imgui) for the imgui library and to [dearimgui/dear_bindings](https://github.com/dearimgui/dear_bindings) for the C bindings.
Also thanks to [thedmd/imgui](https://github.com/thedmd/imgui/tree/layouts) for the stacklayout implementation used in the "master_stacklayout" and "docking_stacklayout" branches.
