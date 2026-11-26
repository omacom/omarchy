-- Draw nothing just for show, for machines that render on the CPU, like a VM:
-- no animations, blur or shadows. How see-through windows are is left to
-- Appearance > Windows > Window Opacity.
hl.config({
  animations = {
    enabled = false,
  },

  decoration = {
    blur = {
      enabled = false,
    },

    shadow = {
      enabled = false,
    },
  },
})
