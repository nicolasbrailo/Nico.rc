" Note: Check :help CMD for help on each command

" *********** Look and feel *************
colorscheme torte
set guifont=Inconsolata\ Medium\ 12
syntax on	    	 " Turn on syntax highlighting
set number		 	 " Show line numbers
"set cursorline	 " Show in which line the cursor is in
set ttyfast		 	 " Should redraw screen more smoothly
"set laststatus=2	 " Always show a status bar (takes a line)
set showmode		 " display the current mode in the status line
set showcmd			 " Display partially-typed commands in the status line
"set colorcolumn=80 " Show a red column for long lines


" *********** Text formatting *************
set wildmode=list:longest,full 	" Use tab-completions
set nowrap								" Default to non wrapping mode
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set beautify
set autoindent
set smartindent


" *********** Spell checking *************
map <leader>sc :setlocal spell!<cr>
" Next misspell
map <leader>sn ]s
" Previous misspell
map <leader>sp [s
" Add ti dictionary
map <leader>sa zg
" Correct misspell
map <leader>s? z=

filetype on
filetype plugin indent on


" *********** Search & replace *************
set ignorecase	" case insensitive
set smartcase	" case insensitive only if there is no uppercase
set incsearch	" incremental search
set gdefault	" default to /g on replace
set hls			" Highlight search results
set showmatch	 	 " Show matching () {} []


" *********** Misc Vim settings *************
set hidden				" Allow movement to another buffer without saving the current one
set nocompatible		" Drop vi compatibility
set wildmenu			" Don't autocomplete on cmd, show alternatives
set mouse=a 			" Always use the mouse
set visualbell			" Stop ugly being in Vim, flash the screen instead
set ruler				" Show current cursor position
set relativenumber	    " Show numbering relative to cursor
autocmd BufEnter * set relativenumber   " Don't know why it won't work for new bufs

set so=10               " When moving, start scrolling the screen 10 lines before end
" Paste from OS clipboard
map <leader>p "+p
" Copy to OS clipboard
map <leader>c "+y

" Turn backup off, since most stuff is in SVN anyway...
set nobackup
set nowb
set noswapfile


" *********** Plugins *************
call pathogen#infect()


" Set the working directory to the directory of the current file.
"autocmd BufEnter * lcd %:p:h

" Load matchit (% to bounce from do to end, etc.)
runtime! macros/matchit.vim

augroup myfiletypes
	" Clear old autocmds in group
	autocmd!
	" autoindent with two spaces, always expand tabs
	autocmd FileType ruby,eruby,yaml set ai sw=2 sts=2 et
augroup END

" Show an error window (if there are errors)
cwindow


" *********** Mappings *************
let mapleader = ","
let g:mapleader = ","

" Use ,o to open a path under the cursor
map <leader>o <C-w>gf

" Use ,c to delete a buffer and close its tab
map <leader>c :bd<cr>

" Use <leader>w for fast saving
nmap <leader>w :w<cr>

" Used to lock commits
nmap <leader>l O# checkinlock<ESC>:w<CR>

" Ctrl-t and ,t: Write tabnew (wait for filename and <cr>)
map <c-t> :tabnew 
map <leader>t :tabnew 

" Alt-R: Exec current file as script
map <a-r> :!.%<cr>
" Ctrl-Alt-R
map <F5> :tabnew<cr>:make<cr>
" Spellcheck
map <F7> :!ispell -x %<cr>:e!<cr><cr>

" Build for a LaTeX file (assumes correct path and makefile)
autocmd filetype tex map <F5> :w<cr>:make<cr>

" Automatic closing brackets
inoremap do<SPACE>{<CR> do<SPACE>{<CR>}<SPACE>while();<ESC>O
inoremap do{<CR> do<SPACE>{<CR>}<SPACE>while();<ESC>O
inoremap {<CR> {<CR>}<ESC>O

" *********** Fuzzy Finder config *************
" Remap Ctrl-T to open Fuzzy Finder
map <C-T> :FufFile<CR>

" Makes Fuzzy finder not burn your eyes: grey menu with black letters
highlight Pmenu guifg=#000000 guibg=#CCCCCC gui=bold ctermfg=0 ctermbg=1 cterm=bold
" Makes Fuzzy finder not burn your eyes: selected item grey with black bg
highlight PmenuSel guifg=#CCCCCC guibg=#000000 gui=bold ctermfg=1 ctermbg=0 cterm=bold
" The previous two lines have the nice side effect of making the autocomplete
" menu suck less (pink, black and white? Really?)

" Because I still don't know how to use FF, let's map ,fs to search files too
"map <leader>fs :!find CLASSES -iname **<left> 
map <leader>fs :Fsfind 
map <leader>fg :Fsgrep 

" Add a quick way to get a class outline, using Tagbar
nmap <F8> :TagbarToggle<CR>

