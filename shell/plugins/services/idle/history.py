"""Actual visit history, including forward replay after going back."""


class History:
  def __init__(self, count, start=0):
    if count < 1 or not 0 <= start < count:
      raise ValueError('Invalid playlist')
    self.count = count
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
        self.items.append((self.current + 1) % self.count)
      self.cursor += 1
    else:
      raise ValueError('Invalid navigation')
    return True
