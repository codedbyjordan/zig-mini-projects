// #include "vec3.h"

// class ray {
//   public:
//     ray() {}

//     ray(const point3& origin, const vec3& direction) : orig(origin), dir(direction) {}

//     const point3& origin() const  { return orig; }
//     const vec3& direction() const { return dir; }

//     point3 at(double t) const {
//         return orig + t*dir;
//     }

//   private:
//     point3 orig;
//     vec3 dir;
// };

// #endif

const Vec3 = @import("vec3.zig").Vec3;

pub const Ray = struct {
    const Self = @This();

    origin: Vec3,
    direction: Vec3,

    pub fn init(origin: Vec3, direction: Vec3) Ray {
        return .{ .origin = origin, .direction = direction };
    }

    pub fn at(self: Self, t: f32) Vec3 {
        return Vec3.add(self.origin, Vec3.multiplyScalar(self.direction, t));
    }
};
