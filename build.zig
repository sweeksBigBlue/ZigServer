const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "client",
        .root_source_file = b.path("src/client.zig"),
        .target = b.host,
    });

    b.installArtifact(exe);

    const runExe = b.addRunArtifact(exe);

    // Add command line arguments that we need
    if (b.args) |args| {
        runExe.addArgs(args);
    }

    const runStep = b.step("run", "Run the application");
    runStep.dependOn(&runExe.step);
}
