#include "../../../default/hypr/float-snap/geometry.hpp"
#include <cassert>
#include <cmath>

using FloatSnap::Box;
static Box apply(Box raw, Box start, Box area = {0, 0, 1536, 960}, bool move = false,
                 double minWidth = 20, double minHeight = 20, double maxWidth = 1e9, double maxHeight = 1e9) {
  return FloatSnap::snap(raw, start, area, move, minWidth, minHeight, maxWidth, maxHeight);
}
int main() {
  const Box start{101, 117, 501, 303};
  auto right = apply({101,117,520,303}, start);
  assert(right.x == 101 && right.y == 117 && right.x + right.width == 608 && right.height == 303);
  auto left = apply({78,117,524,303}, start);
  assert(left.x == 64 && left.x + left.width == 602 && left.y == 117 && left.height == 303);
  auto top = apply({101,94,501,326}, start);
  assert(top.y == 96 && top.y + top.height == 420 && top.x == 101 && top.width == 501);
  auto bottom = apply({101,117,501,324}, start);
  assert(bottom.y == 117 && bottom.y + bottom.height == 448 && bottom.width == 501);
  auto corner = apply({78,94,524,326}, start);
  assert(corner.x == 64 && corner.y == 96 && corner.x + corner.width == 602 && corner.y + corner.height == 420);
  auto limited = apply({590,410,12,10}, start, {0,0,1536,960}, false,100,80);
  assert(limited.width == 100 && limited.height == 80 && limited.x + limited.width == 602 && limited.y + limited.height == 420);
  auto maximum = apply({101,117,800,700}, start, {0,0,1536,960}, false,20,20,550,350);
  assert(maximum.width == 550 && maximum.height == 350);
  auto offset = apply({-921,147,510,303}, {-921,147,501,303}, {-1024,35,1024,800});
  assert(offset.x + offset.width == -416 && offset.y == 147);
  auto unchanged = apply(start, start);
  assert(unchanged.x == start.x && unchanged.y == start.y && unchanged.width == start.width && unchanged.height == start.height);
  auto moving = apply({126,143,501,303}, start, {0,0,1536,960}, true);
  assert(moving.width == 501 && moving.height == 303);
  assert(moving.x == 128 && moving.y + moving.height == 448);
  assert(FloatSnap::line(999,0,1000) == 992);
  assert(FloatSnap::line(1005,0,1000) == 992);
  assert(FloatSnap::line(1020,0,1000) == 1000);
  // Drag updates always use raw pointer geometry: sub-cell motion accumulates,
  // and crossing a boundary backwards returns to the same line without drift.
  double prior = 0;
  for (int delta = 1; delta < 200; ++delta) {
    auto box = apply({101,117,501.0+delta,303}, start);
    assert(box.x + box.width >= prior);
    prior = box.x + box.width;
  }
  assert(apply({101,117,520,303}, start).width == right.width);
}
