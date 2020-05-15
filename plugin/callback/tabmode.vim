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

function! tabmode#Callback() abort
<<<<<<< Updated upstream
	if g:tabsModeInput ==# '?'
		help tabmode-usage
	elseif s:Contains(s:beginning, g:tabsModeInput)
		execute 'tabfirst'
	elseif g:tabsModeInput ==# '$'
		execute 'tablast'
	elseif s:Contains(s:left_chars, g:tabsModeInput)
		execute 'tabprevious'
	elseif s:Contains(s:shift_left_chars, g:tabsModeInput)
		execute '-tabmove'
	elseif s:Contains(s:right_chars, g:tabsModeInput)
		execute 'tabnext'
	elseif s:Contains(s:shift_right_chars, g:tabsModeInput)
		execute '+tabmove'
	elseif g:tabsModeInput ==# 'a'
		execute 'tabnew'
	elseif g:tabsModeInput ==# 'A'
		execute '$tabnew'
	elseif g:tabsModeInput ==# 'i'
		execute '-tabnew'
	elseif g:tabsModeInput ==# 'I'
		execute '0tabnew'
	elseif g:tabsModeInput ==# 'd'
		execute 'tabclose'
	elseif g:tabsModeInput ==# 's'
		execute 'tabnew'
		execute 'tabprevious'
		execute 'tabclose'
	endif
||||||| constructed merge base
	if g:tabsModeInput ==# '?'
		help tabmode-usage
	elseif s:Contains(s:beginning, g:tabsModeInput)
		execute 'tabfirst'
	elseif g:tabsModeInput ==# ')'
		execute '0tabmove'
	elseif g:tabsModeInput ==# '$'
		execute 'tablast'
	elseif g:tabsModeInput ==# '%'
		execute '$tabmove'
	elseif s:Contains(s:left_chars, g:tabsModeInput)
		execute 'tabprevious'
	elseif s:Contains(s:shift_left_chars, g:tabsModeInput)
		execute '-tabmove'
	elseif s:Contains(s:right_chars, g:tabsModeInput)
		execute 'tabnext'
	elseif s:Contains(s:shift_right_chars, g:tabsModeInput)
		execute '+tabmove'
	elseif g:tabsModeInput ==# 'a'
		execute 'tabnew'
	elseif g:tabsModeInput ==# 'A'
		execute '$tabnew'
	elseif g:tabsModeInput ==# 'i'
		execute '-tabnew'
	elseif g:tabsModeInput ==# 'I'
		execute '0tabnew'
	elseif g:tabsModeInput ==# 'd'
		execute 'tabclose'
	elseif g:tabsModeInput ==# 's'
		execute 'tabnew'
		execute 'tabprevious'
		execute 'tabclose'
	endif
=======
	    if s:Contains(s:go_to_beginning , g:tabsModeInput) | execute 'tabfirst'
	elseif s:Contains(s:move_left       , g:tabsModeInput) | execute 'tabprevious'
	elseif s:Contains(s:shift_left      , g:tabsModeInput) | execute '-tabmove'
	elseif s:Contains(s:move_right      , g:tabsModeInput) | execute 'tabnext'
	elseif s:Contains(s:shift_right     , g:tabsModeInput) | execute '+tabmove'
	elseif s:Contains(s:combos          , g:tabsModeInput) | execute s:combos[g:tabsModeInput]
	 endif
>>>>>>> Stashed changes
endfunction
