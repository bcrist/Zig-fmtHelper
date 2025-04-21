// Time (seconds)
// N.B these are mainly useful for small durations; consider using std.fmt.fmtDuration for longer periods
pub inline fn s(val: anytype) Formatter(@TypeOf(val), "s", .none) { return value(val, "s"); }
pub inline fn ms(val: anytype) Formatter(@TypeOf(val), "s", .milli) { return value_scaled(val, .milli, "s"); }
pub inline fn us(val: anytype) Formatter(@TypeOf(val), "s", .micro) { return value_scaled(val, .micro, "s"); }
pub inline fn ns(val: anytype) Formatter(@TypeOf(val), "s", .nano) { return value_scaled(val, .nano, "s"); }

// Mass/weight (grams)
pub inline fn g(val: anytype) Formatter(@TypeOf(val), "g", .none) { return value(val, "g"); }
pub inline fn mg(val: anytype) Formatter(@TypeOf(val), "g", .milli) { return value_scaled(val, .milli, "g"); }
pub inline fn kg(val: anytype) Formatter(@TypeOf(val), "g", .kilo) { return value_scaled(val, .kilo, "g"); }

// Spatial dimension/distance (meters)
pub inline fn m(val: anytype) Formatter(@TypeOf(val), "m") { return value(val, "m"); }
pub inline fn cm(val: anytype) Formatter(@TypeOf(val), "m", .centi) { return value_scaled(val, .centi, "m"); }
pub inline fn mm(val: anytype) Formatter(@TypeOf(val), "m", .milli) { return value_scaled(val, .milli, "m"); }
pub inline fn um(val: anytype) Formatter(@TypeOf(val), "m", .micro) { return value_scaled(val, .micro, "m"); }
pub inline fn nm(val: anytype) Formatter(@TypeOf(val), "m", .nano) { return value_scaled(val, .nano, "m"); }
pub inline fn km(val: anytype) Formatter(@TypeOf(val), "m", .kilo) { return value_scaled(val, .kilo, "m"); }

// Volume (Liters)
pub inline fn l(val: anytype) Formatter(@TypeOf(val), "L", .none) { return value(val, "L"); }
pub inline fn ml(val: anytype) Formatter(@TypeOf(val), "L", .milli) { return value_scaled(val, .milli, "L"); }
pub inline fn ul(val: anytype) Formatter(@TypeOf(val), "L", .micro) { return value_scaled(val, .micro, "L"); }

// Temperature (Kelvin)
pub inline fn k(val: anytype) Formatter(@TypeOf(val), "K", .none) { return value(val, "K"); }
pub inline fn mk(val: anytype) Formatter(@TypeOf(val), "K", .milli) { return value_scaled(val, .milli, "K"); }

// Angle (radians)
pub inline fn rad(val: anytype) Formatter(@TypeOf(val), "rad", .none) { return value(val, "rad"); }

// Frequency (Hertz)
pub inline fn hz(val: anytype) Formatter(@TypeOf(val), "Hz", .none) { return value(val, "Hz"); }
pub inline fn khz(val: anytype) Formatter(@TypeOf(val), "Hz", .kilo) { return value_scaled(val, .kilo, "Hz"); }
pub inline fn mhz(val: anytype) Formatter(@TypeOf(val), "Hz", .mega) { return value_scaled(val, .mega, "Hz"); }
pub inline fn ghz(val: anytype) Formatter(@TypeOf(val), "Hz", .giga) { return value_scaled(val, .giga, "Hz"); }

// Voltage (Volts)
pub inline fn v(val: anytype) Formatter(@TypeOf(val), "V", .none) { return value(val, "V"); }
pub inline fn mv(val: anytype) Formatter(@TypeOf(val), "V", .milli) { return value_scaled(val, .milli, "V"); }
pub inline fn uv(val: anytype) Formatter(@TypeOf(val), "V", .micro) { return value_scaled(val, .micro, "V"); }

// Current (Amps)
pub inline fn a(val: anytype) Formatter(@TypeOf(val), "A", .none) { return value(val, "A"); }
pub inline fn ma(val: anytype) Formatter(@TypeOf(val), "A", .milli) { return value_scaled(val, .milli, "A"); }
pub inline fn ua(val: anytype) Formatter(@TypeOf(val), "A", .micro) { return value_scaled(val, .micro, "A"); }

