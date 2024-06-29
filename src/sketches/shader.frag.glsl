precision mediump float;

uniform float uTime;
uniform vec2 uRes;
uniform vec2 uMouse;

varying vec2 vPos;

#define MAX_ITERATIONS 80
#define MAX_DISTANCE 100.0
#define SURFACE_DISTANCE 0.01

float opUnion(float a, float b) {
  return min(a, b);
}

float opSubtraction(float a, float b) {
  return max(-a, b);
}

float opIntersection(float a, float b) {
  return max(a, b);
}

float opSmoothUnion(float a, float b, float k) {
  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
  return mix(b, a, h) - k * h * (1.0 - h);
}

float opSmoothSubtraction(float a, float b, float k) {
  float h = clamp(0.5 - 0.5 * (b + a) / k, 0.0, 1.0);
  return mix(b, -a, h) - k * h * (1.0 - h);
}

float opSmoothIntersection(float a, float b, float k) {
  float h = clamp(0.5 - 0.5 * (b - a) / k, 0.0, 1.0);
  return mix(b, a, h) - k * h * (1.0 - h);
}

vec3 scaleBox (vec3 size, vec3 coeff) {
  return size * coeff;
}

mat2 rot2d(float angle) {
  float s = sin(angle);
  float c = cos(angle);
  return mat2(c, -s, s, c);
}

vec3 rot_xy(vec3 p, float angle) {
  vec3 p2 = p;
  p2.xy *= rot2d(angle);
  return p2;
}

vec3 rot_xz(vec3 p, float angle) {
  vec3 p2 = p;
  p2.xz *= rot2d(angle);
  return p2;
}

vec3 rot_yz(vec3 p, float angle) {
  vec3 p2 = p;
  p2.yz *= rot2d(angle);
  return p2;
}

vec3 rot_3d(vec3 p, vec3 axis, float angle) {
  // Rodrigues' rotation formula
  return cross (axis, p) * sin(angle) +
    mix(
      dot(axis, p) * axis,
      p,
      cos(angle)
    );
}

// @see https://www.shadertoy.com/view/Xds3zN
float sd_sphere (vec3 position, float size) {
  return length(position) - size;
}

// @see https://www.youtube.com/watch?v=62-pRVZuS5c
float sd_box(vec3 position, vec3 size) {
  vec3 q = abs(position) - size;
  return length(max(q, 0.0)) + min(max(q.x,max(q.y, q.z)), 0.0);
}

vec3 palette(in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d) {
   return a + b * cos(6.28318 * (c * t + d));
}

float sdf_distance(vec3 point) {
  // sphere
  vec3 sphere_position = vec3(3. * sin(uTime), 0, 0);
  float sphere_radius = 0.4;
  float sphere = sd_sphere(point - sphere_position, sphere_radius);

  // box
  vec3 box_position = vec3(0, 0, 0);
  float box_size = 0.02;
  vec3 point2 = point;
  point2.y += uTime;
  point2 = fract(point2) - 0.5;
  point2 = rot_xz(point2, uTime * 3.0);
  float box = sd_box(point2 - box_position, vec3(box_size));

  // floor
  float ground_plane = point.y + 5.;

  return min(
    ground_plane,
    opSmoothUnion(
      box,
      sphere,
      1.
    )
  );
}

void main() {
  vec2 uv = vPos * 2.0 - 1.0;

    // Initialization
    vec3 ray_origin = vec3(0, 0, -3);
    // Vector length is normalized to be of length 1
    vec3 ray_direction = normalize(vec3(uv, 1));

    // Move the camera
    ray_origin.xz *= rot2d(-uMouse.x * 2.0);
    ray_direction.xz *= rot2d(-uMouse.x * 2.0);
    ray_origin.yz *= rot2d(-uMouse.y * 2.0);
    ray_direction.yz *= rot2d(-uMouse.y * 2.0);

    // total distance travelled
    float travel_distance = 0.0;
    // Raymarching
    for (int i = 0; i < MAX_ITERATIONS; i++) {
        // position along the ray
        vec3 ray_position = ray_origin + ray_direction * travel_distance;
        // current distance to the scene
        float scene_distance = sdf_distance(ray_position);
        // advance the ray
        travel_distance += scene_distance;
        // early stop if close to the scene or too far out
        if (scene_distance < SURFACE_DISTANCE || travel_distance > MAX_DISTANCE) break;
    }

  vec3 color = vec3((-travel_distance / 60.0) + 1.0);
  gl_FragColor = vec4(color, 1.0);
}
