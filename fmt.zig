const Format_Bytes = struct {
    bytes: u64,
    negative: bool = false,
    use_iec_suffixes: bool = false,
    limit: f64 = 1023.5,

    pub fn format(self: Format_Bytes, writer: *std.Io.Writer) !void {
        try self.formatNumber(writer, .{});
    }

    pub fn formatNumber(self: Format_Bytes, writer: *std.Io.Writer, options: std.fmt.Number) !void {
        const max_exponent = 6;
        const limit: f64 = self.limit;
        var value: f64 = @floatFromInt(self.bytes);
        var exponent: u16 = 0;
        while (exponent < max_exponent and value >= limit) {
            exponent += 1;
            value /= 1024;
        }

        if (self.negative) {
            value = -value;
        }

        const suffix = if (self.use_iec_suffixes) switch (exponent) {
            0 => " B",
            1 => " KiB",
            2 => " MiB",
            3 => " GiB",
            4 => " TiB",
            5 => " PiB",
            6 => " EiB",
            else => unreachable,
        } else switch (exponent) {
            0 => " B",
            1 => " KB",
            2 => " MB",
            3 => " GB",
            4 => " TB",
            5 => " PB",
            6 => " EB",
            else => unreachable,
        };

        var buf: [std.fmt.float.bufferSize(.decimal, f64) + 4]u8 = undefined;
        const float_buf = buf[0 .. buf.len - 4];
        var out: []const u8 = buf[0..0];
        
        switch (options.mode) {
            .decimal, .scientific => {
                out = std.fmt.float.render(float_buf, value, .{
                    .mode = switch (options.mode) {
                        .decimal => .decimal,
                        .scientific => .scientific,
                        else => unreachable,
                    },
                    .precision = options.precision,
                }) catch |err| switch (err) {
                    error.BufferTooSmall => result: {
                        @memcpy((&buf).ptr, "(float)");
                        break :result buf[0.."(float)".len];
                    },
                };
            },
            else => {
                var buf_writer = std.Io.Writer.fixed(float_buf);
                buf_writer.printFloatHexOptions(value, options) catch unreachable;
                out = buf_writer.buffered();
            },
        }

        @memcpy(buf[out.len..][0..suffix.len], suffix);
        out = buf[0 .. out.len + suffix.len];

        return writer.alignBuffer(out, options.width orelse out.len, options.alignment, options.fill);
    }
};

pub fn bytes(n: u64) Format_Bytes {
    return .{ .bytes = n };
}

pub fn bytes_signed(n: i64) Format_Bytes {
    return .{
        .bytes = @abs(n),
        .negative = n < 0,
    };
}

test bytes {
    var buf: [24]u8 = undefined;
    inline for (.{
        .{ .fmt = "{d}", .s = "0 B", .b = 0 },
        .{ .fmt = "{d}", .s = "1 B", .b = 1 },
        .{ .fmt = "{d}", .s = "1023 B", .b = 1023 },
        .{ .fmt = "{d}", .s = "1 KB", .b = 1024 },
        .{ .fmt = "{d}", .s = "1 MB", .b = 1024 * 1024 },
        .{ .fmt = "{d}", .s = "1 GB", .b = 1024 * 1024 * 1024 },
        .{ .fmt = "{d}", .s = "1 TB", .b = 1024 * 1024 * 1024 * 1024 },
        .{ .fmt = "{d}", .s = "1.5 KB", .b = 1536 },
        .{ .fmt = "{d:.1}", .s = "1.0 MB", .b = 1024 * 1024 - 1 },
        .{ .fmt = "{d:.1}", .s = "1.0 GB", .b = 1024 * 1024 * 1024 - 1 },
        .{ .fmt = "{d:.1}", .s = "1.0 TB", .b = 1024 * 1024 * 1024 * 1024 - 1 },
        .{ .fmt = "{d:.3}", .s = "1023.023 KB", .b = 1024 * 1024 - 1000 },
        .{ .fmt = "{e:.3}", .s = "1.023e3 KB", .b = 1024 * 1024 - 1000 },
        .{ .fmt = "{d:.3}", .s = "1023.046 MB", .b = 1024 * 1024 * 1024 - 1000 * 1000 },
        .{ .fmt = "{d:.3}", .s = "1023.069 GB", .b = 1024 * 1024 * 1024 * 1024 - 1000 * 1000 * 1000 },
        .{ .fmt = "{d}", .s = "0.9999990463256836 MB", .b = 1024 * 1024 - 1 },
        .{ .fmt = "{d}", .s = "0.9999999990686774 GB", .b = 1024 * 1024 * 1024 - 1 },
        .{ .fmt = "{d}", .s = "0.9999999999990905 TB", .b = 1024 * 1024 * 1024 * 1024 - 1 },
        .{ .fmt = "{d}", .s = "16 EB", .b = std.math.maxInt(u64) },
        .{ .fmt = "{d:=>10}", .s = "=======0 B", .b = 0 },
        .{ .fmt = "{d:=<10}", .s = "1 B=======", .b = 1 },
        .{ .fmt = "{d:^10}",  .s = "  100 KB  ", .b = 102400 },
    }) |tc| {
        const slice = try std.fmt.bufPrint(&buf, tc.fmt, .{ bytes(tc.b) });
        try std.testing.expectEqualStrings(tc.s, slice);
    }
}

