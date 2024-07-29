const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;
const Ray = @import("ray.zig").Ray;
const writeColor = @import("color.zig").writeColor;

fn hitSphere(center: Vec3, radius: f32, r: Ray) bool {
    const oc = Vec3.subtract(r.origin, center);
    const a = Vec3.dot(r.direction, r.direction);
    const b = 2.0 * Vec3.dot(oc, r.direction);
    const c = Vec3.dot(oc, oc) - radius * radius;
    const discriminant = b * b - 4 * a * c;
    return discriminant >= 0;
}

fn rayColor(r: Ray) Vec3 {
    if (hitSphere(Vec3.init(0, 0, -1), 0.5, r)) return Vec3.init(1, 0, 0);
    const unit_direction = r.direction.unitVector();
    const a = 0.5 * (unit_direction.y + 1.0);
    return Vec3.add(Vec3.multiplyScalar(Vec3.init(1.0, 1.0, 1.0), 1.0 - a), Vec3.multiplyScalar(Vec3.init(0.5, 0.7, 1.0), a));
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const aspect_ratio: f32 = 16.0 / 9.0;

    const image_width: usize = 400;

    // Calculate the image height, and ensure that it's at least 1.
    var image_height: usize = image_width / @as(usize, @intFromFloat(aspect_ratio));
    image_height = if (image_height < 1) 1 else image_height;

    // Camera

    const focal_length: f32 = 1;
    const viewport_height: f32 = 2;
    const viewport_width: f32 = viewport_height * (@as(f32, @floatFromInt(image_width)) / @as(f32, @floatFromInt(image_height)));
    const camera_center = Vec3.init(0, 0, 0);

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    const viewport_u = Vec3.init(viewport_width, 0, 0);
    const viewport_v = Vec3.init(0, -viewport_height, 0);

    // Calculate the horizontal and vertical delta vectors from pixel to pixel.
    const pixel_delta_u = Vec3.divideScalar(viewport_u, @floatFromInt(image_width));
    const pixel_delta_v = Vec3.divideScalar(viewport_v, @floatFromInt(image_height));

    // Calculate the location of the upper left pixel.
    const half_viewport_u = Vec3.divideScalar(viewport_u, 2);
    const half_viewport_v = Vec3.divideScalar(viewport_v, 2);

    const viewport_upper_left = Vec3.subtract(Vec3.subtract(Vec3.subtract(camera_center, Vec3.init(0, 0, focal_length)), half_viewport_u), half_viewport_v);
    const pixel00_loc = Vec3.add(viewport_upper_left, Vec3.multiplyScalar(Vec3.add(pixel_delta_u, pixel_delta_v), 0.5));

    try stdout.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    for (0..image_height) |j| {
        std.log.info("Scanlines remaining: {d}", .{image_height - j});
        for (0..image_width) |i| {
            const fi: f32 = @floatFromInt(i);
            const fj: f32 = @floatFromInt(j);

            const pixel_center = Vec3.add(pixel00_loc, Vec3.add(Vec3.multiplyScalar(pixel_delta_u, fi), Vec3.multiplyScalar(pixel_delta_v, fj)));
            const ray_direction = Vec3.subtract(pixel_center, camera_center);
            const r = Ray.init(camera_center, ray_direction);
            var pixel_color = rayColor(r);
            try writeColor(&stdout, &pixel_color);
        }
    }

    std.log.info("Done.", .{});
}
