if exists('g:loaded_tabmode')
	finish
endif
let g:loaded_tabmode = 1

nnoremap <unique> <Plug>(TabmodeEnter) :<C-u>call tabmode#Enter()<CR>
nmap <silent> <unique> <leader><Tab> <Plug>(TabmodeEnter)

if !exists(':TabmodeEnter')
	command! TabmodeEnter call tabmode#Enter()
endif
