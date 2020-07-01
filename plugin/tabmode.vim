if exists('g:loaded_tabmode')
	finish
endif
let g:loaded_tabmode = 1

nnoremap <silent> <unique> <Plug>(TabmodeEnter) :<C-u>call libmodal#Enter('TABS', funcref('tabmode#Callback'))<CR>
nmap <silent> <unique> <leader><Tab> <Plug>(TabmodeEnter)

if !exists(':TabmodeEnter')
	command! TabmodeEnter call <Plug>(TabmodeEnter)
endif
