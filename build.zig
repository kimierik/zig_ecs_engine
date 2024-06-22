const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libEngine = b.addStaticLibrary(.{
        .name = "propperEngine",
        .root_source_file = b.path("src/engine.zig"),
        .target = target,
        .optimize = optimize,
    });

    const enginemod = b.addModule("engine", .{
        .root_source_file = .{ .path = "src/engine.zig" },
    });
    _ = enginemod;

    b.installArtifact(libEngine);
}
