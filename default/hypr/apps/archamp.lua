-- Float archamp: its window is the skin's own shape and size, so a tile slot
-- stretches a transparent window over the desktop. No `size` here — archamp
-- resizes itself when the skin or scale changes, and a fixed one clips the
-- equalizer and playlist.
o.window("archamp", { float = true })
