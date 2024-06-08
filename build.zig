pub fn build(b: *std.Build) void {
    _ = b.addModule("fmt", .{
        .root_source_file = b.path("fmt.zig"),
    });

    const tests = b.addTest(.{
        .root_source_file = b.path("fmt.zig"),
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });
    const run_tests = b.addRunArtifact(tests);

    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_tests.step);
}

const std = @import("std");