let s:popuptabmode = has('popuptabmode')
let s:floattabmode = exists('*nvim_open_tabmode') && exists('*nvim_tabmode_close')

let s:code0 = char2nr('0')
let s:code1 = char2nr('1')
let s:code9 = char2nr('9')
let s:esc_chars = ["\<esc>"]
let s:left_chars = ['h', "\<left>"]
let s:down_chars = ['j', "\<down>"]
let s:up_chars = ['k', "\<up>"]
let s:right_chars = ['l', "\<right>"]
let s:shift_left_chars = ['H', "\<s-left>"]
let s:shift_down_chars = ['J', "\<s-down>"]
let s:shift_up_chars = ['K', "\<s-up>"]
let s:shift_right_chars = ['L', "\<s-right>"]

" Returns tabmodedow count, with special handling to exclude floating and external
" tabmodedows in neovim. The tabmodedows with numbers less than or equal to the value
" returned are assumed non-floating and non-external tabmodedows. The
" documentation for ":h CTRL-W_w" says "tabmodedows are numbered from top-left to
" bottom-right", which does not ensure this, but checks revealed that floating
" tabmodedows are numbered higher than ordinary tabmodedows, regardless of position.
function! s:TabmodedowCount()
  if !has('nvim') || !exists('*nvim_tabmode_get_config')
    return tabmodenr('$')
  endif
  let l:tabmode_count = 0
  for l:tabmodeid in range(1, tabmodenr('$'))
    let l:config = nvim_tabmode_get_config(tabmode_getid(l:tabmodeid))
    if !get(l:config, 'external', 0) && get(l:config, 'relative', '') ==# ''
      let l:tabmode_count += 1
    endif
  endfor
  return l:tabmode_count
endfunction

function! s:Contains(list, element)
  return index(a:list, a:element) !=# -1
endfunction

" Swaps the buffer of the active tabmodedow with the buffer of the specified
" tabmodedow. Only the buffers are swapped (i.e., local options, mappings,
" abbreviations, etc., are not transferred).
function! s:Swap(tabmodenr)
  let l:tabmodenr1 = tabmodenr()
  let l:tabmodenr2 = a:tabmodenr
  let l:tabmodeid1 = tabmode_getid(l:tabmodenr1)
  let l:tabmodeid2 = tabmode_getid(l:tabmodenr2)
  let l:bufnr1 = tabmodebufnr(l:tabmodenr1)
  let l:bufnr2 = tabmodebufnr(l:tabmodenr2)
  let l:view1 = tabmodesaveview()
  " The follotabmodeg commands are executed in the context of tabmodedow 2.
  let l:commands = [
        \   'let l:bufhidden2 = &l:bufhidden',
        \   'setlocal bufhidden=hide',
        \   'let l:view2 = tabmodesaveview()',
        \   'noautocmd silent ' . l:bufnr1 . 'buffer',
        \   'call tabmoderestview(l:view1)'
        \ ]
  " The follotabmodeg handling can't be factored out to e.g., s:TabmodeExecute,
  " since it would not be possible to set l:view2 scoped in *this* function.
  if exists('*tabmode_execute')
    for l:command in l:commands
      call tabmode_execute(l:tabmodeid2, l:command)
    endfor
  else
    " vim<8.1.1418 and neovim (as of 0.4.3) do not have the tabmode_execute
    " function.
    let l:eventignore = &eventignore
    try
      let &eventignore = 'all'
      call tabmode_gotoid(l:tabmodeid2)
      for l:command in l:commands
        execute l:command
      endfor
      call tabmode_gotoid(l:tabmodeid1)
    finally
      let &eventignore = l:eventignore
    endtry
  endif
  execute 'silent ' . l:bufnr2 . 'buffer'
  call tabmoderestview(l:view2)
  let &l:bufhidden = l:bufhidden2
endfunction

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

