const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const imageWidth = 32;
    const imageHeight = 32;

    const fImageWidth: f32 = @floatFromInt(imageWidth);
    const fImageHeight: f32 = @floatFromInt(imageHeight);

    try stdout.print("P3\n{d} {d}\n255\n", .{ imageWidth, imageHeight });

    for (0..imageHeight) |j| {
        for (0..imageWidth) |i| {
            const fi: f32 = @floatFromInt(i);
            const fj: f32 = @floatFromInt(j);

            const r: f32 = fi / (fImageWidth - 1);
            const g: f32 = fj / (fImageHeight - 1);
            const b: f32 = 0;

            const ir: i32 = @intFromFloat(255.999 * r);
            const ig: i32 = @intFromFloat(255.999 * g);
            const ib: i32 = @intFromFloat(255.999 * b);

            try stdout.print("{d} {d} {d}\n", .{ @abs(ir), @abs(ig), @abs(ib) });
        }
    }
}
