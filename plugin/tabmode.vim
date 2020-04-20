if exists('g:loaded_tabmode')
  finish
endif
let g:loaded_tabmode = 1

let s:save_cpo = &cpo
set cpo&vim

if !hasmapto('<plug>TabmodeTabmode')
  silent! map <unique> <leader>w <plug>TabmodeTabmode
endif
noremap <unique> <silent> <script> <plug>TabmodeTabmode <sid>Tabmode
noremap <sid>Tabmode :<c-u>call tabmode#tabmode()<cr>

if !exists(':Tabmode')
  command -nargs=* Tabmode :call tabmode#tabmode(<f-args>)
endif

" ************************************************************
" * User Configuration
" ************************************************************

let g:tabmode_resize_height = get(g:, 'tabmode_resize_height', 2)
let g:tabmode_resize_width = get(g:, 'tabmode_resize_width', 2)
let g:tabmode_disable_version_warning = get(g:, 'tabmode_disable_version_warning', 0)
" g:tabmode_ext_command_map allows additional commands to be added to tabmode.vim. It
" maps command keys to command strings. These will override the built-in
" vim-tabmode commands that use the same keys, except for 1) <esc>, which is used
" for exiting, and 2) ?, which is used for help. The 'Tabmode#exit' string can be
" used as a command string for exiting vim-tabmode.
" E.g.,
" :let g:tabmode_ext_command_map = {
"        \   'c': 'tabmodecmd c',
"        \   'C': 'close!',
"        \   'q': 'quit',
"        \   'Q': 'quit!',
"        \   '!': 'qall!',
"        \   'V': 'tabmodecmd v',
"        \   'S': 'tabmodecmd s',
"        \   'n': 'bnext',
"        \   'N': 'bnext!',
"        \   'p': 'bprevious',
"        \   'P': 'bprevious!',
"        \   "\<c-n>": 'tabnext',
"        \   "\<c-p>": 'tabprevious',
"        \   '=': 'tabmodecmd =',
"        \   't': 'tabnew',
"        \   'x': 'Tabmode#exit'
"        \ }
let g:tabmode_ext_command_map = get(g:, 'tabmode_ext_command_map', {})

" The default highlight groups (for colors) are specified below.
" Change these default colors by defining or linking the corresponding
" highlight group.
" E.g., the follotabmodeg will use the Error highlight for the active tabmodedow.
" :highlight link TabmodeActive Error
" E.g., the follotabmodeg will use custom highlight colors for the inactive tabmodedows.
" :highlight TabmodeInactive term=bold ctermfg=12 ctermbg=159 guifg=Blue guibg=LightCyan
highlight default link TabmodeActive DiffAdd
highlight default link TabmodeInactive Todo
highlight default link TabmodeNeighbor Todo
highlight default link TabmodeStar StatusLine
highlight default link TabmodePrompt ModeMsg

let &cpo = s:save_cpo
unlet s:save_cpo
