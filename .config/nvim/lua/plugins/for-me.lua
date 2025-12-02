-- This is probably stuff that I could get out of the community plugins but
-- I've grown accustomed to having it around.

local utils = require "astrocore"
local COPILOT_ENABLED = os.getenv "DISABLE_COPILOT" == nil

return {
  {
    "psliwka/vim-smoothie",
    lazy = false,
    config = function() end,
    opts = {},
  },
  {
    "wakatime/vim-wakatime",
    lazy = false,
    config = function() end,
    opts = {},
  },
  {
    "bronson/vim-trailing-whitespace",
    lazy = false,
    config = function() end,
    opts = {},
  },
  {
    "tpope/vim-sleuth",
    lazy = false,
    config = function() end,
    opts = {},
  },
  {
    "tpope/vim-fugitive",
    lazy = false,
    config = function() end,
    opts = {},
  },
  {
    "fatih/vim-go",
    lazy = false,
    config = function() end,
    opts = {},
  },
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    config = function() end,
    opts = {},
  },
  {
    "tell-k/vim-autopep8",
    lazy = false,
    config = function() end,
    opts = {},
  },
  {
    "github/copilot.vim",
    cond = COPILOT_ENABLED,
    -- build = ":Copilot auth",
    lazy = false,
    config = function()
      vim.keymap.set("i", "<C-o>", 'copilot#Accept("")', {
        silent = true,
        expr = true,
        replace_keycodes = false,
      })
    end,
    opts = {},
  },
  -- {
  --   "Exafunction/codeium.vim",
  --   lazy = false,
  --   cmd = "Codeium",
  --   init = function()
  --     vim.g.codeium_enabled = 1
  --     vim.g.codeium_disable_bindings = 1
  --   end,
  --   config = function()
  --     vim.keymap.set("i", "<C-o>", function() return vim.fn["codeium#Accept"]() end, { expr = true, silent = true })
  --     vim.keymap.set("i", "<c-;>", function() return vim.fn["codeium#CycleCompletions"](1) end, { expr = true })
  --     vim.keymap.set("i", "<c-,>", function() return vim.fn["codeium#CycleCompletions"](-1) end, { expr = true })
  --     vim.keymap.set("i", "<C-BS>", function() return vim.fn["codeium#Clear"]() end, { expr = true })
  --   end,
  --   keys = {
  --     {
  --       "<leader>;;",
  --       function()
  --         vim.cmd.Codeium(vim.g.codeium_enabled == 0 and "Enable" or "Disable")
  --         utils.notify("Codeium " .. (vim.g.codeium_enabled == 0 and "Disabled" or "Enabled"))
  --       end,
  --       desc = "Toggle Codeium (global)",
  --     },
  --     {
  --       "<leader>;,",
  --       function()
  --         vim.cmd.Codeium(vim.b.codeium_enabled == 0 and "EnableBuffer" or "DisableBuffer")
  --         utils.notify("Codeium (buffer) " .. (vim.b.codeium_enabled == 0 and "Disabled" or "Enabled"))
  --       end,
  --       desc = "Toggle Codeium (buffer)",
  --     },
  --   },
  --   opts = {},
  -- },
  -- https://github.com/cloudlena/dotfiles/blob/523295c1d9afe69df0618fa2881eb805807312e8/nvim/.config/nvim/lua/plugins/diff_directories.lua
  -- TODO: revisit, don't follow this rabit hole right now
  {
    "will133/vim-dirdiff",
    lazy = false,
    config = function() vim.g.DirDiffExcludes = ".git,.terraform" end,
    opts = {},
  },
  {
    "Kicamon/markdown-table-mode.nvim",
    config = function() require("markdown-table-mode").setup() end,
  },
  -- Show hidden files in telescope (including .github)
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        hidden = true,
        file_ignore_patterns = {
          "%.git/", -- .git directory (repo internals), NOT .github
          "node_modules/",
          "%.DS_Store",
        },
      },
      pickers = {
        find_files = {
          find_command = { "fd", "--type", "f", "--hidden", "--no-ignore" },
        },
        live_grep = {
          additional_args = function() return { "--hidden", "--no-ignore" } end,
        },
      },
    },
  },
}
