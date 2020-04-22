if exists('g:loaded_tabmode')
	finish
endif
let g:loaded_tabmode = 1

execute 'source' expand('<sfile>:p:h') . '/callback/tabmode.vim'

if !hasmapto('<Plug>TabmodeEnter')
	silent! nmap <unique> <leader><Tab> <Plug>TabmodeEnter
endif

nnoremap <unique> <silent> <script> <Plug>TabmodeEnter <SID>TabmodeEnter
nnoremap <SID>TabmodeEnter :<C-u>call libmodal#Enter('TABS', funcref('tabmode#Callback'))<CR>

if !exists(':TabmodeEnter')
	command! TabmodeEnter :call <Plug>TabmodeEnter
endif
