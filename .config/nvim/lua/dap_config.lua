local dap_g = require "dap"
local query = require "vim.treesitter.query"
local treesitter = require "vim.treesitter"
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

local function load_module(module_name)
    local ok, module = pcall(require, module_name)
    assert(ok, string.format('dap-go dependency error: %s not installed', module_name))
    return module
end

vim.fn.sign_define('DapBreakpoint', { text = '⬤', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointRejected', { text = '❌', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointCodition', { text = '⯁', texthl = '', linehl = '', numhl = '' })

local function setup_go_adapter(dap)
    dap.defaults.fallback.terminal_win_cmd = '50vsplit new'

    dap.adapters.go = function(callback, config)
        local stdout = vim.loop.new_pipe(false)
        local handle
        local pid_or_err
        local host = config.host or "127.0.0.1"
        local port = config.port or "38697"
        local addr = string.format("%s:%s", host, port)
        local opts = {
            stdio = { nil, stdout },
            args = { "dap", "-l", addr },
            detached = true
        }
        handle, pid_or_err = vim.loop.spawn("/usr/bin/bash",
            { stdio = { nil, stdout }, args = { "-c", "dlv dap -l " .. addr }, detached = true }, function(code)
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
                local s = chunk:gsub('\x1b%[%d+;%d+;%d+;%d+;%d+m', '')
                    :gsub('\x1b%[%d+;%d+;%d+;%d+m', '')
                    :gsub('\x1b%[%d+;%d+;%d+m', '')
                    :gsub('\x1b%[%d+;%d+m', '')
                    :gsub('\x1b%[%d+m', '')
                vim.schedule(function()
                    require('dap.repl').append(s)
                end)
            end
        end)
        -- Wait for delve to start
        vim.defer_fn(
            function()
                callback({ type = "server", host = "127.0.0.1", port = port })
            end,
            500)
    end
end

local function setup_go_configuration(dap, conf)
    dap.configurations.go = {
        {
            type = "go",
            name = "Debug",
            request = "launch",
            program = "${file}",
        },
        {
            type = "go",
            name = "Debug custom main (generator)",
            request = "launch",
            program = function()
                local exec = vim.fn.input('Executable: ')
                return "${workspaceFolder}/cmd/" .. exec .. "/main.go"
            end,
            env = {
                PROFILE = "DEV",
                CONFIG_FILE = function()
                    local exec = vim.fn.input('Config: ')
                    return "${workspaceFolder}/conf/" .. exec .. "/conf-dev.yaml"
                end,
            }
        },
        {
            type = "go",
            name = "Attach",
            mode = "local",
            request = "attach",
            processId = require('dap.utils').pick_process,
        },
        {
            type = "go",
            name = "Attach (remote)",
            mode = "remote",
            request = "attach",
            port = 4300,
            host = "localhost",
        },
        {
            type = "go",
            name = "Debug main",
            request = "launch",
            program = "${workspaceFolder}/",
            env = {
                PROFILE = "DEV",
            },
        },
        {
            type = "go",
            name = "Debug test",
            request = "launch",
            mode = "test",
            program = "${file}",
        },
        {
            type = "go",
            name = "Debug test (go.mod)",
            request = "launch",
            mode = "test",
            program = "./${relativeFileDirname}",
        },
    }
    if conf.dap ~= nil and #conf.dap > 0 then
        for _, v in pairs(conf.dap) do
            table.insert(dap.configurations.go, v)
        end
    end
end

-- check if config file is present and load it
local function read_config()
    local filename = ".nvim.json"
    local directory = vim.fn.getcwd()
    local f = io.open(directory .. "/" .. filename, "rb")
    if f == nil then return {} end
    local fileContent = f:read("*all")
    if pcall(function()
            vim.json.decode(fileContent)
        end)
    then
        local table = vim.json.decode(fileContent)
        return table
    else
        print("errorneus json in .nvim.json")
    end
    return {}
end

local function setup()
    local dap = load_module("dap")
    local conf = read_config()
    setup_go_adapter(dap)
    setup_go_configuration(dap, conf)
end

vim.api.nvim_create_user_command('DapReloadConfig',
    function()
        setup()
    end, {})


local function debug_test(testname)
    -- match the exact test name
    local test_regex = "^" .. testname .. "$"
    local dap = load_module("dap")
    local conf = read_config()
    local confFile = ""
    if conf.dapTest.config ~= "" then
        confFile = conf.dapTest.config
    else
        confFile = "${workspaceFolder}/conf-test.yaml"
    end

    dap.run({
        type = "go",
        name = testname,
        request = "launch",
        mode = "test",
        program = "./${relativeFileDirname}",
        args = { "-test.run", test_regex },
        env = {
            PROFILE = "TEST",
            CONFIG_FILE = confFile,
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
  local ft = vim.api.nvim_buf_get_option(0, "filetype")
  assert(ft == "go", "can only find test in go files, not " .. ft)
  local parser = vim.treesitter.get_parser(0)
  local root = (parser:parse()[1]):root()

  local test_tree = {}

  local test_query = vim.treesitter.query.parse(ft, tests_query)
  assert(test_query, "could not parse test query")
  for _, match, _ in test_query:iter_matches(root, 0, 0, stop_row, { all = true }) do
    local test_match = {}
    for id, nodes in pairs(match) do
      for _, node in ipairs(nodes) do
        local capture = test_query.captures[id]
        if capture == "testname" then
          local name = vim.treesitter.get_node_text(node, 0)
          test_match.name = name
        end
        if capture == "parent" then
          test_match.node = node
        end
      end
    end
    table.insert(test_tree, test_match)
  end

  local subtest_query = vim.treesitter.query.parse(ft, subtests_query)
  assert(subtest_query, "could not parse test query")
  for _, match, _ in subtest_query:iter_matches(root, 0, 0, stop_row, { all = true }) do
    local test_match = {}
    for id, nodes in pairs(match) do
      for _, node in ipairs(nodes) do
        local capture = subtest_query.captures[id]
        if capture == "testname" then
          local name = vim.treesitter.get_node_text(node, 0)
          test_match.name = string.gsub(string.gsub(name, " ", "_"), '"', "")
        end
        if capture == "parent" then
          test_match.node = node
        end
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
    layouts = {
        {
            elements = {
                'watches',
                'scopes',
                'breakpoints',
                'stacks',
            },
            size = 40,
            position = 'left',
        },
        {
            elements = {
                'repl',
                -- 'console',
            },
            size = 13,
            position = 'bottom',
        },
    },
    floating = {
        max_height = nil,  -- These can be integers or a float between 0 and 1.
        max_width = nil,   -- Floats will be treated as percentage of your screen.
        border = "single", -- Border style. Can be "single", "double" or "rounded"
        mappings = {
            close = { "q", "<Esc>" },
        },
    },
    windows = { indent = 1 },
})

-- require("nvim-dap-virtual-text").setup {
--     only_first_definition = true,
--     all_references = false,
--     show_stop_reason = true,
-- }
