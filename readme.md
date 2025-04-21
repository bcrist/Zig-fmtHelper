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

## Example Usage
```zig
pub fn print_stats(some_number_of_bytes: usize, some_number_of_nanoseconds: usize) !void {
    std.io.getStdOut().writer().print(
        \\   some number of bytes: {}
        \\   some duration: {}
        \\
    , .{
        fmt.bytes(some_number_of_bytes),
        fmt.si.ns(some_number_of_nanoseconds),
    });
}

const fmt = @import("fmt");
const std = @import("std");
```
Possible output:
```
   some number of bytes: 3 KB
   some duration: 47 ms
```