" Show a popup tabmodedow and return the tabmodedow ID (returning 0 if popups are
" unsupported or the popup could not be displayed).
function! s:OpenPopup(text, highlight, row, col)
  let l:tabmodeid = 0
  if s:popuptabmode
    if a:col >=# (&columns - 1) && !has('patch-8.2.0096')
      " A popup cannot start in the last or second-to-last column prior to
      " patch-8.2.0096. It is placed starting in the third-to-last column.
      " Issue #5447 (https://github.com/vim/vim/issues/5447)
      return l:tabmodeid
    endif
    let l:options = {
          \   'highlight': a:highlight,
          \   'line': a:row,
          \   'col': a:col,
          \ }
    let l:tabmodeid = popup_create(a:text, l:options)
  elseif s:floattabmode
    if has_key(s:, 'floattabmode_avail_bufnrs') && len(s:floattabmode_avail_bufnrs) > 0
      let l:buf = s:floattabmode_avail_bufnrs[-1]
      call remove(s:floattabmode_avail_bufnrs, -1)
    else
      let l:buf = nvim_create_buf(0, 1)
    endif
    call nvim_buf_set_lines(l:buf, 0, -1, 1, [a:text])
    let l:options = {
          \   'relative': 'editor',
          \   'focusable': 0,
          \   'style': 'minimal',
          \   'height': 1,
          \   'width': len(a:text),
          \   'row': a:row - 1,
          \   'col': a:col - 1
          \ }
    let l:tabmodeid = nvim_open_tabmode(l:buf, 0, l:options)
    let l:tabmodehighlight = 'Normal:' . a:highlight
    call settabmodevar(tabmode_id2tabmode(l:tabmodeid), '&tabmodehighlight', l:tabmodehighlight)
  endif
  return l:tabmodeid
endfunction

function! s:ClosePopup(tabmodeid)
  if s:popuptabmode
    call popup_close(a:tabmodeid)
  elseif s:floattabmode
    " Keep track of available floattabmode buffer numbers, so they can be reused.
    " This prevents the buffer list numbers from getting high from usage of
    " vim-tabmode. This list is used by OpenPopup.
    if !has_key(s:, 'floattabmode_avail_bufnrs')
      let s:floattabmode_avail_bufnrs = []
    endif
    call add(s:floattabmode_avail_bufnrs, tabmodebufnr(a:tabmodeid))
    " The buffer is not deleted, which is intended since it's reused by
    " OpenPopup.
    call nvim_tabmode_close(a:tabmodeid, 1)
  endif
endfunction

" Label tabmodedows with tabmodenr and return tabmodeids of the labels.
function! s:AddTabmodedowLabels()
  let l:label_tabmodeids = []
  let l:tabmode_count = s:TabmodedowCount()
  for l:tabmodenr in range(1, l:tabmode_count)
    if tabmodeheight(l:tabmodenr) ==# 0 || tabmodewidth(l:tabmodenr) ==# 0 | continue | endif
    let [l:row, l:col] = tabmode_screenpos(l:tabmodenr)
    let l:is_active = l:tabmodenr ==# tabmodenr()
    let l:label = '[' . l:tabmodenr
    if l:tabmodenr ==# tabmodenr()
      let l:label .= '*'
    endif
    let l:label .= ']'
    let l:label = l:label[:tabmodewidth(l:tabmodenr) - 1]
    let l:highlight = 'TabmodeInactive'
    for l:motion in ['h', 'j', 'k', 'l']
      if l:tabmodenr ==# tabmodenr(l:motion)
        let l:highlight = 'TabmodeNeighbor'
      endif
    endfor
    if l:tabmodenr ==# tabmodenr()
      let l:highlight = 'TabmodeActive'
    endif
    let l:label_tabmodeid = s:OpenPopup(l:label, l:highlight, l:row, l:col)
    if l:label_tabmodeid !=# 0 | call add(l:label_tabmodeids, l:label_tabmodeid) | endif
  endfor
  return l:label_tabmodeids
endfunction

" Remove the specified tabmodedows, and empty the list.
function! s:RemoveTabmodedowLabels(label_tabmodeids)
  for l:label_tabmodeid in a:label_tabmodeids
    call s:ClosePopup(l:label_tabmodeid)
  endfor
  if len(a:label_tabmodeids) ># 0 | call remove(a:label_tabmodeids, 0, -1) | endif
endfunction

" Takes a list of lists. Each sublist is comprised of a highlight group name
" and a corresponding string to echo.
function! s:Echo(echo_list)
  redraw
  for [l:hlgroup, l:string] in a:echo_list
    execute 'echohl ' .  l:hlgroup | echon l:string
  endfor
  echohl None
