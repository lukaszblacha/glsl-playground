precision mediump float;

uniform float uTime;
uniform vec2 uRes;
uniform vec2 uMouse;

varying vec2 vPos;

#define MAX_ITERATIONS 80
#define MAX_DISTANCE 100.0
#define SURFACE_DISTANCE 0.01
#define PI 3.1415926538

float min3(in float a, in float b, in float c) {
  return min(a, min(b, c));
}

float min4(in float a, in float b, in float c, in float d) {
  return min3(a, b, min(c, d));
}

float max3(in float a, in float b, in float c) {
  return max(a, max(b, c));
}

float max4(in float a, in float b, in float c, in float d) {
  return max3(a, b, max(c, d));
}

float opSubtraction(in float a, in float b) {
  return max(a, -b);
}

float opIntersection(in float a, in float b) {
  return max(a, b);
}

float smin(in float a, in float b, in float k) {
  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
  return mix(b, a, h) - k * h * (1.0 - h);
}

float opSmoothSubtraction(in float a, in float b, in float k) {
  float h = clamp(0.5 - 0.5 * (b + a) / k, 0.0, 1.0);
  return mix(b, -a, h) - k * h * (1.0 - h);
}

float opSmoothIntersection(in float a, in float b, in float k) {
  float h = clamp(0.5 - 0.5 * (b - a) / k, 0.0, 1.0);
  return mix(b, a, h) - k * h * (1.0 - h);
}

vec3 scaleBox (in vec3 size, in vec3 coeff) {
  return size * coeff;
}

vec3 mirror_x(in vec3 position) {
    return vec3(abs(position.x), position.yz);
}
vec3 mirror_y(in vec3 position) {
    return vec3(position.x, abs(position.y), position.z);
}
vec3 mirror_z(in vec3 position) {
    return vec3(position.xy, abs(position.z));
}

mat2 rot2d(in float angle) {
  float s = sin(angle);
  float c = cos(angle);
  return mat2(c, -s, s, c);
}

vec3 mov_x(in vec3 point, in float dist) {
  return vec3(point.x + dist, point.yz);
}

vec3 mov_y(in vec3 point, in float dist) {
  return vec3(point.x, point.y + dist, point.z);
}

vec3 mov_z(in vec3 point, in float dist) {
  return vec3(point.xy, point.z + dist);
}

vec3 mov(in vec3 point, in vec3 dist) {
  return point + dist;
}

vec3 rot_xy(in vec3 p, in float angle) {
  vec3 p2 = p;
  p2.xy *= rot2d(angle);
  return p2;
}

vec3 rot_xz(in vec3 p, in float angle) {
  vec3 p2 = p;
  p2.xz *= rot2d(angle);
  return p2;
}

vec3 rot_yz(in vec3 p, in float angle) {
  vec3 p2 = p;
  p2.yz *= rot2d(angle);
  return p2;
}

// Rodrigues' rotation formula
vec3 rot(in vec3 p, in vec3 axis, in float angle) {
  return cross(axis, p) * sin(angle) +
    mix(
      dot(axis, p) * axis,
      p,
      cos(angle)
    );
}

// @see https://www.shadertoy.com/view/Xds3zN
float sd_sphere (in vec3 position, in float size) {
  return length(position) - size;
}

// @see https://www.youtube.com/watch?v=62-pRVZuS5c
float sd_box(in vec3 position, in vec3 size) {
  vec3 q = abs(position) - size;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float render_cabin(in vec3 p) {
  vec3 point = mirror_x(p);

  return opSubtraction(
    sd_box(
      point - vec3(0.1, 0, 0),
      vec3(0.1, 0.2, 0.6)
    ),
    min(
      sd_box(
        rot_xy(rot_xz(point - vec3(0.25, 0, -0.2), PI / 12.0), PI / 30.0),
        vec3(0.1, 0.3, 0.6)
      ),
      sd_box(
        rot_yz(point - vec3(0.1, 0.3, -0.2), PI / 12.0),
        vec3(0.2, 0.1, 0.6) // size
      )
    )
  );
}

float distane_to_scene(in vec3 point) {
  float cabin = render_cabin(point);
  float ground = point.y + 3.1;

  return min(
    ground,
    cabin
  );
}

vec3 normal_vector(in vec3 point)
{ 
    float distance = distane_to_scene(point);
    vec2 e = vec2(SURFACE_DISTANCE, 0); // Epsilon
    vec3 n = distance - vec3(
      distane_to_scene(point - e.xyy),  
      distane_to_scene(point - e.yxy),
      distane_to_scene(point - e.yyx)
    );
   
    return normalize(n);
}

// @see https://www.shadertoy.com/view/NlfGDs
vec3 light_diffuse(in vec3 light_pos, in vec3 light_color, in vec3 point) { 
    vec3 light_direction = normalize(light_pos - point);
   // Diffuse light
    float dif = dot(normal_vector(point), light_direction);

    return clamp(dif * light_color, 0.0, 1.0);
}

vec3 scene_light(vec3 position) {
  vec3 light1 = vec3(rot_xz(vec3(9, 2, 0), uTime / 2.));
  vec3 light1_color = vec3(1, 0.7, 0.5);
  vec3 light2 = vec3(rot_xz(vec3(-9, -2, 0), uTime / 2.));
  vec3 light2_color = vec3(0.5, 0.4, 0.4);
  vec3 light3 = vec3(-3, 10, 0);
  vec3 light3_color = vec3(0.2);

  vec3 color = 
    light_diffuse(light1, light1_color, position) + 
    light_diffuse(light2, light2_color, position) + 
    light_diffuse(light3, light3_color, position);

  return clamp(color, 0.0, 1.0);
}

vec4 ray_march(in vec3 origin, in vec3 direction) {
    // total distance travelled
    float travel_distance = 0.0;
    vec3 position = origin;

    for (int i = 0; i < MAX_ITERATIONS; i++) {
        // position along the ray
        position = origin + direction * travel_distance;
        float scene_distance = distane_to_scene(position);
        travel_distance += scene_distance;
        if (scene_distance < SURFACE_DISTANCE || travel_distance > MAX_DISTANCE) {
          break;
        }
    }

    return vec4(position, travel_distance);
}

void main() {
  vec2 uv = vPos * 2.0 - 1.0;

  // Move the camera
  vec2 mouse_angle = vec2(-uMouse.x * 2.0, -uMouse.y * 2.0);

  // Initialization
  vec3 ray_origin = vec3(0, 0, -3);
  // Vector length is normalized to be of length 1
  vec3 ray_direction = normalize(vec3(uv, 1));
  ray_origin.xz *= rot2d(mouse_angle.x);
  ray_direction.xz *= rot2d(mouse_angle.x);
  ray_origin.yz *= rot2d(mouse_angle.y);
  ray_direction.yz *= rot2d(mouse_angle.y);

  vec4 ray = ray_march(ray_origin, ray_direction);

  vec3 color = scene_light(ray.xyz);
  gl_FragColor = vec4(color, 1.0);
}