// Power (Watts)
pub inline fn w(val: anytype) Formatter(@TypeOf(val), "W", .none) { return value(val, "W"); }
pub inline fn kw(val: anytype) Formatter(@TypeOf(val), "W", .kilo) { return value_scaled(val, .kilo, "W"); }

// Energy (Joules)
pub inline fn j(val: anytype) Formatter(@TypeOf(val), "J", .none) { return value(val, "J"); }
pub inline fn kj(val: anytype) Formatter(@TypeOf(val), "J", .kilo) { return value_scaled(val, .kilo, "J"); }

// Resistance/impedance (Ohms)
pub inline fn ohms(val: anytype) Formatter(@TypeOf(val), "\u{3A9}", .none) { return value(val, "\u{3A9}"); }
pub inline fn kohms(val: anytype) Formatter(@TypeOf(val), "\u{3A9}", .kilo) { return value_scaled(val, .kilo, "\u{3A9}"); }
pub inline fn megaohms(val: anytype) Formatter(@TypeOf(val), "\u{3A9}", .mega) { return value_scaled(val, .mega, "\u{3A9}"); }

// Capacitance (Farads)
pub inline fn f(val: anytype) Formatter(@TypeOf(val), "F", .none) { return value(val, "F"); }
pub inline fn uf(val: anytype) Formatter(@TypeOf(val), "F", .micro) { return value_scaled(val, .micro, "F"); }
pub inline fn nf(val: anytype) Formatter(@TypeOf(val), "F", .nano) { return value_scaled(val, .nano, "F"); }
pub inline fn pf(val: anytype) Formatter(@TypeOf(val), "F", .pico) { return value_scaled(val, .pico, "F"); }

// Inductance (Henries)
pub inline fn h(val: anytype) Formatter(@TypeOf(val), "H", .none) { return value(val, "H"); }
pub inline fn mh(val: anytype) Formatter(@TypeOf(val), "H", .milli) { return value_scaled(val, .milli, "H"); }
pub inline fn uh(val: anytype) Formatter(@TypeOf(val), "H", .micro) { return value_scaled(val, .micro, "H"); }
pub inline fn nh(val: anytype) Formatter(@TypeOf(val), "H", .nano) { return value_scaled(val, .nano, "H"); }


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
    var val = @abs(data.value);
    var exponent: i16 = 0;
    while (exponent < max_exponent and val >= data.limit) {
        exponent += 1;
        val /= 1000;
    }
    const limit = data.limit / 1000;
    while (exponent > min_exponent and val < limit and val != 0) {
        exponent -= 1;
        val *= 1000;
    }

    if (data.value < 0) {
        val = -val;
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
        out = std.fmt.formatFloat(float_buf, val, .{ .mode = .scientific, .precision = options.precision }) catch |err| switch (err) {
            error.BufferTooSmall => "(float)",
        };
    } else if (comptime std.mem.eql(u8, fmt, "d")) {
        out = std.fmt.formatFloat(float_buf, val, .{ .mode = .decimal, .precision = options.precision }) catch |err| switch (err) {
            error.BufferTooSmall => "(float)",
        };
    } else if (comptime std.mem.eql(u8, fmt, "x")) {
        var buf_stream = std.io.fixedBufferStream(float_buf);
        std.fmt.formatFloatHexadecimal(val, options, buf_stream.writer()) catch |err| switch (err) {
            error.NoSpaceLeft => unreachable,
        };
        out = buf_stream.getWritten();
    } else {
        std.fmt.invalidFmtError(fmt, val);
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

            const min_exponent = -30;
            const max_exponent = 30;

            const precision = options.precision orelse 0;
            if (precision > 32) return error.InvalidPrecision;

            var precision_buf: [32]u8 = .{ '0' } ** 32;
            var precision_slice = precision_buf[0..precision];

            var exponent = si_options.exponent_offset;
            var val = @abs(data.value);
            if (val == 0) {
                exponent = 0;
            } else {
                switch (@mod(exponent, 3)) {
                    0 => {},
                    1 => {
                        exponent -= 1;
                        val *= 10;
                    },
                    2 => {
                        exponent -= 2;
                        val *= 100;
                    },
                    else => unreachable,
                }

                while (exponent > max_exponent) {
                    val *= 1000;
                    exponent -= 3;
                }
                while (exponent < min_exponent or (exponent < max_exponent and val >= si_options.limit)) {
                    for (0..3) |_| {
                        if (precision > 0) {
                            const remainder: u8 = @intCast(val % 10);
                            std.mem.copyBackwards(u8, precision_slice[1..], precision_slice[0 .. precision_slice.len - 1]);
                            precision_slice[0] = '0' + remainder;
                        }
                        val = @divTrunc(val, 10);
                    }
                    exponent += 3;
                }
            }

            const suffix: []const u8 = switch (exponent) {
                -30 => "q",
                -27 => "r",
                -24 => "y",
                -21 => "z",
                -18 => "a",
                -15 => "f",
                -12 => " p",
                -9 => " n",
                -6 => if (si_options.use_utf8) " \u{b5}" else " u",
                -3 => " m",
                0 => " ",
                3 => " k",
                6 => " M",
                9 => " G",
                12 => " T",
                15 => " P",
                18 => " E",
                21 => " Z",
                24 => " Y",
                27 => " R",
                30 => " Q",
                else => {
                    std.debug.panic("unsupported exponent: {}", .{ exponent });
                    unreachable;
                },
            };

            var buf: [@bitSizeOf(T) / 3 + 36 + si_options.unit.len]u8 = undefined;
            var buf_stream = std.io.fixedBufferStream(&buf);
            var buf_writer = buf_stream.writer();

            if (data.value < 0) {
                buf_writer.writeByte('-') catch unreachable;
            }

            std.fmt.formatInt(val, 10, .lower, .{}, buf_writer) catch unreachable;

            if (options.precision) |_| {
                buf_writer.writeByte('.') catch unreachable;
                buf_writer.writeAll(precision_slice) catch unreachable;
            }

            buf_writer.writeAll(suffix) catch unreachable;
            buf_writer.writeAll(si_options.unit) catch unreachable;

            return std.fmt.formatBuf(buf_stream.getWritten(), options, writer);
        }
    };
}

