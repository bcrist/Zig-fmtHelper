# Zig Formatting Helpers

Includes several `std.Io.Writer.print()` helpers, including:

- `bytes`: automatically format large byte values in KB, MB, GB, TB, etc.
- `si`: automatically format large or small values using SI unit prefixes.

## Example Usage
```zig
pub fn print_stats(some_number_of_bytes: usize, some_number_of_nanoseconds: usize) !void {
    std.debug.print(
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

## Branches
| Zig Version  | Recommended Branch |
|--------------|--------------------|
| 0.18.0-dev.* | zig-master         |
| 0.17.0       | main               |
| 0.16.0       | zig-0.16           |
| 0.15.2       | zig-0.15           |
