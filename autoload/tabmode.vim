let s:left_chars = ['b', 'j', 'h', "\<Left>"]
let s:right_chars = ['w', 'k', 'l', "\<Right>"]
let s:shift_left_chars = ['B', 'J', 'H', "\<S-Left>"]
let s:shift_right_chars = ['W', 'K', 'L', "\<S-Right>"]
let s:beginning = ['^', '0']

function! s:Contains(testChars, baseChar) abort
	return index(a:testChars, a:baseChar) > -1
endfunction

function! tabmode#Provide()
	if g:libmodalInput ==# '?'
		help tabmode-usage
	elseif s:Contains(s:beginning, g:libmodalInput)
		execute 'tabfirst'
	elseif g:libmodalInput ==# '$'
		execute 'tablast'
	elseif s:Contains(s:left_chars, g:libmodalInput)
		execute 'tabprevious'
	elseif s:Contains(s:shift_left_chars, g:libmodalInput)
		execute '-tabmove'
	elseif s:Contains(s:right_chars, g:libmodalInput)
		execute 'tabnext'
	elseif s:Contains(s:shift_right_chars, g:libmodalInput)
		execute '+tabmove'
	elseif g:libmodalInput ==# 'a'
		execute 'tabnew'
	elseif g:libmodalInput ==# 'A'
		execute '$tabnew'
	elseif g:libmodalInput ==# 'i'
		execute '-tabnew'
	elseif g:libmodalInput ==# 'I'
		execute '0tabnew'
	elseif g:libmodalInput ==# 'd'
		execute 'tabclose'
	elseif g:libmodalInput ==# 's'
		execute 'tabnew'
		execute 'tabprevious'
		execute 'tabclose'
	endif
endfunction
