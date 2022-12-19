local set = vim.opt -- set options
set.tabstop = 4
set.softtabstop = 4
set.shiftwidth = 4
set.expandtab = true
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

local function on_attach(client, bufnr)
    require("lsp_config").on_attach(client, bufnr)
    require("jdtls").setup_dap({
        hotcodereplace = "auto",
        config_overrides = {
            console = "internalConsole",
            vmArgs = function()
                local profile = vim.fn.input('Spring profile: ')
                return "-Dspring.profiles.active=" .. profile
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
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-javaagent:" .. lombok_path,
    "-jar",
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
            configuration = {
                runtimes = {
                    {
                        name = "JavaSE-1.8",
                        path = "/usr/lib/jvm/java-8-openjdk/",
                    },
                    {
                        name = "JavaSE-11",
                        path = "/usr/lib/jvm/java-11-openjdk/",
                    },
                    {
                        name = "JavaSE-17",
                        path = "/usr/lib/jvm/java-17-openjdk/",
                    },
                },
            },
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

-- add generated sources to resources org.eclipse.core.resources.prefs
--
-- encoding//src/generated/java=UTF-8
-- encoding//src/generated/resources=UTF-8
--
-- add generated sources to module .classpath
--
--
-- <classpathentry kind="src" output="target/classes" path="src/generated/java">
--     <attributes>
--         <attribute name="optional" value="true"/>
--         <attribute name="maven.pomderived" value="true"/>
--     </attributes>
-- </classpathentry>
-- <classpathentry excluding="" kind="src" output="target/classes" path="src/generated/resources">
--     <attributes>
--         <attribute name="maven.pomderived" value="true"/>
--     </attributes>
-- </classpathentry>
-- <classpathentry kind="src" output="target/test-classes" path="src/test/generated/java">
--     <attributes>
--         <attribute name="optional" value="true"/>
--         <attribute name="maven.pomderived" value="true"/>
--         <attribute name="test" value="true"/>
--     </attributes>
-- </classpathentry>
-- <classpathentry excluding="" kind="src" output="target/test-classes" path="src/test/generated/resources">
--     <attributes>
--         <attribute name="maven.pomderived" value="true"/>
--         <attribute name="test" value="true"/>
--     </attributes>
-- </classpathentry>
