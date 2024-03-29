if not pcall(require, "luasnip") then
  return
end

local ls = require "luasnip"
local types = require "luasnip.util.types"

ls.config.set_config {
  -- This tells LuaSnip to remember to keep around the last snippet.
  -- You can jump back into it even if you move outside of the selection
  history = false,
  updateevents = "TextChanged,TextChangedI",
  -- Autosnippets:
  enable_autosnippets = true,
  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = { { " « ", "NonTest" } },
      },
    },
  },
}
for _, ft_path in ipairs(vim.api.nvim_get_runtime_file("lua/snips/*.lua", true)) do
  loadfile(ft_path)()
end
-- <c-l> cycle options.
vim.keymap.set("i", "<c-l>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end)
vim.keymap.set("i", "<c-u>", require "luasnip.extras.select_choice")