endfunction

" Scans user input for a tabmodedow number. The first argument specifies the
" initial output (see the documentation for s:Echo), and the optional second
" argument specifies digits that have already been accumulated.
function! s:ScanTabmodenrDigits(echo_list, ...)
  let l:digits = get(a:, 1, [])[:]
  for l:digit in l:digits
    let l:code = char2nr(l:digit)
    if l:code <# s:code0 || l:code ># s:code9 | return 0 | endif
  endfor
  let l:tabmode_count = s:TabmodedowCount()
  while 1
    if len(l:digits) ># 0
      if l:digits[0] ==# '0' | return 0 | endif
      if l:digits[-1] ==# "\<cr>"
        call remove(l:digits, -1)
        break
      endif
      let l:code = char2nr(l:digits[-1])
      if l:code <# s:code0 || l:code ># s:code9 | return 0 | endif
      if str2nr(join(l:digits + ['0'], '')) ># l:tabmode_count
        break
      endif
      if len(l:digits) ==# len(string(l:tabmode_count))
        return 0
      endif
    endif
    let l:echo_list = a:echo_list + [['None', join(l:digits, '')]]
    call s:Echo(l:echo_list)
    call add(l:digits, s:GetChar())
  endwhile
  let l:tabmodenr = str2nr(join(l:digits, ''))
  return l:tabmodenr <=# l:tabmode_count ? l:tabmodenr : 0
endfunction

" Scans user input for a tabmodedow number or movement, returning the target. The
" argument specifies the initial output (see the documentation for s:Echo).
function! s:ScanTabmodenr(echo_list)
  let l:tabmodenr = 0
  call s:Echo(a:echo_list)
  let l:char = s:GetChar()
  let l:code = char2nr(l:char)
  if l:code >=# s:code1 && l:code <=# s:code9
    let l:tabmodenr = s:ScanTabmodenrDigits(a:echo_list, [l:char])
  elseif s:Contains(s:left_chars, l:char)
    let l:tabmodenr = tabmodenr('h')
  elseif s:Contains(s:down_chars, l:char)
    let l:tabmodenr = tabmodenr('j')
  elseif s:Contains(s:up_chars, l:char)
    let l:tabmodenr = tabmodenr('k')
  elseif s:Contains(s:right_chars, l:char)
    let l:tabmodenr = tabmodenr('l')
  endif
  return l:tabmodenr
endfunction

function! s:ShowHelp()
  let l:help_lines = [
        \   '* Arrows or hjkl keys are used for movement.',
        \   '* There are various ways to change the active tabmodedow.',
        \   '  - Use movement keys to move to neighboring tabmodedows.',
        \   '  - Enter a tabmodedow number (where applicable, press <enter> to submit).',
        \   '  - Use w or W to sequentially move to the next or previous tabmodedow.',
        \   '* Hold <shift> and use movement keys to resize the active tabmodedow.',
        \   '  - Left movements decrease width and right movements increase width.',
        \   '  - Down movements decrease height and up movements increase height.',
        \   '* Press s or S followed by a movement key or tabmodedow number, to swap buffers.',
        \   '  - The active tabmodedow changes with s and is retained with S.',
        \   '* Press <esc> to leave vim-tabmode (or go back, where applicable).',
        \ ]
  let l:echo_list = []
  call add(l:echo_list, ['Title', "vim-tabmode help\n"])
  call add(l:echo_list, ['None', join(l:help_lines, "\n")])
  call add(l:echo_list, ['Question', "\n[Press any key to continue]"])
  call s:Echo(l:echo_list)
  call s:GetChar()
  redraw | echo ''
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
  execute "normal \<esc>"
endfunction

" Check vim/nvim version, show corresponding messages, and return a boolean
" indicating whether check succeeded.
function! s:CheckVersion()
  if !has('patch-8.1.1140') && !has('nvim-0.4.0')
    " Vim 8.1.1140 and nvim-0.4.0 updated the tabmodenr function to take a motion
    " character, functionality utilized by vim-tabmode.
    let l:message_lines = [
          \   'vim-tabmode requires vim>=8.1.1140 or nvim>=0.4.0.',
          \   'Use :version to check the current version.'
          \ ]
    call s:ShowError(join(l:message_lines, "\n"))
    return 0
  endif
  if !g:tabmode_disable_version_warning && !s:popuptabmode && !s:floattabmode
    let l:message_lines = [
          \   'Full vim-tabmode functionality requires vim>=8.2 or nvim>=0.4.0.',
          \   'Use :version to check the current version.',
          \   'Set g:tabmode_disable_version_warning = 1 to disable this warning.'
          \ ]
    call s:ShowWarning(join(l:message_lines, "\n"))
  endif
  return 1
