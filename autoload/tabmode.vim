let s:popupwin = has('popupwin')
let s:floatwin = exists('*nvim_open_win') && exists('*nvim_win_close')

let s:esc_chars = ["\<Esc>"]
let s:left_chars = ['b', 'k', 'h', "\<Left>"]
let s:right_chars = ['w', 'j', 'l', "\<Right>"]
let s:shift_left_chars = ['B', 'K', 'H', "\<S-Left>"]
let s:shift_right_chars = ['W', 'J', 'L', "\<S-Right>"]
let s:beginning = ['^', '$']

function! s:GetChar()
	try
		while 1
			let l:char = getchar()
			if v:mouse_tabmode ># 0 | continue | endif
			if l:char ==# "\<CursorHold>" | continue | endif
			break
		endwhile
	catch
		" E.g., <c-c>
		let l:char = char2nr("\<esc>")
	endtry
	if type(l:char) ==# v:t_number
		let l:char = nr2char(l:char)
	endif
	return l:char
endfunction

function! s:ShowHelp()
	help vim-tabmode
endfunction

function! s:ShowError(message)
	let l:echo_list = []
	call add(l:echo_list, ['Title', "vim-tabmode error\n"])
	call add(l:echo_list, ['Error', a:message])
	call add(l:echo_list, ['Question', "\n[Press any key to return]"])
	call s:Echo(l:echo_list)
	call s:GetChar()
	redraw | echo ''
endfunction

function! s:ShowWarning(message)
	let l:echo_list = []
	call add(l:echo_list, ['Title', "vim-tabmode warning\n"])
	call add(l:echo_list, ['Error', a:message])
	call add(l:echo_list, ['Question', "\n[Press any key to return]"])
	call s:Echo(l:echo_list)
	call s:GetChar()
	redraw | echo ''
endfunction

function! s:Beep()
	execute "normal \<Esc>"
endfunction

" Check vim/nvim version, show corresponding messages, and return a boolean
" indicating whether check succeeded.
function! s:CheckVersion()
	if !has('patch-8.1.1140') && !has('nvim-0.4.0')
		" Vim 8.1.1140 and nvim-0.4.0 updated the tabmodenr function to take a motion
		" character, functionality utilized by vim-tabmode.
		let l:message_lines = [
		\	'vim-tabmode requires vim>=8.1.1140 or nvim>=0.4.0.',
		\	'Use :version to check the current version.'
		\]
		call s:ShowError(join(l:message_lines, "\n"))
		return 0
	endif
	if !g:tabmode_disable_version_warning && !s:popupwin && !s:floatwin
		let l:message_lines = [
		\	'Full vim-tabmode functionality requires vim>=8.2 or nvim>=0.4.0.',
		\	'Use :version to check the current version.',
		\	'Set g:tabmode_disable_version_warning = 1 to disable this warning.'
		\]
		call s:ShowWarning(join(l:message_lines, "\n"))
	endif
	return 1
endfunction

" Returns a state that can be used for restoration.
function! s:Init()
	let l:state = {
	\	'winwidth': &winwidth,
	\	'winheight': &winheight
	\}
	" Minimize winwidth and winheight so that moving around doesn't unexpectedly
	" cause window resizing.
	let &winwidth = max([1, &winminwidth])
	let &winheight = max([1, &winminheight])
	return l:state
endfunction

function! s:Restore(state)
	let &winwidth = a:state['winwidth']
	let &winheight = a:state['winheight']
endfunction

" Runs the vim-tabmode command prompt loop. The function takes an optional
" argument specifying how many times to run (runs until exiting by default).
function! tabmode#Enter(...)
	if !s:CheckVersion() | return | endif
	let l:label_winids = []
	let l:prompt = [
	\	 ['WinStar', '*'],
	\	 ['None', ' '],
	\	 ['WinPrompt', 'vim-tabmode'],
	\	 ['None', '> ']
	\]
	let l:state = s:Init()
	let l:max_reps = str2nr(get(a:, 1, '0'))
	let l:reps = 0
	while l:max_reps <=# 0 || l:reps <# l:max_reps
		let l:reps += 1
		try
			if &buftype ==# 'nofile' && bufname('%') ==# '[Command Line]'
				call s:Beep()
				call s:ShowError('vim-tabmode does not work with the command-line window')
				break
			endif
			if s:Contains(s:esc_chars, l:char)
				break
			elseif l:char ==# '?'
				s:ShowHelp()
			elseif s:Contains(s:beginning, l:char)
				execute 'tabmove 0'
			elseif l:char ==# '$'
				execute 'tabmove $'
			elseif s:Contains(s:left_chars, l:char)
				execute 'tabnext'
			elseif s:Contains(s:shift_left_chars, l:char)
				execute '+tabmove'
			elseif s:Contains(s:right_chars, l:char)
				execute 'tabprevious'
			elseif s:Contains(s:shift_right_chars, l:char)
				execute '-tabmove'
			elseif l:char ==# 'a'
				execute 'tabnew'
				execute 'tabnext'
			elseif l:char ==# 'A'
				execute '$tabnew'
				execute '$tabmove'
			elseif l:char ==# 'i'
				execute '-tabnew'
				execute 'tabprevious'
			elseif l:char ==# 'I'
				execute '0tabnew'
				execute '0tabmove'
			elseif l:char ==# 'd'
				execute 'tabclose'
			elseif l:char ==# 's'
				execute 'tabnew'
				execute '-tabmove'
				execute 'tabclose'
			endif
		catch
			call s:Beep()
			let l:message = v:throwpoint . "\n" . v:exception
			call s:ShowError(l:message)
			break
		endtry
	endwhile
	call s:Restore(l:state)
	redraw | echo ''
endfunction
