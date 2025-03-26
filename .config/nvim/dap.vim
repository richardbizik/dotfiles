nnoremap <silent> <F5> :lua require'dap'.continue()<CR>
nnoremap <silent> <F6> :lua require'dap'.terminate()<CR>
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

