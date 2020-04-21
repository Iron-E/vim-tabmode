let s:popuptabmode = has('popuptabmode')
let s:floattabmode = exists('*nvim_open_tabmode') && exists('*nvim_tabmode_close')

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
	let l:help_lines = [
	\	'* Arrows or hjkl keys are used for movement.',
	\	'* There are various ways to change the active tabmodedow.',
	\	'  - Use movement keys to move to neighboring tabmodedows.',
	\	'  - Enter a tabmodedow number (where applicable, press <enter> to submit).',
	\	'  - Use w or W to sequentially move to the next or previous tabmodedow.',
	\	'* Hold <shift> and use movement keys to resize the active tabmodedow.',
	\	'  - Left movements decrease width and right movements increase width.',
	\	'  - Down movements decrease height and up movements increase height.',
	\	'* Press s or S followed by a movement key or tabmodedow number, to swap buffers.',
	\	'  - The active tabmodedow changes with s and is retained with S.',
	\	'* Press <esc> to leave vim-tabmode (or go back, where applicable).',
	\]
	let l:echo_list = []
	call add(l:echo_list, ['Title', "vim-tabmode help\n"])
	call add(l:echo_list, ['None', join(l:help_lines, "\n")])
	call add(l:echo_list, ['Question', "\n[Press any key to continue]"])
	call s:Echo(l:echo_list)
	call s:GetChar()
	redraw | echo ''
endfunction

function! s:ShowError(message)
	help tabmode-usage
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
	if !g:tabmode_disable_version_warning && !s:popuptabmode && !s:floattabmode
		let l:message_lines = [
		\		'Full vim-tabmode functionality requires vim>=8.2 or nvim>=0.4.0.',
		\		'Use :version to check the current version.',
		\		'Set g:tabmode_disable_version_warning = 1 to disable this warning.'
		\]
		call s:ShowWarning(join(l:message_lines, "\n"))
	endif
	return 1
endfunction

" Returns a state that can be used for restoration.
function! s:Init()
	let l:state = {
	\	'tabmodewidth': &tabmodewidth,
	\	'tabmodeheight': &tabmodeheight
	\}
	" Minimize tabmodewidth and tabmodeheight so that moving around doesn't unexpectedly
	" cause tabmodedow resizing.
	let &tabmodewidth = max([1, &tabmodeminwidth])
	let &tabmodeheight = max([1, &tabmodeminheight])
	return l:state
endfunction

function! s:Restore(state)
	let &tabmodewidth = a:state['tabmodewidth']
	let &tabmodeheight = a:state['tabmodeheight']
endfunction

" Runs the vim-tabmode command prompt loop. The function takes an optional
" argument specifying how many times to run (runs until exiting by default).
function! tabmode#Tabmode(...)
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
