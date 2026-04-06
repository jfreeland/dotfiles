-- Customize Treesitter

---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    opts = {
      highlight = { enable = true },
      ensure_installed = {
        -- System & Config
        "bash",
        "lua",
        "vim",
        "vimdoc",
        -- Web Development
        "html",
        "css",
        "scss",
        "javascript",
        "typescript",
        "tsx",
        "json",
        "yaml",
        -- Backend
        "go",
        "python",
        "sql",
        -- DevOps/Infrastructure
        "dockerfile",
        "terraform",
        "hcl",
        "helm",
        -- Documentation
        "markdown",
        "markdown_inline",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main", -- Use main branch, not master (master is frozen)
  },
}
