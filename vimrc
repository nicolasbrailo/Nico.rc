" Note: Check :help CMD for help on each command

" *********** GUIish stuff *************
colorscheme torte
set guifont=Inconsolata\ Medium\ 14
set guifont=Menlo-Regular:h14
syntax on            " Turn on syntax highlighting
set synmaxcol=200    " Only do syntax highlighting for the first N cols
set number           " Show line numbers
" set cursorline      " Highlight current line
set ttyfast          " Should redraw screen more smoothly
"set laststatus=2    " Always show a status bar (takes a line)
set showmode         " display the current mode in the status line
set showcmd          " Display partially-typed commands in the status line
"set colorcolumn=80  " Show a red column for long lines
set nomousehide      " Some times gvim decides to hide the cursor. Dunno why but I don't like it.
set mouse=a          " Always use the mouse
set novisualbell     " Stop ugly screen flashing
set ruler            " Show current cursor position
set relativenumber   " Show numbering relative to cursor
autocmd BufEnter * set relativenumber   " Don't know why won't work for new bufs
set scrolloff=4      " Start scrolling the screen 10 lines before end

filetype on
filetype plugin indent on

" *********** Text formatting *************
set wildmode=list:longest,full    " Use tab-completions
set nowrap                        " Default to non wrapping mode
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set autoindent
set smartindent

" *********** Search & replace *************
set ignorecase    " case insensitive
set smartcase     " case insensitive only if there is no uppercase
set incsearch     " incremental search
set gdefault      " default to /g on replace
set hls           " Highlight search results
set showmatch     " Show matching () {} []

" *********** Misc Vim settings *************
set hidden            " It's OK to move to another buffer without saving the current
set nocompatible      " Drop vi compatibility
set wildmenu          " Don't autocomplete on cmd, show alternatives
set nobackup          " Turn backup off, most stuff is in a repo anyway...
set nowb              " Turn backup off, most stuff is in a repo anyway...
set noswapfile        " Turn backup off, most stuff is in a repo anyway...

" *********** Mappings *************
let mapleader = ","
let g:mapleader = ","

" Closer pg-up/dn
imap <C-Up> <PageUp>
imap <C-Down> <PageDown>
map <C-Up> <PageUp>
map <C-Down> <PageDown>

" Alternative <esc> mapping, useful when writing lots of text
inoremap <leader><leader> <esc>

" " Paste from OS clipboard
" map <leader>p "+p
" " Copy to OS clipboard
" map <leader>x "+y
" Use ,c to delete a buffer and close its tab
map <leader>c :bd<cr>
" Ctrl-t and ,t: Write tabnew (wait for filename and <cr>)
map <leader>t :tabnew 
nmap <C-Left> :tabprev<CR>
nmap <C-Right> :tabnex<CR>

" FN mappings
nmap <F8> :TagbarToggle<CR><C-W><C-W>
nmap <leader>1 :TagbarToggle<CR><C-W><C-W>
noremap <F4> :call ImplSwitcher_OpenCurrentImplFile(1)<cr>
nmap <leader>2 :call ImplSwitcher_OpenCurrentImplFile(1)<cr>
map <leader>f :call FG_RequestInput_AndDo("Find file: ", "FG_FindFile")<CR>

" *************** Ctags ***************
set tags=./tags;/       " Search ctags file instead of just tags
" Open a tag definition in a new tab
map <C-CR> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>

" *************** Find & grep integration ***************
" Find and grep integration: use my fastgrep wrapper instead of plain grep
let g:FG_grepCommand = '~/Nico.rc/fastgrep.sh'
source ~/.vim/plugins/findgrep.vim

" If $VIM_PATH is not empty, adding it to path so that #include searches work
" Eg:
"   if there's an #include "foo/bar/baz.h"
"   located in /path/to/file/foo/bar/baz.h
"   export VIM_PATH=/path/to/file
" Should work with multiple paths split with a comma
if !empty($VIM_PATH)
  set path+=$VIM_PATH
endif

