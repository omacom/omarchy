#pragma once

#include <algorithm>
#include <cmath>

namespace FloatSnap {
struct Box {
  double x, y, width, height;
};

inline double line(double value, double origin, double extent) {
  constexpr double spacing = 32;
  return std::clamp(origin + std::round((value - origin) / spacing) * spacing, origin, origin + extent);
}

// The original rectangle identifies the dragged edges. The compositor supplies
// unrounded geometry from the drag's original pointer position on every event.
inline Box snap(Box raw, Box start, Box area, bool move,
                double minWidth, double minHeight, double maxWidth, double maxHeight) {
  if (move) {
    double left = line(raw.x, area.x, area.width) - raw.x;
    double right = line(raw.x + raw.width, area.x, area.width) - raw.x - raw.width;
    double top = line(raw.y, area.y, area.height) - raw.y;
    double bottom = line(raw.y + raw.height, area.y, area.height) - raw.y - raw.height;
    raw.x += std::abs(left) <= std::abs(right) ? left : right;
    raw.y += std::abs(top) <= std::abs(bottom) ? top : bottom;
    return raw;
  }
  bool left = std::abs(raw.x - start.x) > 0.5;
  bool top = std::abs(raw.y - start.y) > 0.5;
  bool right = std::abs(raw.x + raw.width - start.x - start.width) > 0.5;
  bool bottom = std::abs(raw.y + raw.height - start.y - start.height) > 0.5;
  if (left) {
    raw.width = std::clamp(start.x + start.width - line(raw.x, area.x, area.width), minWidth, maxWidth);
    raw.x = start.x + start.width - raw.width;
  } else if (right) {
    raw.width = std::clamp(line(raw.x + raw.width, area.x, area.width) - start.x, minWidth, maxWidth);
  }
  if (top) {
    raw.height = std::clamp(start.y + start.height - line(raw.y, area.y, area.height), minHeight, maxHeight);
    raw.y = start.y + start.height - raw.height;
  } else if (bottom) {
    raw.height = std::clamp(line(raw.y + raw.height, area.y, area.height) - start.y, minHeight, maxHeight);
  }
  return raw;
}
}
