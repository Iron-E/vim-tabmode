# Description

`vim-tabmode` is a Vim plugin for managing windows. Built-in functionality includes window selection, window buffer swapping, and window resizing. The plugin is extensible, allowing additional functionality to be added (see *Configuration* below).

<img src="screenshot.png?raw=true" width="800"/>

# Requirements

* Full functionality
	* `vim>=8.2` or `nvim>=0.4.0`
* Limited functionality (no window labels)
	* `vim>=8.1.1140`

# Installation

Use one of the following package managers:

* [Vim8 packages][vim8pack]:
	* `git clone https://github.com/https://gitlab.com/Iron_E/vim-tabmode ~/.vim/pack/plugins/start/vim-win`
* [Vundle][vundle]:
	* Add `Plugin 'https://gitlab.com/Iron_E/vim-tabmode'` to `~/.vimrc`
	* `:PluginInstall` or `$ vim +PluginInstall +qall`
* [Pathogen][pathogen]:
	* `git clone --depth=1 https://github.com/https://gitlab.com/Iron_E/vim-tabmode ~/.vim/bundle/vim-win`
* [vim-plug][vimplug]:
	* Add `Plug 'https://gitlab.com/Iron_E/vim-tabmode'` to `~/.vimrc`
	* `:PlugInstall` or `$ vim +PlugInstall +qall`
* [dein.vim][dein]:
	* Add `call dein#add('https://gitlab.com/Iron_E/vim-tabmode')` to `~/.vimrc`
	* `:call dein#install()`
* [NeoBundle][neobundle]:
	* Add `NeoBundle 'https://gitlab.com/Iron_E/vim-tabmode'` to `~/.vimrc`
	* Re-open vim or execute `:source ~/.vimrc`

# Usage

Enter `vim-tabmode` with `<leader><Tab>` or `:Tabmode`.

| Key         | Use                                                  | Modifiers                               |
|:-----------:|:----------------------------------------------------:|:---------------------------------------:|
| `w`/`h`/`j` | Tab left                                             | `<shift>` to move the current tab.      |
| `b`/`k`/`l` | Tab right                                            | `<shift>` to move the current tab.      |
| `<esc>`     | Leave `tabmode`                                      |                                         |
| `?`         | Show help message                                    |                                         |
| `a`         | Insert a tab and switch to it.                       |                                         |
| `A`         | Append new tab at the end of tab list                |                                         |
| `c`         | to the right with a single new tab.                  | Prepend number `N` to replace `N` tabs. |
| `d`         | (__e.g.__ `2d`).                                     | Prepend number `N` to delete `N` tabs.  |
| `dd`        | Delete the current tab.                              |                                         |
| `D`         | Delete all tabs to the right of the current tab.     |                                         |
| `i`/`I`     | Insert a tab and leave it empty.                     |                                         |
| `s`         | Replace the current tab with a new tab.              |                                         |
| `S`         | Replace all tabs to the right with a single new tab. |                                         |

See `:help win-usage` for additional details.

# Documentation

```vim
:help vim-tabmode
```

The underlying markup is in [tabmode.txt](doc/win.txt).

## Demo

<img src="screencast.gif?raw=true" width="735"/>

# License

The source code has an [MIT License](https://en.wikipedia.org/wiki/MIT_License).

See [LICENSE](LICENSE).

[dein]: https://github.com/Shougo/dein.vim
[neobundle]: https://github.com/Shougo/neobundle.vim
[pathogen]: https://github.com/tpope/vim-pathogen
[vim8pack]: http://vimhelp.appspot.com/repeat.txt.html#packages
[vimplug]: https://github.com/junegunn/vim-plug
[vundle]: https://github.com/gmarik/vundle
