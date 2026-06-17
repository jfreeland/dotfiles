-- Customize Mason

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        -- install language servers
        "lua-language-server",
        "sqlls",

        -- install formatters
        "prettier",
        "stylua",

        -- install debuggers
        "debugpy",

        -- install any other package
        "tree-sitter-cli",
      },
    },
  },

  -- mason-null-ls auto-registers every Mason-installed tool against its
  -- filetype with no arguments. For sqlfluff that means `sqlfluff lint` with
  -- no --dialect, which errors. Disable its auto-setup; we don't use it.
  { "jay-babu/mason-null-ls.nvim", enabled = false },
}
