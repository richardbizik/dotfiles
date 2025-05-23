local api = vim.api

local function format_sql()
    local pos = vim.api.nvim_win_get_cursor(0)
    local format_cmd = vim.api.nvim_parse_cmd("silent%!pg_format --no-space-function -w 140 -", {})
    local out = vim.api.nvim_cmd(format_cmd, {})
    vim.api.nvim_win_set_cursor(0, pos)
end

-- api.nvim_create_autocmd("BufWritePost", {
--     pattern = "*.sql",
--     callback = format_sql,
-- })
local opts = { noremap = true, silent = true }
vim.keymap.set('n', 'ff', format_sql, opts)
