-- This is probably stuff that I could get out of the community plugins but
-- I've grown accustomed to having it around.
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
    "Exafunction/codeium.vim",
    lazy = false,
    config = function() end,
    opts = {},
  },
  -- https://github.com/cloudlena/dotfiles/blob/523295c1d9afe69df0618fa2881eb805807312e8/nvim/.config/nvim/lua/plugins/diff_directories.lua
  -- TODO: revisit, don't follow this rabit hole right now
  {
    "will133/vim-dirdiff",
    lazy = false,
    config = function()
      vim.g.DirDiffExcludes = ".git,.terraform"
    end,
    opts = {},
  }
}
