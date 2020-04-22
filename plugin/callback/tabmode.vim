let s:left_chars = ['b', 'j', 'h', "\<Left>"]
let s:right_chars = ['w', 'k', 'l', "\<Right>"]
let s:shift_left_chars = ['B', 'J', 'H', "\<S-Left>"]
let s:shift_right_chars = ['W', 'K', 'L', "\<S-Right>"]
let s:beginning = ['^', '0']

function! s:Contains(testChars, baseChar) abort
	return index(a:testChars, a:baseChar) > -1
endfunction

function! tabmode#Callback() abort
	if g:tabModeInput ==# '?'
		help tabmode-usage
	elseif s:Contains(s:beginning, g:tabModeInput)
		execute 'tabfirst'
	elseif g:tabModeInput ==# '$'
		execute 'tablast'
	elseif s:Contains(s:left_chars, g:tabModeInput)
		execute 'tabprevious'
	elseif s:Contains(s:shift_left_chars, g:tabModeInput)
		execute '-tabmove'
	elseif s:Contains(s:right_chars, g:tabModeInput)
		execute 'tabnext'
	elseif s:Contains(s:shift_right_chars, g:tabModeInput)
		execute '+tabmove'
	elseif g:tabModeInput ==# 'a'
		execute 'tabnew'
	elseif g:tabModeInput ==# 'A'
		execute '$tabnew'
	elseif g:tabModeInput ==# 'i'
		execute '-tabnew'
	elseif g:tabModeInput ==# 'I'
		execute '0tabnew'
	elseif g:tabModeInput ==# 'd'
		execute 'tabclose'
	elseif g:tabModeInput ==# 's'
		execute 'tabnew'
		execute 'tabprevious'
		execute 'tabclose'
	endif
endfunction
