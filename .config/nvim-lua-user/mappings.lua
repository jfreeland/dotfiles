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
        ["<C-S-Up>"] = { function() require("smart-splits").resize_up() end, desc = "Resize split up" },
        ["<C-S-Down>"] = { function() require("smart-splits").resize_down() end, desc = "Resize split down" },
        ["<C-S-Left>"] = { function() require("smart-splits").resize_left() end, desc = "Resize split left" },
        ["<C-S-Right>"] = { function() require("smart-splits").resize_right() end, desc = "Resize split right" }, }
}
