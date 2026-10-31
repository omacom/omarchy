#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
  mat4 qt_Matrix;
  float qt_Opacity;
  vec4 backgroundColor;
  vec4 foregroundColor;
};
layout(binding = 1) uniform sampler2D source;

float luminance(vec2 point) {
  return dot(texture(source, clamp(point, vec2(0.0), vec2(1.0))).rgb, vec3(0.2126, 0.7152, 0.0722));
}

float water(float value) {
  return 1.0 - smoothstep(0.008, 0.035, abs(value - 200.0 / 255.0));
}

void main() {
  float value = luminance(qt_TexCoord0);
  float mean = value * 4.0;
  float sea = water(value) * 4.0;
  float nearbySea = 0.0;
  for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
      if (x == 0 && y == 0) continue;
      vec2 offset = vec2(x, y) / 512.0;
      float weight = x == 0 || y == 0 ? 2.0 : 1.0;
      float sampleValue = luminance(qt_TexCoord0 + offset);
      mean += sampleValue * weight;
      sea += water(sampleValue) * weight;
      nearbySea += water(luminance(qt_TexCoord0 + offset * 6.0));
    }
  }
  mean /= 16.0;
  sea /= 16.0;
  // Broad water support excludes road antialiasing from the coastal outline.
  float shore = smoothstep(0.06, 0.25, sea) * (1.0 - smoothstep(0.70, 0.97, sea)) * smoothstep(2.0, 3.5, nearbySea);
  float road = 0.60 * (1.0 - smoothstep(0.22, 0.45, mean));
  vec3 terrain = mix(backgroundColor.rgb, foregroundColor.rgb, 0.02 * smoothstep(0.83, 0.98, mean));
  vec3 color = mix(terrain, foregroundColor.rgb, max(road * 0.40, shore * 0.32));
  fragColor = vec4(color, 1.0) * qt_Opacity;
}