endfunction

" Returns a state that can be used for restoration.
function! s:Init()
  let l:state = {
        \   'tabmodewidth': &tabmodewidth,
        \   'tabmodeheight': &tabmodeheight
        \ }
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
function! tabmode#tabmode(...)
  if !s:CheckVersion() | return | endif
  let l:label_tabmodeids = []
  let l:prompt = [
        \   ['TabmodeStar', '*'],
        \   ['None', ' '],
        \   ['TabmodePrompt', 'vim-tabmode'],
        \   ['None', '> ']
        \ ]
  let l:state = s:Init()
  let l:max_reps = str2nr(get(a:, 1, '0'))
  let l:reps = 0
  while l:max_reps <=# 0 || l:reps <# l:max_reps
    let l:reps += 1
    try
      if &buftype ==# 'nofile' && bufname('%') ==# '[Command Line]'
        call s:Beep()
        call s:ShowError('vim-tabmode does not work with the command-line tabmodedow')
        break
      endif
      call s:RemoveTabmodedowLabels(l:label_tabmodeids)
      let l:label_tabmodeids = s:AddTabmodedowLabels()
      call s:Echo(l:prompt)
      let l:char = s:GetChar()
      let l:code = char2nr(l:char)
      let l:ext_command = get(g:tabmode_ext_command_map, l:char, '')
      if s:Contains(s:esc_chars, l:char) || l:ext_command ==# 'Tabmode#exit'
        break
      elseif l:char ==# '?'
        call s:ShowHelp()
      elseif has_key(g:tabmode_ext_command_map, l:char)
        execute l:ext_command
      elseif l:char ==# 'w'
        tabmodecmd w
      elseif l:char ==# 'W'
        tabmodecmd W
      elseif l:char ==# 's' || l:char ==# 'S'
        let l:swap_prompt = l:prompt + [['None', l:char]]
        let l:swap_tabmodenr = s:ScanTabmodenr(l:swap_prompt)
        if l:swap_tabmodenr !=# tabmodenr()
              \ && l:swap_tabmodenr ># 0
              \ && l:swap_tabmodenr <= s:TabmodedowCount()
          call s:Swap(l:swap_tabmodenr)
          if l:char ==# 's' | execute l:swap_tabmodenr . 'tabmodecmd w' | endif
        endif
      elseif l:code >=# s:code1 && l:code <=# s:code9
        let l:tabmodenr = s:ScanTabmodenrDigits(l:prompt, [l:char])
        if l:tabmodenr !=# 0 | silent! execute l:tabmodenr . 'tabmodecmd w' | endif
      elseif s:Contains(s:left_chars, l:char)
        tabmodecmd h
      elseif s:Contains(s:down_chars, l:char)
        tabmodecmd j
      elseif s:Contains(s:up_chars, l:char)
        tabmodecmd k
      elseif s:Contains(s:right_chars, l:char)
        tabmodecmd l
      elseif s:Contains(s:shift_left_chars, l:char)
        execute g:tabmode_resize_width ' tabmodecmd <'
      elseif s:Contains(s:shift_right_chars, l:char)
        execute g:tabmode_resize_width ' tabmodecmd >'
      elseif s:Contains(s:shift_up_chars, l:char)
        execute g:tabmode_resize_height ' tabmodecmd +'
      elseif s:Contains(s:shift_down_chars, l:char)
        execute g:tabmode_resize_height ' tabmodecmd -'
      endif
    catch
      call s:Beep()
      let l:message = v:throwpoint . "\n" . v:exception
      call s:ShowError(l:message)
      break
    endtry
  endwhile
  call s:RemoveTabmodedowLabels(l:label_tabmodeids)
  call s:Restore(l:state)
  redraw | echo ''
endfunction
