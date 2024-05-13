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

pub fn fmtBytes(bytes: u64) std.fmt.Formatter(format_bytes) {
    const data = Format_Bytes_Data{ .bytes = bytes };
    return .{ .data = data };
}

test fmtBytes {
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
        const slice = try std.fmt.bufPrint(&buf, tc.fmt, .{ fmtBytes(tc.b) });
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
pub fn fmtBytesFloor(bytes: u64) std.fmt.Formatter(format_bytes_floor) {
    const data = Format_Bytes_Floor_Data{ .bytes = bytes };
    return .{ .data = data };
}

test fmtBytesFloor {
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
        const slice = try std.fmt.bufPrint(&buf, tc.fmt, .{ fmtBytesFloor(tc.b) });
        try std.testing.expectEqualStrings(tc.s, slice);
    }
}

const Format_SI_Float_Data = struct {
    value: f64,
    limit: f64 = 999.5,
    unit: []const u8,
    use_utf8: bool = true,
};

fn format_si_float(data: Format_SI_Float_Data, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
    if (data.unit.len > 32) return error.InvalidUnit;

    const min_exponent = -10;
    const max_exponent = 10;
    var value = @abs(data.value);
    var exponent: i16 = 0;
    while (exponent < max_exponent and value >= data.limit) {
        exponent += 1;
        value /= 1000;
    }
    const limit = data.limit / 1000;
    while (exponent > min_exponent and value < limit and value != 0) {
        exponent -= 1;
        value *= 1000;
    }

    if (data.value < 0) {
        value = -value;
    }

    const suffix: []const u8 = switch (exponent) {
        -10 => " q",
        -9 => " r",
        -8 => " y",
        -7 => " z",
        -6 => " a",
        -5 => " f",
        -4 => " p",
        -3 => " n",
        -2 => if (data.use_utf8) " \u{b5}" else " u",
        -1 => " m",
        0 => " ",
        1 => " k",
        2 => " M",
        3 => " G",
        4 => " T",
        5 => " P",
        6 => " E",
        7 => " Z",
        8 => " Y",
        9 => " R",
        10 => " Q",
        else => unreachable,
    };

    var buf: [std.fmt.format_float.bufferSize(.decimal, f64) + 35]u8 = undefined;
    const float_buf = buf[0 .. buf.len - 35];
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
    @memcpy(buf[out.len + suffix.len ..][0..data.unit.len], data.unit);
    out = buf[0 .. out.len + suffix.len + data.unit.len];

    return std.fmt.formatBuf(out, options, writer);
}


pub const Format_SI_Int_Options = struct {
    unit: []const u8,
    exponent_offset: i16 = 0,
    use_utf8: bool = true,
    limit: comptime_int = 1000,
};

fn Format_SI_Int(comptime T: type, comptime si_options: Format_SI_Int_Options) type {
    return struct {
        value: T,

        pub const Formatter = std.fmt.Formatter(format);

        pub fn format(data: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            _ = fmt;

            const min_exponent = -10;
            const max_exponent = 10;

            const precision = options.precision orelse 0;
            if (precision > 32) return error.InvalidPrecision;

            var precision_buf: [32]u8 = .{ 0 } ** 32;
            var precision_slice = precision_buf[0..precision];

            var exponent = si_options.exponent_offset;
            var value = @abs(data.value);
            while (exponent > max_exponent) {
                value *= 1000;
                exponent -= 1;
            }
            while (exponent < min_exponent or (exponent < max_exponent and value >= si_options.limit)) {
                for (0..3) |_| {
                    if (precision > 0) {
                        const remainder: u8 = @intCast(value % 10);
                        std.mem.copyBackwards(u8, precision_slice[1..], precision_slice[0 .. precision_slice.len - 1]);
                        precision_slice[0] = '0' + remainder;
                    }
                    value = @divTrunc(value, 10);
                }
                exponent += 1;
            }

            const suffix: []const u8 = switch (exponent) {
                -10 => "q",
                -9 => "r",
                -8 => "y",
                -7 => "z",
                -6 => "a",
                -5 => "f",
                -4 => " p",
                -3 => " n",
                -2 => if (si_options.use_utf8) " \u{b5}" else " u",
                -1 => " m",
                0 => " ",
                1 => " k",
                2 => " M",
                3 => " G",
                4 => " T",
                5 => " P",
                6 => " E",
                7 => " Z",
                8 => " Y",
                9 => " R",
                10 => " Q",
                else => unreachable,
            };

            var buf: [@bitSizeOf(T) / 3 + 36 + si_options.unit.len]u8 = undefined;
            var buf_stream = std.io.fixedBufferStream(&buf);
            var w = buf_stream.writer();

            if (data.value < 0) {
                w.writeByte('-') catch unreachable;
            }

            std.fmt.formatInt(value, 10, .lower, .{}, w) catch unreachable;

            if (options.precision) |_| {
                w.writeByte('.') catch unreachable;
                w.writeAll(precision_slice) catch unreachable;
            }

            w.writeAll(suffix) catch unreachable;
            w.writeAll(si_options.unit) catch unreachable;

            return std.fmt.formatBuf(buf_stream.getWritten(), options, writer);
        }
    };
}



fn Format_SI_Formatter(comptime T: type, comptime unit: []const u8) type {
    return switch (@typeInfo(T)) {
        .Float, .ComptimeFloat => std.fmt.Formatter(format_si_float),
        .Int => Format_SI_Int(T, .{ .unit = unit }).Formatter,
        .ComptimeInt => Format_SI_Int(i64, .{ .unit = unit }).Formatter,
        else => @compileError("Expected float or int value"),
    };
}