pub const Scaling = enum (i16) {
    quecto = -30,
    ronto = -27,
    yocto = -24,
    zepto = -21,
    atto = -18,
    femto = -15,
    pico = -12,
    nano = -9,
    micro = -6,
    milli = -3,
    centi = -2,
    deci = -1,
    none = 0,
    deka = 1,
    hecto = 2,
    kilo = 3,
    mega = 6,
    giga = 9,
    tera = 12,
    peta = 15,
    exa = 18,
    zetta = 21,
    yotta = 24,
    ronna = 27,
    quetta = 30,
};

fn Formatter(comptime T: type, comptime unit: []const u8, comptime scaling: Scaling) type {
    return switch (@typeInfo(T)) {
        .float, .comptime_float => std.fmt.Formatter(format_si_float),
        .int => Format_SI_Int(T, .{ .unit = unit, .exponent_offset = @intFromEnum(scaling) }).Formatter,
        .comptime_int => Format_SI_Int(i64, .{ .unit = unit, .exponent_offset = @intFromEnum(scaling) }).Formatter,
        else => @compileError("Expected float or int value"),
    };
}

pub fn value(val: anytype, comptime unit: []const u8) Formatter(@TypeOf(val), unit, .none) {
    switch (@typeInfo(@TypeOf(val))) {
        .float, .comptime_float => {
            const data = Format_SI_Float_Data{ .value = val, .unit = unit };
            return .{ .data = data };
        },
        .int => {
            const data = Format_SI_Int(@TypeOf(val), .{ .unit = unit, .exponent_offset = 0 }) { .value = val };
            return .{ .data = data };
        },
        .comptime_int => {
            const data = Format_SI_Int(i64, .{ .unit = unit, .exponent_offset = 0 }) { .value = @intCast(val) };
            return .{ .data = data };
        },
        else => @compileError("Expected float or int value"),
    }
}

