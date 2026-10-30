return {
  {
    "neanias/everforest-nvim",
    config = function()
      require("everforest").setup({
        transparent_background_level = 2,
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "everforest",
      background = "soft",
    },
  },
}
