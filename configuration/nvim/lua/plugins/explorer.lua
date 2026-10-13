-- File tree (Neo-tree), for getting oriented in unfamiliar codebases.
--
-- Enabled via the `editor.neo-tree` extra in lazyvim.json; this file only tweaks it.
-- It opens as a sidebar automatically when you start `nvim` with no file or on a
-- directory (`nvim .`), and it highlights the file you're editing.
--
-- Keys (outside the tree):  <leader>e  toggle tree at project root
--                           <leader>E  toggle tree at the current working directory
--                           <leader>ge git-changed files as a tree
-- Keys (inside the tree):   Z  expand every folder (the whole project structure at once)
--                           z  collapse everything
--                           l / h  open / close a folder,  <CR> open file
--                           H  show/hide dotfiles,  I  show/hide gitignored files
--                           P  preview file,  a / d / r  add / delete / rename
--                           ?  list every key
-- Bare `nvim` (dashboard): open the tree beside it without stealing focus.
-- Registered here rather than in the spec's `init`, because a user `init` would
-- replace the LazyVim extra's own `init` (which handles `nvim <directory>`).
local group = vim.api.nvim_create_augroup("explorer_autostart", { clear = true })
vim.api.nvim_create_autocmd("StdinReadPre", {
  group = group,
  once = true,
  callback = function() vim.g.started_with_stdin = true end,
})
vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  once = true,
  callback = function()
    if vim.fn.argc() == 0 and not vim.g.started_with_stdin then
      vim.schedule(function()
        require("neo-tree.command").execute({ action = "show", dir = vim.uv.cwd() })
      end)
    end
  end,
})

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        width = 36,
        mappings = {
          ["Z"] = "expand_all_nodes",
          ["z"] = "close_all_nodes",
          ["I"] = "toggle_gitignored",
        },
      },
      filesystem = {
        -- Show dotfiles (.github, .env.example, ...) since they are part of the structure,
        -- but keep gitignored build/venv/node_modules folders out so `Z` stays readable.
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = { ".git", ".DS_Store" },
        },
        -- `nvim .` opens the sidebar instead of a full-window file listing.
        hijack_netrw_behavior = "open_default",
      },
      commands = {
        -- `I` flips gitignored visibility without also showing every other filtered item.
        toggle_gitignored = function(state)
          local f = state.filtered_items
          f.hide_gitignored = not f.hide_gitignored
          require("neo-tree.sources.manager").refresh(state.name)
        end,
      },
    },
  },
}
