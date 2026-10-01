-- Draw nothing just for show, for machines that render on the CPU, like a VM:
-- no animations, blur or shadows, and opaque windows, so nothing behind a
-- window has to be blended into it.
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

o.window(".*", { opacity = "1 1" })