pub fn value_scaled(val: anytype, comptime scaling: Scaling, comptime unit: []const u8) Formatter(@TypeOf(val), unit, scaling) {
    switch (@typeInfo(@TypeOf(val))) {
        .float, .comptime_float => {
            const data = Format_SI_Float_Data{ .value = val * comptime std.math.pow(f64, 10, @intFromEnum(scaling)), .unit = unit };
            return .{ .data = data };
        },
        .int => {
            const data = Format_SI_Int(@TypeOf(val), .{ .unit = unit, .exponent_offset = @intFromEnum(scaling) }) { .value = val };
            return .{ .data = data };
        },
        .comptime_int => {
            const data = Format_SI_Int(i64, .{ .unit = unit, .exponent_offset = @intFromEnum(scaling) }) { .value = @intCast(val) };
            return .{ .data = data };
        },
        else => @compileError("Expected float or int value"),
    }
}



test value {
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
        const slice = try std.fmt.bufPrint(&buf, tc.fmt, .{ value(tc.b, tc.u) });
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
        const slice = try std.fmt.bufPrint(&buf, tc.fmt, .{ value(@as(f64, tc.b), tc.u) });
        try std.testing.expectEqualStrings(tc.s, slice);
    }
}

test value_scaled {
    var buf: [24]u8 = undefined;
    inline for (.{
        .{ .u = "m", .e = .centi, .fmt = "{d}", .s = "0 m", .b = 0 },
        .{ .u = "m", .e = .centi, .fmt = "{d}", .s = "10 mm", .b = 1 },
        .{ .u = "m", .e = .centi, .fmt = "{d}", .s = "9 m", .b = 999 },
        .{ .u = "m", .e = .centi, .fmt = "{d}", .s = "10 m", .b = 1000 },
        .{ .u = "m", .e = .centi, .fmt = "{d}", .s = "14 m", .b = 1423 },
        .{ .u = "m", .e = .centi, .fmt = "{d}", .s = "19 m", .b = 1999 },
        .{ .u = "m", .e = .centi, .fmt = "{d:.3}", .s = "102.310 m", .b = 10231 },
        .{ .u = "m", .e = .centi, .fmt = "{d:.3}", .s = "102.345 km", .b = 10234567 },
        .{ .u = "m", .e = .centi, .fmt = "{d:=>10}", .s = "=======0 m", .b = 0 },
        .{ .u = "m", .e = .centi, .fmt = "{d:=<10.1}", .s = "10.0 mm===", .b = 1 },
        .{ .u = "m", .e = .centi, .fmt = "{d:^10}",  .s = "  102 km  ", .b = 10240000 },
    }) |tc| {
        const slice = try std.fmt.bufPrint(&buf, tc.fmt, .{ value_scaled(tc.b, tc.e, tc.u) });
        try std.testing.expectEqualStrings(tc.s, slice);
    }

    inline for (.{
        .{ .u = "m", .e = .deka, .fmt = "{d}", .s = "0 m", .b = 0 },
        .{ .u = "m", .e = .deka, .fmt = "{d}", .s = "10 m", .b = 1 },
        .{ .u = "m", .e = .deka, .fmt = "{d}", .s = "9.99 km", .b = 999 },
        .{ .u = "m", .e = .deka, .fmt = "{d}", .s = "10 km", .b = 1000 },
        .{ .u = "m", .e = .deka, .fmt = "{d}", .s = "14.23 km", .b = 1423 },
        .{ .u = "m", .e = .deka, .fmt = "{d}", .s = "19.99 km", .b = 1999 },
        .{ .u = "m", .e = .deka, .fmt = "{d:.3}", .s = "10.230 km", .b = 1023 },
        .{ .u = "m", .e = .deka, .fmt = "{d:.3}", .s = "10.235 Mm", .b = 1023456 },
        .{ .u = "m", .e = .deka, .fmt = "{d:=>10}", .s = "=======0 m", .b = 0 },
        .{ .u = "m", .e = .deka, .fmt = "{d:=<10}", .s = "10 m======", .b = 1 },
        .{ .u = "m", .e = .deka, .fmt = "{d:^10}",  .s = " 1.024 Mm ", .b = 102400 },
    }) |tc| {
        const slice = try std.fmt.bufPrint(&buf, tc.fmt, .{ value_scaled(@as(f64, tc.b), tc.e, tc.u) });
        try std.testing.expectEqualStrings(tc.s, slice);
    }
}

const std = @import("std");
