const Format_Bytes_Data = struct {
    bytes: u64,
    negative: bool = false,
    use_iec_suffixes: bool = false,
    limit: f64 = 1023.5,
};

fn format_bytes(data: Format_Bytes_Data, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
    const max_exponent = 6;
    const limit: f64 = data.limit;
    var value: f64 = @floatFromInt(data.bytes);
    var exponent: u16 = 0;
    while (exponent < max_exponent and value >= limit) {
        exponent += 1;
        value /= 1024;
    }

    if (data.negative) {
        value = -value;
    }

    const suffix = if (data.use_iec_suffixes) switch (exponent) {
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

    var buf: [std.fmt.format_float.bufferSize(.decimal, f64) + 4]u8 = undefined;
    const float_buf = buf[0 .. buf.len - 4];
    var out: []const u8 = buf[0..0];

    if (fmt.len == 0 or comptime std.mem.eql(u8, fmt, "e")) {
        out = std.fmt.formatFloat(float_buf, value, .{ .mode = .scientific, .precision = options.precision }) catch |err| switch (err) {
            error.BufferTooSmall => "(float)",
        };
    } else if (comptime std.mem.eql(u8, fmt, "d")) {
        out = std.fmt.formatFloat(float_buf, value, .{ .mode = .decimal, .precision = options.precision }) catch |err| switch (err) {
            error.BufferTooSmall => "(float)",
        };
    } else if (comptime std.mem.eql(u8, fmt, "x")) {
        var buf_stream = std.io.fixedBufferStream(float_buf);
        std.fmt.formatFloatHexadecimal(value, options, buf_stream.writer()) catch |err| switch (err) {
            error.NoSpaceLeft => unreachable,
        };
        out = buf_stream.getWritten();
    } else {
        std.fmt.invalidFmtError(fmt, value);
    }

    @memcpy(buf[out.len..][0..suffix.len], suffix);
    out = buf[0 .. out.len + suffix.len];

    return std.fmt.formatBuf(out, options, writer);
}

pub fn bytes(n: u64) std.fmt.Formatter(format_bytes) {
    return .{
        .data = .{
            .bytes = n,
        },
    };
}

pub fn bytes_signed(n: i64) std.fmt.Formatter(format_bytes) {
    return .{
        .data = .{
            .bytes = @abs(n),
            .negative = n < 0,
        },
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



const Format_Bytes_Floor_Data = struct {
    bytes: u64,
    negative: bool = false,
    use_iec_suffixes: bool = false,
    limit: u64 = 1024,
};

fn format_bytes_floor(data: Format_Bytes_Floor_Data, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
    _ = fmt;

    const max_exponent = 6;
    var value: u64 = data.bytes;
    var exponent: u16 = 0;
    while (exponent < max_exponent and value >= data.limit) {
        exponent += 1;
        value = @divFloor(value, 1024);
    }

    const signed_value: i64 = @intCast(value);
    const final_value = if (data.negative) -signed_value else signed_value;

    const suffix = if (data.use_iec_suffixes) switch (exponent) {
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

    var buf_stream = std.io.fixedBufferStream(int_buf);
    std.fmt.formatInt(final_value, 10, .lower, .{}, buf_stream.writer()) catch unreachable;
    var out = buf_stream.getWritten();

    @memcpy(buf[out.len..][0..suffix.len], suffix);
    out = buf[0 .. out.len + suffix.len];

    return std.fmt.formatBuf(out, options, writer);
}

/// Like fmtBytes, but always truncates towards zero instead of rounding, and avoids floating point computation entirely.
pub fn bytes_floor(n: u64) std.fmt.Formatter(format_bytes_floor) {
    const data = Format_Bytes_Floor_Data{ .bytes = n };
    return .{ .data = data };
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
