let s:combos = {
\	'$': 'tablast',
\	'%': '$tabmove',
\	')': '0tabmove',
\	'?': 'help tabmode-usage',
\	'a': 'tabnew',
\	'A': '$tabnew',
\	'd': 'tabclose',
\	'i': '-tabnew',
\	'I': '0tabnew',
\	's': 'tabnew | tabprevious | tabclose'
\}
let s:go_to_beginning = ['^', '0']
let s:move_left       = ['b', 'j', 'h', "\<Left>"]
let s:move_right      = ['w', 'k', 'l', "\<Right>"]
let s:shift_left      = ['B', 'J', 'H', "\<S-Left>"]
let s:shift_right     = ['W', 'K', 'L', "\<S-Right>"]

function! s:Contains(testChars, baseChar) abort
	return index(a:testChars, a:baseChar) > -1
endfunction

function! s:tabmode_callback() abort
	    if s:Contains(s:go_to_beginning , g:tabsModeInput) | execute 'tabfirst'
	elseif s:Contains(s:move_left       , g:tabsModeInput) | execute 'tabprevious'
	elseif s:Contains(s:shift_left      , g:tabsModeInput) | execute '-tabmove'
	elseif s:Contains(s:move_right      , g:tabsModeInput) | execute 'tabnext'
	elseif s:Contains(s:shift_right     , g:tabsModeInput) | execute '+tabmove'
	elseif    has_key(s:combos          , g:tabsModeInput) | execute s:combos[g:tabsModeInput]
	 endif
endfunction

function! tabmode#Enter() abort
	call libmodal#Enter('TABS', funcref('s:tabmode_callback'))
endfunction
