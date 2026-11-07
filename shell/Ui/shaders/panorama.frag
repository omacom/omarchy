#version 440

// Draws the part of a 360 panorama a camera looking along yaw and pitch
// would see. The source is an equirectangular image: longitude across, from
// -180 to 180 degrees, and latitude down, from 90 to -90.

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
  mat4 qt_Matrix;
  float qt_Opacity;
  float yaw;
  float pitch;
  float tanHalfFov;
  float aspect;
};

layout(binding = 1) uniform sampler2D source;

const float PI = 3.14159265358979;

void main() {
  vec2 ndc = qt_TexCoord0 * 2.0 - 1.0;
  vec3 dir = normalize(vec3(ndc.x * tanHalfFov, -ndc.y * tanHalfFov * aspect, 1.0));
  float cp = cos(pitch);
  float sp = sin(pitch);
  dir = vec3(dir.x, dir.y * cp + dir.z * sp, dir.z * cp - dir.y * sp);

  float u = (atan(dir.x, dir.z) + yaw) / (2.0 * PI) + 0.5;
  float v = 0.5 - asin(clamp(dir.y, -1.0, 1.0)) / PI;
  // The gradients come from the unwrapped longitude, so the seam where u
  // wraps from 1 to 0 does not pick the smallest mip level and draw a line.
  vec2 grad = vec2(u, v);
  vec2 dx = dFdx(grad);
  vec2 dy = dFdy(grad);
  float uf = fract(u);
  vec4 color = textureGrad(source, vec2(uf, v), dx, dy);
  // The texture clamps at its edges rather than repeating, so the half texel
  // either side of the seam blends the last column into the first by hand.
  float halfTexel = 0.5 / float(textureSize(source, 0).x);
  if (uf < halfTexel || uf > 1.0 - halfTexel) {
    float t = fract(uf + halfTexel) / (2.0 * halfTexel);
    vec4 last = textureGrad(source, vec2(1.0 - halfTexel, v), dx, dy);
    vec4 first = textureGrad(source, vec2(halfTexel, v), dx, dy);
    color = mix(last, first, t);
  }
  fragColor = color * qt_Opacity;
}
