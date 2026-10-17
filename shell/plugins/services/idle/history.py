"""Random non-repeating visit history, including forward replay after going back."""

import secrets


class History:
  def __init__(self, count, start=None, order=None, excluded=None):
    if excluded is not None and (not isinstance(excluded, int) or not 0 <= excluded < count):
      raise ValueError('Invalid excluded playlist item')
    if start is None:
      if order is not None:
        start = order[0] if order else -1
      else:
        candidates = [item for item in range(count) if item != excluded]
        start = candidates[secrets.randbelow(len(candidates))] if candidates else 0
    if count < 1 or not 0 <= start < count:
      raise ValueError('Invalid playlist')
    if order is None:
      remaining = [item for item in range(count) if item != start]
      secrets.SystemRandom().shuffle(remaining)
      order = [start, *remaining]
    if sorted(order) != list(range(count)) or order[0] != start:
      raise ValueError('Invalid playlist order')
    self.count = count
    self.order = order
    self.items = [start]
    self.cursor = 0

  @property
  def current(self):
    return self.items[self.cursor]

  def navigate(self, direction):
    if direction == 'previous':
      if self.cursor == 0:
        return False
      self.cursor -= 1
    elif direction == 'next':
      if self.cursor + 1 == len(self.items):
        self.items.append(self.order[len(self.items) % self.count])
      self.cursor += 1
    else:
      raise ValueError('Invalid navigation')
    return True