pub fn fmtSI(value: anytype, comptime unit: []const u8) Format_SI_Formatter(@TypeOf(value), unit) {
    switch (@typeInfo(@TypeOf(value))) {
        .Float, .ComptimeFloat => {
            const data = Format_SI_Float_Data{ .value = value, .unit = unit };
            return .{ .data = data };
        },
        .Int => {
            const data = Format_SI_Int(@TypeOf(value), .{ .unit = unit }) { .value = value };
            return .{ .data = data };
        },
        .ComptimeInt => {
            const data = Format_SI_Int(i64, .{ .unit = unit }) { .value = @intCast(value) };
            return .{ .data = data };
        },
        else => @compileError("Expected float or int value"),
    }
}


/// N.B this is mainly useful for small floating point durations; consider using std.fmt.fmtDuration for longer periods
pub inline fn fmtSeconds(value: anytype) Format_SI_Formatter(@TypeOf(value), "s") { return fmtSI(value, "s"); }
pub inline fn fmtGrams(value: anytype) Format_SI_Formatter(@TypeOf(value), "g") { return fmtSI(value, "g"); }
pub inline fn fmtMeters(value: anytype) Format_SI_Formatter(@TypeOf(value), "m") { return fmtSI(value, "m"); }
pub inline fn fmtLiters(value: anytype) Format_SI_Formatter(@TypeOf(value), "L") { return fmtSI(value, "L"); }
pub inline fn fmtKelvins(value: anytype) Format_SI_Formatter(@TypeOf(value), "K") { return fmtSI(value, "K"); }
pub inline fn fmtRadians(value: anytype) Format_SI_Formatter(@TypeOf(value), "rad") { return fmtSI(value, "rad"); }
pub inline fn fmtHertz(value: anytype) Format_SI_Formatter(@TypeOf(value), "Hz") { return fmtSI(value, "Hz"); }
pub inline fn fmtVolts(value: anytype) Format_SI_Formatter(@TypeOf(value), "V") { return fmtSI(value, "V"); }
pub inline fn fmtAmps(value: anytype) Format_SI_Formatter(@TypeOf(value), "A") { return fmtSI(value, "A"); }
pub inline fn fmtWatts(value: anytype) Format_SI_Formatter(@TypeOf(value), "W") { return fmtSI(value, "W"); }
pub inline fn fmtJoules(value: anytype) Format_SI_Formatter(@TypeOf(value), "J") { return fmtSI(value, "J"); }
pub inline fn fmtOhms(value: anytype) Format_SI_Formatter(@TypeOf(value), "\u{3A9}") { return fmtSI(value, "\u{3A9}"); }
pub inline fn fmtFarads(value: anytype) Format_SI_Formatter(@TypeOf(value), "F") { return fmtSI(value, "F"); }
pub inline fn fmtHenries(value: anytype) Format_SI_Formatter(@TypeOf(value), "H") { return fmtSI(value, "H"); }

test fmtSI {
    var buf: [24]u8 = undefined;
    inline for (.{
        .{ .u = "m", .fmt = "{d}", .s = "0 m", .b = 0 },
        .{ .u = "m", .fmt = "{d}", .s = "1 m", .b = 1 },
        .{ .u = "m", .fmt = "{d}", .s = "999 m", .b = 999 },
        .{ .u = "m", .fmt = "{d}", .s = "1 km", .b = 1000 },
        .{ .u = "m", .fmt = "{d}", .s = "1 km", .b = 1423 },
        .{ .u = "m", .fmt = "{d}", .s = "1 km", .b = 1999 },
        .{ .u = "m", .fmt = "{d:.3}", .s = "1.023 km", .b = 1023 },
        .{ .u = "m", .fmt = "{d:.3}", .s = "1.023 Mm", .b = 1023456 },
        .{ .u = "m", .fmt = "{d:=>10}", .s = "=======0 m", .b = 0 },
        .{ .u = "m", .fmt = "{d:=<10}", .s = "1 m=======", .b = 1 },
        .{ .u = "m", .fmt = "{d:^10}",  .s = "  102 km  ", .b = 102400 },
    }) |tc| {
        const slice = try std.fmt.bufPrint(&buf, tc.fmt, .{ fmtSI(tc.b, tc.u) });
        try std.testing.expectEqualStrings(tc.s, slice);
    }

    inline for (.{
        .{ .u = "m", .fmt = "{d}", .s = "0 m", .b = 0 },
        .{ .u = "m", .fmt = "{d}", .s = "1 m", .b = 1 },
        .{ .u = "m", .fmt = "{d}", .s = "999 m", .b = 999 },
        .{ .u = "m", .fmt = "{d}", .s = "1 km", .b = 1000 },
        .{ .u = "m", .fmt = "{d}", .s = "1.423 km", .b = 1423 },
        .{ .u = "m", .fmt = "{d}", .s = "1.999 km", .b = 1999 },
        .{ .u = "m", .fmt = "{d:.3}", .s = "1.023 km", .b = 1023 },
        .{ .u = "m", .fmt = "{d:.3}", .s = "1.023 Mm", .b = 1023456 },
        .{ .u = "m", .fmt = "{d:=>10}", .s = "=======0 m", .b = 0 },
        .{ .u = "m", .fmt = "{d:=<10}", .s = "1 m=======", .b = 1 },
        .{ .u = "m", .fmt = "{d:^10}",  .s = " 102.4 km ", .b = 102400 },
    }) |tc| {
        const slice = try std.fmt.bufPrint(&buf, tc.fmt, .{ fmtSI(@as(f64, tc.b), tc.u) });
        try std.testing.expectEqualStrings(tc.s, slice);
    }
}

const std = @import("std");
