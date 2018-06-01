" Note: Check :help CMD for help on each command

" *********** Look and feel *************
colorscheme torte
set guifont=Inconsolata\ Medium\ 14
syntax on	    	 " Turn on syntax highlighting
set synmaxcol=300    " Only do syntax highlighting for the first 300 cols 
set number		 	 " Show line numbers
"set cursorline	     " Show in which line the cursor is in
set ttyfast		 	 " Should redraw screen more smoothly
"set laststatus=2	 " Always show a status bar (takes a line)
set showmode		 " display the current mode in the status line
set showcmd			 " Display partially-typed commands in the status line
"set colorcolumn=80  " Show a red column for long lines
set nomousehide      " Some times gvim decides to hide the cursor. Dunno why but I don't like it.

" *********** Text formatting *************
set wildmode=list:longest,full 	" Use tab-completions
set nowrap						" Default to non wrapping mode
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set beautify
set autoindent
set smartindent

" *********** Search & replace *************
set ignorecase	" case insensitive
set smartcase	" case insensitive only if there is no uppercase
set incsearch	" incremental search
set gdefault	" default to /g on replace
set hls			" Highlight search results
set showmatch	 	 " Show matching () {} []

" *********** Misc Vim settings *************
set hidden				" It's OK to move to another buffer without saving the current
set nocompatible		" Drop vi compatibility
set wildmenu			" Don't autocomplete on cmd, show alternatives
set mouse=a 			" Always use the mouse
set novisualbell		" Stop ugly screen flashing
set ruler				" Show current cursor position
set relativenumber	    " Show numbering relative to cursor
autocmd BufEnter * set relativenumber   " Don't know why won't work for new bufs
set so=10               " Start scrolling the screen 10 lines before end
set nobackup            " Turn backup off, most stuff is in a repo anyway...
set nowb                " Turn backup off, most stuff is in a repo anyway...
set noswapfile          " Turn backup off, most stuff is in a repo anyway...

" *********** File specific stuff *************
" autoindent with two spaces, always expand tabs
autocmd FileType ruby,eruby,yaml set ai sw=2 sts=2 et
" Build for a LaTeX file (assumes correct path and makefile)
autocmd filetype tex map <F5> :w<cr>:make<cr>

" *********** Mappings *************
let mapleader = ","
let g:mapleader = ","

" Alternative <esc> mapping, usefule when writing lots of text
inoremap <leader><leader> <esc>

" Paste from OS clipboard
map <leader>p "+p
" Copy to OS clipboard
map <leader>x "+y
" Use ,c to delete a buffer and close its tab
map <leader>c :bd<cr>
" Ctrl-t and ,t: Write tabnew (wait for filename and <cr>)
map <c-t> :tabnew 
map <leader>t :tabnew 
nmap <C-Left> :tabprev<CR>
nmap <C-Right> :tabnex<CR>

" *********** Plugins *************
"source ~/.vim/plugins/vim-pathogen/autoload/pathogen.vim
"execute pathogen#infect()

filetype on
filetype plugin indent on

" *************** Ctags ***************
set tags=./tags;/       " Search ctags file instead of just tags
" Open a tag definition in a new tab
map <C-CR> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>

" *************** Find & grep integration ***************
" Find and grep integration: use my fastgrep wrapper instead of plain grep
let g:FG_grepCommand = '~/src/Nico.rc/fastgrep.sh'
source ~/.vim/plugins/findgrep.vim

" *************** Tagbar config ***************
let tagbar_compact=1    " Don't waste screen with tips and blank lines
let tagbar_sort=0       " Don't sort alphabetically tagbar's list, show it in
                        " the defined order

nmap <F8> :TagbarToggle<CR><C-W><C-W>
source ~/.vim/plugins/tagbar.vim

" *************** Impl Switcher config ***************
let g:ImplSwitcher_searchMaxDirUps = 4
source ~/.vim/plugins/impl_switcher.vim

" *************** Other plugins ***************
source ~/.vim/plugins/bettertabnew.vim
source ~/.vim/plugins/tabmover.vim
source ~/.vim/plugins/minimalistic_p4.vim



"""""""""" STUFF I SHOULD CLEAN?

" Do I need pathogen at all?
"call pathogen#infect()


" Used to lock commits
nmap <leader>l O# checkinlock - HERE BE DRAGONS<ESC>:w<CR>

" Spellcheck
noremap <F7> :!ispell -x %<cr>:e!<cr><cr>

" *********** Fuzzy Finder config *************
" Remap Ctrl-T to open Fuzzy Finder
" map <C-T> :FufFile<CR>

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

" Display svn annotations
map <leader>cn :VCSAnnotate!<CR>


