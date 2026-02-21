pub fn build(b: *std.Build) void {
    const fmt = b.addModule("fmt", .{
        .root_source_file = b.path("fmt.zig"),
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });

    const tests = b.addTest(.{
        .root_module = fmt,
    });
    const run_tests = b.addRunArtifact(tests);

    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_tests.step);
}

const std = @import("std");