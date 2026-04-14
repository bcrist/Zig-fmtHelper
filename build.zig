pub fn build(b: *std.Build) void {
    const fmt = b.addModule("fmt", .{
        .root_source_file = b.path("fmt.zig"),
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });

    const tests = b.addTest(.{
        .root_module = fmt,
    });
    b.step("test", "Run all tests").dependOn(&b.addRunArtifact(tests).step);
}

const std = @import("std");