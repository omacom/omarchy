-- Remove borders and dim inactive windows without changing gaps or corners.
hl.config({
  general = {
    border_size = 0,
  },

  decoration = {
    dim_inactive = true,
    dim_strength = 0.20,
  },
})
