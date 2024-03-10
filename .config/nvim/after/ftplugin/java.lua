local set = vim.opt -- set options
set.tabstop = 2
set.softtabstop = 2
set.shiftwidth = 2
set.expandtab = true
set.autoread = true
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.textDocument.completion.completionItem.snippetSupport = true

local home_path = require("os").getenv("HOME")
local vsext_path = home_path .. "/dev/vscode"
local java_debug_paths = vim.fn.glob(
    vsext_path .. "/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar"
)
local java_test_paths = vim.fn.glob(vsext_path .. "/vscode-java-test/server/*.jar")
local bundles = {
    java_debug_paths,
}
vim.list_extend(bundles, vim.split(java_test_paths, "\n"))
vim.list_extend(bundles, vim.split("", "\n"))

local jdtls_path = home_path .. "/dev/lsp/jdtls"
local jdtls_jar_path = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
local jdtls_config_path = jdtls_path .. "/config_linux"
local lombok_path = home_path .. "/dev/lsp/lombok/lombok.jar"

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local jdtls_data_path = home_path .. "/java_workspace/" .. project_name

local function format_using_make()
    local pos = vim.api.nvim_win_get_cursor(0)
    if vim.bo.modified then
        vim.cmd('w')
    end
    local format_cmd = vim.api.nvim_parse_cmd("silent make format", {})
    local out = vim.api.nvim_cmd(format_cmd, {})
    vim.api.nvim_win_set_cursor(0, pos)
end

local function on_attach(client, bufnr)
    -- require("lsp_config").on_attach(client, bufnr)
    require("jdtls").setup_dap({
        hotcodereplace = "auto",
        config_overrides = {
            console = "internalConsole",
            vmArgs = function()
                local profile = vim.fn.input('Spring profile: ')
                return "--add-opens java.base/java.time=ALL-UNNAMED -Dspring.profiles.active=" .. profile
            end,
        },
    })
    require('jdtls.dap').setup_dap_main_class_configs()
    require("jdtls.setup").add_commands()
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Define commands.
    vim.cmd(
        [[command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_compile JdtCompile lua require('jdtls').compile(<f-args>)]]
    )
    vim.cmd(
        [[command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_set_runtime JdtSetRuntime lua require('jdtls').set_runtime(<f-args>)]]
    )
    vim.cmd([[command! -buffer JdtUpdateConfig lua require('jdtls').update_project_config()]])
    vim.cmd([[command! -buffer JdtJol lua require('jdtls').jol()]])
    vim.cmd([[command! -buffer JdtBytecode lua require('jdtls').javap()]])
    vim.cmd([[command! -buffer JdtJshell lua require('jdtls').jshell()]])
    vim.api.nvim_create_user_command('LR',
        function()
            vim.api.nvim_command('LspRestart')
            require('jdtls.setup').wipe_data_and_restart()
            vim.diagnostic.reset()
        end,
        { nargs = 0 }
    )
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    -- Mappings.
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
    -- replaced by telescope
    -- buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    -- buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    -- buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    -- buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)

    -- Set some keybinds conditional on server capabilities
    local format_exit = os.execute("make -q format") / 256
    print(format_exit)
    if format_exit ~= 2 then
        local opts = { noremap = true, silent = true }
        vim.keymap.set('n', 'ff', format_using_make, opts)
    end
    if format_exit == 2 and client.server_capabilities.documentFormattingProvider then
        buf_set_keymap("n", "ff", "<cmd>lua vim.lsp.buf.format{async=true}<CR>", opts)
    end
end

local cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xms1g",
    "--add-modules=ALL-SYSTEM",
    "-javaagent:" .. lombok_path,
    "-jar",
    "--add-exports=jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED",
    "--add-exports=jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED",
    "--add-exports=jdk.compiler/com.sun.tools.javac.main=ALL-UNNAMED",
    "--add-exports=jdk.compiler/com.sun.tools.javac.model=ALL-UNNAMED",
    "--add-exports=jdk.compiler/com.sun.tools.javac.parser=ALL-UNNAMED",
    "--add-exports=jdk.compiler/com.sun.tools.javac.processing=ALL-UNNAMED",
    "--add-exports=jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED",
    "--add-exports=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED",
    "--add-opens=jdk.compiler/com.sun.tools.javac.code=ALL-UNNAMED",
    "--add-opens=jdk.compiler/com.sun.tools.javac.comp=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.time=ALL-UNNAMED",
    jdtls_jar_path,
    "-configuration",
    jdtls_config_path,
    "-data",
    jdtls_data_path,
}
local config = {
    cmd = cmd,
    -- root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),
    root_dir = require("jdtls.setup").find_root({ ".git" }),
    settings = {
        java = {
            format = {
                settings = {
                    url = "https://raw.githubusercontent.com/diffplug/freshmark/main/spotless.eclipseformat.xml",
                }
            },
            signatureHelp = { enabled = true },
            contentProvider = { preferred = 'fernflower' },
            configuration = {
                runtimes = {
                    -- {
                    --     name = "JavaSE-1.8",
                    --     path = "/usr/lib/jvm/java-8-openjdk/",
                    -- },
                    -- {
                    --     name = "JavaSE-11",
                    --     path = "/usr/lib/jvm/java-11-openjdk/",
                    -- },
                    {
                        name = "JavaSE-17",
                        path = "/usr/lib/jvm/java-17-temurin/",
                    },
                },
            },
            -- saveActions = {
            --     organizeImports = true,
            -- },
            completion = {
                favoriteStaticMembers = {
                    "io.crate.testing.Asserts.assertThat",
                    "org.assertj.core.api.Assertions.assertThat",
                    "org.assertj.core.api.Assertions.assertThatThrownBy",
                    "org.assertj.core.api.Assertions.assertThatExceptionOfType",
                    "org.assertj.core.api.Assertions.catchThrowable",
                    "org.hamcrest.MatcherAssert.assertThat",
                    "org.hamcrest.Matchers.*",
                    "org.hamcrest.CoreMatchers.*",
                    "org.junit.jupiter.api.Assertions.*",
                    "java.util.Objects.requireNonNull",
                    "java.util.Objects.requireNonNullElse",
                    "org.mockito.Mockito.*",
                    "org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*",
                },
                filteredTypes = {
                    "com.sun.*",
                    "io.micrometer.shaded.*",
                    "java.awt.*",
                    "jdk.*",
                    "sun.*",
                },
            }
        },
    },
    init_options = {
        bundles = bundles,
    },
    flags = {
        debounce_text_changes = 150,
    },
    capabilities = capabilities,
    on_attach = on_attach,
}
require("jdtls").start_or_attach(config)

vim.cmd([[nnoremap <leader>dt <Cmd>lua require'jdtls'.test_nearest_method()<CR>]])
vim.cmd([[nnoremap <leader>dc <Cmd>lua require'jdtls'.test_class()<CR>]])
