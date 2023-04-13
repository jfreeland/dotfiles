return {
    n = {
        ["[b"] = false, -- only add if you want to disable new key binding for switching tabs
        ["]b"] = false, -- only add if you want to disable new key binding for switching tabs
        L = {
          function() require("astronvim.utils.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end,
          desc = "Next buffer",
        },
        H = {
          function() require("astronvim.utils.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
          desc = "Previous buffer",
        },
    }
}
