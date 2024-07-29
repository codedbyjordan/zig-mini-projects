const std = @import("std");

pub const Vec3 = struct {
    const Self = @This();

    x: f32,
    y: f32,
    z: f32,

    pub fn init(x: f32, y: f32, z: f32) Vec3 {
        return .{ .x = x, .y = y, .z = z };
    }

    pub fn zero() Vec3 {
        return .{ .x = 0, .y = 0, .z = 0 };
    }

    pub fn negative(self: Self) Vec3 {
        return .{
            .x = -self.x,
            .y = -self.y,
            .z = -self.z,
        };
    }

    pub fn addBy(self: *Self, val: f32) void {
        self.x += val;
        self.y += val;
        self.z += val;
    }

    pub fn multiplyBy(self: *Self, val: f32) void {
        self.x *= val;
        self.y *= val;
        self.z *= val;
    }

    pub fn divideBy(self: *Self, val: f32) void {
        self.x /= val;
        self.y /= val;
        self.z /= val;
    }

    pub fn length(self: Self) f32 {
        return @sqrt(self.lengthSquared());
    }

    pub fn lengthSquared(self: Self) f32 {
        return std.math.pow(f32, self.x, 2) + std.math.pow(f32, self.y, 2) + std.math.pow(f32, self.z, 2);
    }

    pub fn log(self: Self) void {
        std.log.info("{d}, {d}, {d}", .{ self.x, self.y, self.z });
    }

    pub fn add(a: Vec3, b: Vec3) Vec3 {
        return .{
            .x = a.x + b.x,
            .y = a.y + b.y,
            .z = a.z + b.z,
        };
    }

    pub fn subtract(a: Vec3, b: Vec3) Vec3 {
        return .{
            .x = a.x - b.x,
            .y = a.y - b.y,
            .z = a.z - b.z,
        };
    }

    pub fn multiply(a: Vec3, b: Vec3) Vec3 {
        return .{
            .x = a.x * b.x,
            .y = a.y * b.y,
            .z = a.z * b.z,
        };
    }

    pub fn addScalar(a: Vec3, val: f32) Vec3 {
        return .{
            .x = a.x + val,
            .y = a.y + val,
            .z = a.z + val,
        };
    }

    pub fn subtractScalar(a: Vec3, val: f32) Vec3 {
        return .{
            .x = a.x - val,
            .y = a.y - val,
            .z = a.z - val,
        };
    }

    pub fn multiplyScalar(a: Vec3, val: f32) Vec3 {
        return .{
            .x = a.x * val,
            .y = a.y * val,
            .z = a.z * val,
        };
    }

    pub fn divideScalar(a: Vec3, val: f32) Vec3 {
        return .{
            .x = a.x / val,
            .y = a.y / val,
            .z = a.z / val,
        };
    }

    pub fn dot(a: Vec3, b: Vec3) f32 {
        return a.x * b.x + a.y * b.y + a.z * b.z;
    }

    pub fn cross(a: Vec3, b: Vec3) Vec3 {
        return .{ .x = a.y * b.z - a.z * b.y, .y = a.z * b.x - a.x * b.z, .z = a.x * b.y - a.y * b.x };
    }

    pub fn unitVector(self: Self) Vec3 {
        const v_len = self.length();
        if (v_len == 0) {
            return self;
        }

        return .{
            .x = self.x / v_len,
            .y = self.y / v_len,
            .z = self.z / v_len,
        };
    }
};

// ============== TESTS START HERE ==============

test "Vec3" {
    var vec = Vec3.init(1, 2, 3);
    try std.testing.expectEqual(1, vec.x);

    vec.addBy(1);
    try std.testing.expectEqual(2, vec.x);
    try std.testing.expectEqual(9, vec.length());

    const math_vec = Vec3.init(1, 2, 3);

    try std.testing.expectEqualDeep(Vec3.add(math_vec, Vec3.init(1, 2, 3)), Vec3.init(2, 4, 6));
    try std.testing.expectEqualDeep(Vec3.subtract(math_vec, Vec3.init(1, 2, 3)), Vec3.init(0, 0, 0));
    try std.testing.expectEqualDeep(Vec3.multiply(math_vec, Vec3.init(1, 2, 3)), Vec3.init(1, 4, 9));
    try std.testing.expectEqual(14, Vec3.dot(Vec3.init(1, 2, 3), Vec3.init(1, 2, 3)));
    try std.testing.expectEqualDeep(Vec3.init(-3, 6, -3), Vec3.cross(Vec3.init(1, 2, 3), Vec3.init(4, 5, 6)));

    const unit_v = math_vec.unitVector();
    try std.testing.expectApproxEqAbs(unit_v.x, 0.2672612419124244, 1e-6);
    try std.testing.expectApproxEqAbs(unit_v.y, 0.5345224838248488, 1e-6);
    try std.testing.expectApproxEqAbs(unit_v.z, 0.8017837257372732, 1e-6);
}