" *************** Tagbar config ***************
let tagbar_compact=1    " Don't waste screen with tips and blank lines
let tagbar_sort=0       " Don't sort alphabetically tagbar's list, show it in
                        " the defined order

source ~/.vim/plugins/tagbar.vim

" *************** Impl Switcher config ***************
let g:ImplSwitcher_searchMaxDirUps = 4
source ~/.vim/plugins/impl_switcher.vim

" *************** GnuPG Switcher config ***************
" Add to bashrc if GPG complains " GPG_TTY=`tty`
" Add to bashrc if GPG complains " export GPG_TTY
" Still not working? Maybe IDE has no key agent. Try gpg-connect-agent
let g:GPGPreferArmor=1
let g:GPGPreferSign=1
let gpgLvl1 = {'ext': 'secure.pwd', 'key': 'nicolasbrailo+pwd+secure@gmail.com'}
let gpgLvl2 = {'ext': 'general.pwd', 'key': 'nicolasbrailo+pwd+general@gmail.com'}
let g:GPGFileDefaults = [gpgLvl1, gpgLvl2]
"let g:GPGDebugLevel=99999
"let g:GPGDebugLog='~/gpg.vim.log'

source ~/.vim/plugins/config_gnupg.vim
source ~/.vim/plugins/gnupg.vim

" *************** Other plugins ***************
source ~/.vim/plugins/bettertabnew.vim
source ~/.vim/plugins/tabmover.vim

noremap <C-S-RIGHT> :call MoveTab(2)<CR>
noremap <C-S-LEFT> :call MoveTab(-1)<CR>

" https://github.com/Valloric/YouCompleteMe#c-family-semantic-completion
let g:ycm_global_ycm_extra_conf = '~/.vim/ycm_extraconf.py'
let g:ycm_disable_for_files_larger_than_kb = 50
" Cheatsheet:
"   YcmDiags -> See all errors/warnings in a file
"   YcmDebugInfo -> See compile command for file
"   YcmCompleter GoTo -> Jump to definition/impl


" *********** Plugins *************
execute pathogen#infect()

" Open NERDTree if no file is specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" Close NERDTree if it's the only remaining window
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

let g:NERDTreeQuitOnOpen=1

function! IsNerdTreeEnabled()
    return exists('t:NERDTreeBufName') && bufwinnr(t:NERDTreeBufName) != -1
endfunction

" Toggle NERDTree in the current buffer's directory
function! ToggleInCurrBuffDir()
    " If tab is already open then just toggle it (ie close it) ||
    " if there is no saved file, then just toggle
    if IsNerdTreeEnabled() || len(expand('%:p')) == 0
        exec 'NERDTreeToggle'
    else
        exec 'NERDTreeFind'
    endif
endfunction

map <leader>n :call ToggleInCurrBuffDir()<CR>

" VimWiki ========================

" Handle VimWiki links in the format of vlocal: to bypass vimwiki syntax
" (which screwes with my custom gnupg folding)
function! VimwikiLinkHandler(link)
    let scheme = 'vlocal:'
    let pos = match(a:link, scheme)
    if pos != -1
        let path = a:link[pos + len(scheme) : ]
        exec 'tabnew ' . path
        return 1
    endif

    " Use default hanlder
    return 0
endfunction

" Some custom coloring
source ~/.vim/vimwiki.syntax.vim

" Vimwikis
let nicowiki = {}
let nicowiki.path = '~/src/nicowiki'
let nicowiki.ext = '.wiki.txt'
let nicowiki.syntax = 'markdown'
let nicowiki.auto_toc = 1
let fbwiki = {}
let fbwiki.path = '~/src/fbwiki'
let fbwiki.ext = '.wiki.txt'
let fbwiki.syntax = 'markdown'
let fbwiki.auto_toc = 1
" HTML not supported with markdown " let nicowiki.auto_export = 1
" HTML not supported with markdown " let nicowiki.path_html = '~/src/nicowiki/html/'
let g:vimwiki_list = [nicowiki, fbwiki]

