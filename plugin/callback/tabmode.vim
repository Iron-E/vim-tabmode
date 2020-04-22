let s:left_chars = ['b', 'j', 'h', "\<Left>"]
let s:right_chars = ['w', 'k', 'l', "\<Right>"]
let s:shift_left_chars = ['B', 'J', 'H', "\<S-Left>"]
let s:shift_right_chars = ['W', 'K', 'L', "\<S-Right>"]
let s:beginning = ['^', '0']

function! s:Contains(testChars, baseChar) abort
	return index(a:testChars, a:baseChar) > -1
endfunction

function! tabmode#Callback() abort
	if g:tabmodeInput ==# '?'
		help tabmode-usage
	elseif s:Contains(s:beginning, g:tabmodeInput)
		execute 'tabfirst'
	elseif g:tabmodeInput ==# '$'
		execute 'tablast'
	elseif s:Contains(s:left_chars, g:tabmodeInput)
		execute 'tabprevious'
	elseif s:Contains(s:shift_left_chars, g:tabmodeInput)
		execute '-tabmove'
	elseif s:Contains(s:right_chars, g:tabmodeInput)
		execute 'tabnext'
	elseif s:Contains(s:shift_right_chars, g:tabmodeInput)
		execute '+tabmove'
	elseif g:tabmodeInput ==# 'a'
		execute 'tabnew'
	elseif g:tabmodeInput ==# 'A'
		execute '$tabnew'
	elseif g:tabmodeInput ==# 'i'
		execute '-tabnew'
	elseif g:tabmodeInput ==# 'I'
		execute '0tabnew'
	elseif g:tabmodeInput ==# 'd'
		execute 'tabclose'
	elseif g:tabmodeInput ==# 's'
		execute 'tabnew'
		execute 'tabprevious'
		execute 'tabclose'
	endif
endfunction
