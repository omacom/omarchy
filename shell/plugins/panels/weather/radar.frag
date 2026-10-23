#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
  mat4 qt_Matrix;
  float qt_Opacity;
  float tileSize;
  vec2 tileOffset;
};
layout(binding = 1) uniform sampler2D source;
layout(binding = 2) uniform sampler2D n0bPalette;

// IEM's N0B curve is stored as RGB above and dBZ + 32 as R + G/255 below.
// The curve repeats white at 60 and 94.5 dBZ; the palette keeps the lower interval.
float reflectivity(vec3 color) {
  color *= 255.0;
  float nearest = 1e9;
  float entry = 0.0;
  for (int i = 0; i < 239; i++) {
    float x = (float(i) + 0.5) / 239.0;
    vec3 delta = color - texture(n0bPalette, vec2(x, 0.25)).rgb * 255.0;
    float distance = dot(delta, delta);
    if (distance < nearest) {
      nearest = distance;
      entry = x;
    }
    if (distance < 0.01) break;
  }
  if (nearest > 0.01) return -32.0;
  return dot(texture(n0bPalette, vec2(entry, 0.75)).rg, vec2(255.0, 1.0)) - 32.0;
}

vec3 ramp(float dbz) {
  vec3 color = mix(vec3(42, 156, 140), vec3(52, 182, 152), clamp((dbz - 20.0) / 10.0, 0.0, 1.0));
  color = mix(color, vec3(70, 190, 138), clamp((dbz - 30.0) / 6.0, 0.0, 1.0));
  color = mix(color, vec3(176, 214, 86), clamp((dbz - 36.0) / 3.0, 0.0, 1.0));
  color = mix(color, vec3(244, 206, 74), clamp((dbz - 39.0) / 4.0, 0.0, 1.0));
  color = mix(color, vec3(246, 148, 58), clamp((dbz - 43.0) / 7.0, 0.0, 1.0));
  return color / 255.0;
}

void main() {
  const vec2 pitch = vec2(2.36, 2.55);
  vec2 grid = (qt_TexCoord0 * (tileSize + 4.0) + tileOffset - 2.0) / pitch;
  vec2 cell = floor(grid);
  float edge = 0.5 * fwidth(grid.x * pitch.x) / pitch.x;
  vec2 samplePoint = (cell + 0.5) * pitch - tileOffset;
  if (any(lessThan(samplePoint, vec2(0.0))) || any(greaterThanEqual(samplePoint, vec2(tileSize)))) {
    fragColor = vec4(0.0);
    return;
  }
  vec4 pixel = texture(source, samplePoint / tileSize);
  if (pixel.a < 0.01) {
    fragColor = vec4(0.0);
    return;
  }
  float dbz = reflectivity(pixel.rgb / pixel.a);
  float noise = fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453);
  if (dbz < 20.0 || noise > mix(0.12, 1.0, smoothstep(20.0, 36.0, dbz))) {
    fragColor = vec4(0.0);
    return;
  }
  vec2 offset = (fract(grid) - 0.5) * pitch;
  float distance = length(offset) / pitch.x;
  float radius = mix(0.16, 0.54, smoothstep(26.0, 46.0, dbz));
  float dotShape = 1.0 - smoothstep(radius - edge, radius + edge, distance);
  fragColor = vec4(ramp(dbz) * dotShape, dotShape) * qt_Opacity;
}
