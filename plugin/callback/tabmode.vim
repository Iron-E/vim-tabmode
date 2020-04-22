let s:left_chars = ['b', 'j', 'h', "\<Left>"]
let s:right_chars = ['w', 'k', 'l', "\<Right>"]
let s:shift_left_chars = ['B', 'J', 'H', "\<S-Left>"]
let s:shift_right_chars = ['W', 'K', 'L', "\<S-Right>"]
let s:beginning = ['^', '0']

function! s:Contains(testChars, baseChar) abort
	return index(a:testChars, a:baseChar) > -1
endfunction

function! tabmode#Callback() abort
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
endfunction
