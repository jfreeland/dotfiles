-- sqls is a binary LSP we no longer use (sqlls covers SQL). Three layers try
-- to start it; kill all of them:
--   1. mason-lspconfig auto-maps sqls to filetype "sql"
--   2. nanotee/sqls.nvim (helper plugin) autocmd requires a non-existent lua module
--   3. the sqls binary itself, which demands a live DB connection
package.preload["sqls"] = function() return { on_attach = function() end } end

-- uninstall sqls from Mason so the binary isn't on PATH for lspconfig to find
pcall(vim.fn.system, "rm -rf " .. vim.fn.stdpath("data") .. "/mason/packages/sqls")

return {
  { "nanotee/sqls.nvim", enabled = false },
}
