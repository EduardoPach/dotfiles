-- Colorscheme setup.
--
-- Tokyo Night is the default and ships with LazyVim. The others are installed
-- too, so you can try them live at any time with, e.g.:
--   :colorscheme catppuccin-mocha
--   :colorscheme kanagawa-wave
--   :colorscheme gruvbox
-- To make one of them your default, change the `colorscheme` value at the bottom.
return {
  -- Tokyo Night: configure the "moon" variant (deep navy, soft purple/cyan).
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "moon", -- options: "storm" | "moon" | "night" | "day"
      transparent = false,
    },
  },

  -- Extra themes available to switch to on the fly.
  { "catppuccin/nvim", name = "catppuccin", lazy = true },
  { "rebelot/kanagawa.nvim", lazy = true },
  { "ellisonleao/gruvbox.nvim", lazy = true },

  -- Tell LazyVim which colorscheme to load on startup.
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-moon",
    },
  },
}
