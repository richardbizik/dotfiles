lua << EOF

local dap_g = require "dap"
local query = require "vim.treesitter.query"
local tests_query = [[
(function_declaration
  name: (identifier) @testname
  parameters: (parameter_list
    . (parameter_declaration
      type: (pointer_type) @type) .)
  (#eq? @type "*testing.T")
  (#match? @testname "^Test.+$")) @parent
]]

local subtests_query = [[
(call_expression
  function: (selector_expression
    operand: (identifier)
    field: (field_identifier) @run)
  arguments: (argument_list
    (interpreted_string_literal) @testname
    (func_literal))
  (#eq? @run "Run")) @parent
]]

-- getting default service for nghis projects
local function get_default_service()
  local filename = "Makefile"
	local line = 7
	local directory = vim.fn.getcwd()
  local f = io.open(directory.."/"..filename, "rb")
  if f == nil then return "" end
	local i = 1
	for l in io.lines(filename) do 
		if i == line then
			if string.len(l) > 18 then 
				return string.sub(l, 18)
			else return ""
			end
		end
		i = i+1
	end
end

local function load_module(module_name)
  local ok, module = pcall(require, module_name)
  assert(ok, string.format('dap-go dependency error: %s not installed', module_name))
  return module
end

local function setup_go_adapter(dap)
  vim.fn.sign_define('DapBreakpoint', {text='⬤', texthl='', linehl='', numhl=''})
  vim.fn.sign_define('DapBreakpointRejected', {text='❌', texthl='', linehl='', numhl=''})
  vim.fn.sign_define('DapBreakpointCodition', {text='⯁', texthl='', linehl='', numhl=''})

  dap.defaults.fallback.terminal_win_cmd = '50vsplit new'
  dap.adapters.go = function(callback, config)
    local stdout = vim.loop.new_pipe(false)
    local handle
    local pid_or_err
    local host = config.host or "127.0.0.1"
    local port = config.port or "38697"
    local addr = string.format("%s:%s", host, port)
    local opts = {
      stdio = {nil, stdout},
      args = {"dap", "-l", addr},
      detached = true
    }
	handle, pid_or_err = vim.loop.spawn("/usr/bin/bash", {stdio = {nil, stdout}, args={"-c", "dlv dap -l "..addr}, detached = true}, function(code)
      stdout:close()
      handle:close()
      if code ~= 0 then
        print('dlv exited with code', code)
      end
    end)
    assert(handle, 'Error running dlv: ' .. tostring(pid_or_err))
    stdout:read_start(function(err, chunk)
      assert(not err, err)
      if chunk then
        vim.schedule(function()
          require('dap.repl').append(chunk)
        end)
      end
    end)
    -- Wait for delve to start
    vim.defer_fn(
      function()
        callback({type = "server", host = "127.0.0.1", port = port})
      end,
      500)
  end
end

local function setup_go_configuration(dap)
  local service = get_default_service()
	if service ~= nil then
		print("Running as: "..service)
	else
		service = "other"
	end
  dap.configurations.go = {
    {
      type = "go",
      name = "Debug",
      request = "launch",
      program = "${file}",
			env = {}
    },
		{
      type = "go",
      name = "Debug test (nghis)",
      request = "launch",
      mode = "test",
			program = "${workspaceFolder}/test/rest",
  		env = {
				PROFILE="TEST",
				CONFIG_FILE="${workspaceFolder}/conf/"..service.."/conf-test.yaml"
			}
    },
		{
      type = "go",
      name = "Debug main (nghis)",
      request = "launch",
			program = "${workspaceFolder}/cmd/"..service.."/main.go",
  		env = {
				PROFILE="DEV",
				CONFIG_FILE="${workspaceFolder}/conf/"..service.."/conf-dev.yaml"
			}
    }, 
    {
      type = "go",
      name = "Attach",
      mode = "local",
      request = "attach",
      processId = require('dap.utils').pick_process,
			env = {}
    },
		{
      type = "go",
      name = "Debug main",
      request = "launch",
			program = "${workspaceFolder}/main.go",
			env = {}
    }, 
    {
      type = "go",
      name = "Debug test",
      request = "launch",
      mode = "test",
      program = "${file}",
			env = {}
    },
    {
      type = "go",
      name = "Debug test (go.mod)",
      request = "launch",
      mode = "test",
      program = "./${relativeFileDirname}",
			env = {}
    },
  }
end

function setup()
  local dap = load_module("dap")
  setup_go_adapter(dap)
  setup_go_configuration(dap)
end

local function debug_test(testname)
  local dap = load_module("dap")
  dap.run({
      type = "go",
      name = testname,
      request = "launch",
      mode = "test",
      program = "./${relativeFileDirname}",
      args = {"-test.run", testname},
  		env = {
				PROFILE="TEST",
				CONFIG_FILE="${workspaceFolder}/conf/"..get_default_service().."/conf-test.yaml"
			}
  })
end

local function get_closest_above_cursor(test_tree)
  local result
  for _, curr in pairs(test_tree) do
    if not result then
      result = curr
    else
      local node_row1, _, _, _ = curr.node:range()
      local result_row1, _, _, _ = result.node:range()
      if node_row1 > result_row1 then
        result = curr
      end
    end
  end
  if result.parent then
    return string.format("%s/%s", result.parent, result.name)
  else
    return result.name
  end
end


local function is_parent(dest, source)
  if not (dest and source) then
    return false
  end
  if dest == source then
    return false
  end

  local current = source
  while current ~= nil do
    if current == dest then
      return true
    end

    current = current:parent()
  end

  return false
end

local function get_closest_test()
  local stop_row = vim.api.nvim_win_get_cursor(0)[1]
  local ft = vim.api.nvim_buf_get_option(0, 'filetype')
  assert(ft == 'go', 'dap-go error: can only debug go files, not '..ft)
  local parser = vim.treesitter.get_parser(0)
  local root = (parser:parse()[1]):root()

  local test_tree = {}

  local test_query = vim.treesitter.parse_query(ft, tests_query)
  assert(test_query, 'dap-go error: could not parse test query')
  for _, match, _ in test_query:iter_matches(root, 0, 0, stop_row) do
    local test_match = {}
    for id, node in pairs(match) do
      local capture = test_query.captures[id]
      if capture == "testname" then
        local name = query.get_node_text(node, 0)
        test_match.name = name
      end
      if capture == "parent" then
        test_match.node = node
      end
    end
    table.insert(test_tree, test_match)
  end

  local subtest_query = vim.treesitter.parse_query(ft, subtests_query)
  assert(subtest_query, 'dap-go error: could not parse test query')
  for _, match, _ in subtest_query:iter_matches(root, 0, 0, stop_row) do
    local test_match = {}
    for id, node in pairs(match) do
      local capture = subtest_query.captures[id]
      if capture == "testname" then
        local name = query.get_node_text(node, 0)
        test_match.name = string.gsub(string.gsub(name, ' ', '_'), '"', '')
      end
      if capture == "parent" then
        test_match.node = node
      end
    end
    table.insert(test_tree, test_match)
  end

  table.sort(test_tree, function(a, b)
    return is_parent(a.node, b.node)
  end)

  for _, parent in ipairs(test_tree) do
    for _, child in ipairs(test_tree) do
      if is_parent(parent.node, child.node) then
        child.parent = parent.name
      end
    end
  end

  return get_closest_above_cursor(test_tree)
end

function dap_g.debug_test()
  local testname = get_closest_test()
  local msg = string.format("starting debug session '%s'...", testname)
  print(msg)
  debug_test(testname)
end

setup()

-- open dapui automatically
-- local dap, dapui = require("dap"), require("dapui")
-- dap.listeners.after.event_initialized["dapui_config"] = function()
--   dapui.open()
-- end
-- dap.listeners.before.event_terminated["dapui_config"] = function()
--   dapui.close()
-- end
-- dap.listeners.before.event_exited["dapui_config"] = function()
--   dapui.close()
-- end

require("nvim-dap-virtual-text").setup()
require("dapui").setup({
  icons = { expanded = "▾", collapsed = "▸" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
  },
  sidebar = {
    -- You can change the order of elements in the sidebar
    elements = {
      -- Provide as ID strings or tables with "id" and "size" keys
      {
        id = "scopes",
        size = 0.25, -- Can be float or integer > 1
      },
      { id = "breakpoints", size = 0.25 },
      { id = "stacks", size = 0.25 },
      { id = "watches", size = 00.25 },
    },
    size = 40,
    position = "left", -- Can be "left", "right", "top", "bottom"
  },
  tray = {
    elements = { "repl" },
    size = 10,
    position = "bottom", -- Can be "left", "right", "top", "bottom"
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
    border = "single", -- Border style. Can be "single", "double" or "rounded"
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
  windows = { indent = 1 },
})
EOF

nnoremap <silent> <F5> :lua require'dap'.continue()<CR>
nnoremap <silent> <F6> :lua require'dap'.close()<CR>
nnoremap <silent> <F7> :lua require'dap'.step_into()<CR>
nnoremap <silent> <F8> :lua require'dap'.step_over()<CR>
nnoremap <silent> <F9> :lua require'dap'.step_out()<CR>
nnoremap <silent> <leader>b :lua require'dap'.toggle_breakpoint()<CR>
nnoremap <silent> <leader>cb :lua require'dap.breakpoints'.clear()<CR>
nnoremap <silent> <leader>B :lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
nnoremap <silent> <leader>lp :lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
nnoremap <silent> <leader>do :lua require'dapui'.toggle()<CR>
nnoremap <silent> <leader>de :lua require'dapui'.eval()<CR>
nnoremap <silent> <leader>df :lua require'dapui'.float_element()<CR>
nnoremap <silent> <leader>dr :lua require'dap'.repl.open()<CR>
nnoremap <silent> <leader>dl :lua require'dap'.run_last()<CR>
nmap <leader>dt :lua require('dap').debug_test()<CR>

function! dap#debug_test(...)
  execute "lua require('dap').debug_test()"
endfunction

function! dap#getEvalParams(...)
	let flags = (a:0 >0)? join(a:000) : ""
	let flags = "'" . flags . "'"
	execute "lua require('dapui').eval(" . flags . ")"
endfunction
command! -nargs=* Deval call dap#getEvalParams(<f-args>)
command! -nargs=* DTest call dap#debug_test(<f-args>)

