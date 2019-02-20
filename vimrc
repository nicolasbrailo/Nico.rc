" Note: Check :help CMD for help on each command

" *********** Look and feel *************
colorscheme torte
set guifont=Inconsolata\ Medium\ 14
syntax on	    	 " Turn on syntax highlighting
set synmaxcol=400    " Only do syntax highlighting for the first N cols 
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

" Alternative <esc> mapping, useful when writing lots of text
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
" map ,fs to search files
"map <leader>fs :!find CLASSES -iname **<left> 
map <leader>fs :Fsfind 
map <leader>fg :Fsgrep 

" *************** Tagbar config ***************
let tagbar_compact=1    " Don't waste screen with tips and blank lines
let tagbar_sort=0       " Don't sort alphabetically tagbar's list, show it in
                        " the defined order

nmap <F8> :TagbarToggle<CR><C-W><C-W>
source ~/.vim/plugins/tagbar.vim

" *************** Impl Switcher config ***************
let g:ImplSwitcher_searchMaxDirUps = 4
source ~/.vim/plugins/impl_switcher.vim

" *************** GnuPG Switcher config ***************
" Add to bashrc if GPG complains " GPG_TTY=`tty`
" Add to bashrc if GPG complains " export GPG_TTY
let g:GPGPreferArmor=1
let g:GPGPreferSign=1
let gpgLvl1 = {'ext': 'pwd_lvl1.wiki.txt', 'key': 'nicolasbrailo@gmail.com'}
let gpgLvl2 = {'ext': 'pwd_lvl2.wiki.txt', 'key': 'nicolasbrailo+pgp+lvl2@gmail.com'}
let g:GPGFileDefaults = [gpgLvl1, gpgLvl2]

function! GPG_BuildFileFilter(fileDefaults)
    " Build a GPG file extension filter out of the GPGFileDefaults config
    let filter = ''
    let sep = ''
    for cfg in a:fileDefaults
        let filter = filter . sep . cfg.ext
        let sep = '\|'
    endfor
    return '*.\(' . filter . '\)'
endfunction
let g:GPGFilePattern = GPG_BuildFileFilter(g:GPGFileDefaults)

function! GPG_SetBufferOptions()
    setlocal updatetime=30000 " 30 secs
    setlocal foldmethod=marker
    setlocal foldclose=all
    setlocal foldopen=insert
    setlocal foldminlines=0

    " Make sure fold content is hidden, even if fold is a single line
    function! PwdHideFoldText()
        " Foldmarker is defined as $start_tok,$end_tok
        let l:fold_start_tok = &foldmarker[0 : match(&foldmarker, ',')-1]
        let l:first_ln = getline(v:foldstart)
        let l:fold_start_pos = match(l:first_ln, l:fold_start_tok) - 1
        let extension = expand('%:t')
        return extension . "|" . l:first_ln[0 : l:fold_start_pos]
    endfunction
    setlocal foldtext=PwdHideFoldText()

    " Set default destinatary for file type
    for cfg in g:GPGFileDefaults
        let curr_file = expand('%:t')
        let ext_pos = match(curr_file, cfg.ext)
        if len(cfg.ext) + ext_pos == len(curr_file)
            let g:GPGDefaultRecipients=[cfg.key]
        endif
    endfor
endfunction

augroup GnuPGExtra
    " Note: `autocmd EVENT $var ACTION` doesn't work, only 
    " `autocmd EVENT PATTERN ACTION` works. Use exec to get around that

    " Set extra options for all files defined in $GPGFilePattern
    execute "autocmd BufReadCmd,FileReadCmd " . g:GPGFilePattern . " call GPG_SetBufferOptions()"
    " Close buffer after $updatetime
    execute "autocmd CursorHold " . g:GPGFilePattern . " bd"
augroup END

source ~/.vim/plugins/gnupg.vim

" *************** Other plugins ***************
source ~/.vim/plugins/bettertabnew.vim
source ~/.vim/plugins/tabmover.vim

" *********** Plugins *************
" source ~/.vim/autoload/pathogen.vim
execute pathogen#infect()

" Vimwikis
let nicowiki = {}
let nicowiki.path = '~/src/nicowiki'
let nicowiki.ext = '.wiki.txt'
let nicowiki.syntax = 'markdown'
let nicowiki.auto_toc = 1
" HTML not supported with markdown " let nicowiki.auto_export = 1
" HTML not supported with markdown " let nicowiki.path_html = '~/src/nicowiki/html/'
let g:vimwiki_list = [nicowiki]

