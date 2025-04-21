# Zig-fmtHelper

Includes several std.fmt helpers, including:

- `bytes`: automatically format large byte values in KB, MB, GB, TB, etc.
- `si`: automatically format large or small values using SI unit prefixes.

## Installation

Add to your `build.zig.zon`:
```
$ zig fetch --save git+https://github.com/bcrist/Zig-fmtHelper
```

Add to your `build.zig`:
```zig
pub fn build(b: *std.Build) void {
    const fmt_module = b.dependency("fmt_helper", .{}).module("fmt");

    //...

    const exe = b.addExecutable(.{
        //...
    });
    exe.root_module.addImport("fmt", fmt_module);

    //...
}
```
