const Vec3 = @import("vec3.zig").Vec3;

pub fn writeColor(writer: anytype, color: *Vec3) !void {
    const r = color.x;
    const g = color.y;
    const b = color.z;

    const r_byte: i32 = @intFromFloat(255.999 * r);
    const g_byte: i32 = @intFromFloat(255.999 * g);
    const b_byte: i32 = @intFromFloat(255.999 * b);

    try writer.*.print("{d} {d} {d}\n", .{ @abs(r_byte), @abs(g_byte), @abs(b_byte) });
}
