return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.angular" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.helm" },
  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.markdown" },
  -- { import = "astrocommunity.pack.nix" },
  { import = "astrocommunity.pack.python" },
  -- { import = "astrocommunity.pack.sql" }, -- broken on nvim 0.12 (requires non-existent `sqls` lua module); using sqlls via Mason instead
  { import = "astrocommunity.pack.tailwindcss" },
  { import = "astrocommunity.pack.terraform" },
  { import = "astrocommunity.pack.typescript" },
  -- { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.test.neotest" },
}
