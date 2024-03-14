vim.api.nvim_create_autocmd({'BufNewFile', 'BufRead'}, {
    pattern = 'Tiltfile*',
    callback = function()
        vim.opt_local.filetype = 'starlark'
    end
})
