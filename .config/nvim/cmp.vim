set completeopt=menu,menuone,noselect
let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']

" autocmd TextChangedI * call s:on_text_changed()
" let s:timer_id = 0
" function! s:on_text_changed() abort
"   function! s:invoke() abort closure
" lua << EOF
"     if vim.fn.pumvisible() == 0 then
"         local cmp = require('cmp')
"         cmp.complete({ reason = cmp.ContextReason.Auto })
"     end
" EOF
"   endfunction
"   call timer_stop(s:timer_id)
"   let s:timer_id = timer_start(1000, { -> s:invoke() })
" endfunction