const Format_Bytes_Floor = struct {
    bytes: u64,
    negative: bool = false,
    use_iec_suffixes: bool = false,
    limit: u64 = 1024,

    pub fn format(self: Format_Bytes_Floor, writer: *std.Io.Writer) !void {
        try self.formatNumber(writer, .{});
    }

    pub fn formatNumber(self: Format_Bytes_Floor, writer: *std.Io.Writer, options: std.fmt.Number) !void {
        const max_exponent = 6;
        var value: u64 = self.bytes;
        var exponent: u16 = 0;
        while (exponent < max_exponent and value >= self.limit) {
            exponent += 1;
            value = @divFloor(value, 1024);
        }

        const signed_value: i64 = @intCast(value);
        const final_value = if (self.negative) -signed_value else signed_value;

        const suffix = if (self.use_iec_suffixes) switch (exponent) {
            0 => " B",
            1 => " KiB",
            2 => " MiB",
            3 => " GiB",
            4 => " TiB",
            5 => " PiB",
            6 => " EiB",
            else => unreachable,
        } else switch (exponent) {
            0 => " B",
            1 => " KB",
            2 => " MB",
            3 => " GB",
            4 => " TB",
            5 => " PB",
            6 => " EB",
            else => unreachable,
        };

        var buf: [25]u8 = undefined;
        const int_buf = buf[0 .. buf.len - 4];

        var buf_writer = std.Io.Writer.fixed(int_buf);
        buf_writer.printInt(final_value, 10, .lower, .{}) catch unreachable;
        var out = buf_writer.buffered();

        @memcpy(buf[out.len..][0..suffix.len], suffix);
        out = buf[0 .. out.len + suffix.len];

        return writer.alignBuffer(out, options.width orelse out.len, options.alignment, options.fill);
    }
};

/// Like fmtBytes, but always truncates towards zero instead of rounding, and avoids floating point computation entirely.
pub fn bytes_floor(n: u64) Format_Bytes_Floor {
    return .{ .bytes = n };
}

test bytes_floor {
    var buf: [24]u8 = undefined;
    inline for (.{
        .{ .fmt = "{d}", .s = "0 B", .b = 0 },
        .{ .fmt = "{d}", .s = "1 B", .b = 1 },
        .{ .fmt = "{d}", .s = "1023 B", .b = 1023 },
        .{ .fmt = "{d}", .s = "1 KB", .b = 1024 },
        .{ .fmt = "{d}", .s = "1 MB", .b = 1024 * 1024 },
        .{ .fmt = "{d}", .s = "1 GB", .b = 1024 * 1024 * 1024 },
        .{ .fmt = "{d}", .s = "1 TB", .b = 1024 * 1024 * 1024 * 1024 },
        .{ .fmt = "{d}", .s = "1 KB", .b = 1536 },
        .{ .fmt = "{d}", .s = "1023 KB", .b = 1024 * 1024 - 1 },
        .{ .fmt = "{d}", .s = "1023 MB", .b = 1024 * 1024 * 1024 - 1 },
        .{ .fmt = "{d}", .s = "1023 GB", .b = 1024 * 1024 * 1024 * 1024 - 1 },
        .{ .fmt = "{d}", .s = "1023 KB", .b = 1024 * 1024 - 1000 },
        .{ .fmt = "{d}", .s = "1023 MB", .b = 1024 * 1024 * 1024 - 1000 * 1000 },
        .{ .fmt = "{d}", .s = "1023 GB", .b = 1024 * 1024 * 1024 * 1024 - 1000 * 1000 * 1000 },
        .{ .fmt = "{d}", .s = "15 EB", .b = std.math.maxInt(u64) },
        .{ .fmt = "{d:=>10}", .s = "=======0 B", .b = 0 },
        .{ .fmt = "{d:=<10}", .s = "1 B=======", .b = 1 },
        .{ .fmt = "{d:^10}",  .s = "  100 KB  ", .b = 102400 },
    }) |tc| {
        const slice = try std.fmt.bufPrint(&buf, tc.fmt, .{ bytes_floor(tc.b) });
        try std.testing.expectEqualStrings(tc.s, slice);
    }
}

pub const si = @import("si.zig");
comptime {
    _ = si; // ensure tests are run
}

const std = @import("std");
