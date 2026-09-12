return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "latte",
      color_overrides = {
        latte = {
          base = "#eeebed",
          mantle = "#eceef3",
          crust = "#eff1f5",
          text = "#4c4f69",
          subtext1 = "#595c74",
          subtext0 = "#595c74",
          surface0 = "#e6e9ef",
          surface1 = "#e3e2ee",
          surface2 = "#ccd0da",
          overlay0 = "#595c74",
          overlay1 = "#595c74",
          overlay2 = "#595c74",
          rosewater = "#934939",
          flamingo = "#bb0f31",
          pink = "#9f3086",
          mauve = "#7d27e1",
          red = "#be0130",
          maroon = "#bb0f31",
          peach = "#a53d00",
          yellow = "#865200",
          green = "#1b6c01",
          teal = "#01686e",
          sky = "#026777",
          sapphire = "#026777",
          blue = "#0551df",
          lavender = "#014cd7",
        },
      },
      custom_highlights = function(colors)
        return {
          Cursor = { fg = colors.base, bg = "#454862" },
          TermCursor = { fg = colors.base, bg = "#454862" },
          Visual = { fg = colors.text, bg = colors.surface1 },
          WinSeparator = { fg = colors.surface2, bg = colors.base },
          FloatBorder = { fg = "#9ca0b0", bg = colors.base },
          Pmenu = { fg = colors.text, bg = colors.base },
          PmenuSel = { fg = colors.text, bg = colors.surface1 },
          CursorLine = { bg = colors.surface0 },
          Comment = { fg = colors.subtext1, style = { "italic" } },
        }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-latte",
    },
  },
}
