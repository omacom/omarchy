local active_border_color = "rgba(FFA68Fff)"
local inactive_border_color = "rgba(4E4264aa)"

hl.config({
  general = {
    border_size = 3,
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },
  decoration = {
    rounding = 10,
  },
  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },
})
