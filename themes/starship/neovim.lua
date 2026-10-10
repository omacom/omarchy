return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      colors = {
        bg = "#1c1c1e",
        dark_bg = "#161618",
        darker_bg = "#0e0e10",
        lighter_bg = "#2c2c2e",

        fg = "#f5f5f7",
        dark_fg = "#98989d",
        light_fg = "#fbfbfd",
        bright_fg = "#ffffff",
        muted = "#8e8e93",

        red = "#ff5f4a",
        orange = "#ff6a3d",
        yellow = "#ffc27a",
        green = "#ff9f0a",
        cyan = "#a6dcef",
        blue = "#8fb8de",
        purple = "#ff8fa3",
        brown = "#b8a99a",

        bright_red = "#ff8373",
        bright_yellow = "#ffd8a8",
        bright_green = "#ffb340",
        bright_cyan = "#cdeefa",
        bright_blue = "#b5d0ea",
        bright_purple = "#ffb3c1",

        accent = "#ff9f0a",
        cursor = "#ffffff",
        foreground = "#f5f5f7",
        background = "#1c1c1e",
        selection = "#3a3a3c",
        selection_foreground = "#ffffff",
        selection_background = "#3a3a3c",
      },
      on_colors = function(c)
        c.cursorline_bg = c.lighter_bg
        c.terminal.black = c.bg
        c.terminal.black_bright = c.muted
        c.terminal.white = c.fg
        c.terminal.white_bright = c.bright_fg
      end,
      on_highlights = function(hl, c)
        for name, spec in pairs(hl) do
          if type(spec) == "table" and spec.bg == c.dark_bg
            and (name:match("^Noice") or name:match("^Pmenu") or name:match("^BlinkCmpMenu")
              or name:match("^WhichKey") or name:match("^TelescopePrompt")) then
            spec.bg = c.none
          end
        end
        hl.PmenuSel = { bg = c.selection, fg = c.bright_fg, bold = true }
        hl.PmenuMatchSel = { bg = c.selection, fg = c.bright_blue, bold = true }
        hl.MiniStatuslineFilename = { bg = c.lighter_bg, fg = c.dark_fg }
        hl.TroubleCount = { bg = c.lighter_bg, fg = c.bright_purple }
        hl["@punctuation.bracket"] = { fg = c.muted }
        hl["@punctuation.delimiter"] = { fg = c.muted }
      end,
    },
    config = function(_, opts)
      require("aether").setup(opts)
      vim.cmd.colorscheme("aether")
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}
