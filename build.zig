const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const enable = b.option(bool, "enable", "enable zpix") orelse false;
    const options = .{
        .enable = enable,
        .path = b.option([]const u8, "path", "installed pix path") orelse if (enable) @panic("PIX path is required when enabled") else "",
    };

    const options_step = b.addOptions();
    const options_struct_info = @typeInfo(@TypeOf(options)).@"struct";
    inline for (options_struct_info.field_names, options_struct_info.field_types) |field_name, FieldType| {
        options_step.addOption(FieldType, field_name, @field(options, field_name));
    }

    const options_module = options_step.createModule();

    const module = b.addModule("root", .{
        .root_source_file = b.path("src/zpix.zig"),
        .imports = &.{
            .{ .name = "zpix_options", .module = options_module },
        },
        .target = target,
        .optimize = optimize,
    });

    // Minimal contained compile check
    b.step("check", "Check that zpix module compiles").dependOn(&b.addObject(.{
        .name = "zpix_check",
        .root_module = module,
    }).step);
}
