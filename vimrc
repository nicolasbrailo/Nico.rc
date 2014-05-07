call pathogen#infect()

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


" *********** Spell checking *************
" map <leader>sc :setlocal spell!<cr>
" " Next misspell
" map <leader>sn ]s
" " Previous misspell
" map <leader>sp [s
" " Add ti dictionary
" map <leader>sa zg
" " Correct misspell
" map <leader>s? z=

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
set visualbell			" Stop ugly beeping in Vim, flash the screen instead
set ruler				" Show current cursor position
set relativenumber	    " Show numbering relative to cursor
autocmd BufEnter * set relativenumber   " Don't know why it won't work for new bufs

set so=10               " When moving, start scrolling the screen 10 lines before end

" Turn backup off, since most stuff is in a repo anyway...
set nobackup
set nowb
set noswapfile


" *********** Plugins *************

" Switch between header and impl using f4
map <F4>c :AT

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

" " Paste from OS clipboard
" map <leader>p "+p
" " Copy to OS clipboard
 map <leader>x "+y
" 
" " Use ,o to open a path under the cursor
" map <leader>o <C-w>gf

" Use ,c to delete a buffer and close its tab
map <leader>c :bd<cr>

" Use <leader>w for fast saving
nmap <leader>w :w<cr>

" Used to lock commits
nmap <leader>l O# checkinlock - HERE BE DRAGONS<ESC>:w<CR>

" Ctrl-t and ,t: Write tabnew (wait for filename and <cr>)
map <c-t> :tabnew 
map <leader>t :tabnew 
nmap <C-Left> :tabprev<CR>
nmap <C-Right> :tabnex<CR>

" Alt-R: Exec current file as script
noremap <a-r> :!.%<cr>
" Ctrl-Alt-R
noremap <F5> :tabnew<cr>:make<cr>
" Spellcheck
noremap <F7> :!ispell -x %<cr>:e!<cr><cr>

" TODO: Clean up the vimrc...
noremap <F4> :AT<cr>

" Build for a LaTeX file (assumes correct path and makefile)
autocmd filetype tex map <F5> :w<cr>:make<cr>

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

inoremap <leader><leader> <esc>

" *********** Tagbar config *************
" Don't waste screen with tips and blank lines
let tagbar_compact=1
" Don't sort alphabetically tagbar's list, show it in the defined order
let tagbar_sort=0

" Add a quick way to get a class outline, using Tagbar
nmap <F8> :TagbarToggle<CR><C-W><C-W>

" Display svn annotations
map <leader>cn :VCSAnnotate!<CR>

" Ctags
" Search ctags file instead of just tags
set tags=./tags;/
" Open a tag definition in a new tab
map <C-CR> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>


function! Get_IsP4File()
    if $P4CONFIG != ""
        " If no cfg is found, break after $N dirs
        let max_up_dirs=15
        let p4cfgpath = expand("%:p")
        while (p4cfgpath != "/") && (max_up_dirs != 0)
            let p4cfgpath = system("dirname " . p4cfgpath)
            let p4cfgpath = substitute(p4cfgpath, '\n$', '', '')
            let max_up_dirs = max_up_dirs - 1

            let p4cfg = p4cfgpath . "/" . $P4CONFIG
            if filereadable(p4cfg)
                let max_up_dirs = 0
                let b:IsP4File = 1
                let b:P4PrjRoot = p4cfgpath . "/"
            endif
        endwhile
    endif
endfunction

function! Get_P4_RelFileName()
    call Get_IsP4File()
    if exists("b:IsP4File")
        let b:CurrFile_P4FileName = substitute(expand("%:p"), b:P4PrjRoot, "", "")
    endif
endfunction

function! P4_Checkout()
    call Get_IsP4File()
    if exists("b:IsP4File")
        if (confirm("Checkout from Perforce?", "&Yes\n&No", 1) == 1)
            let cmdout = system("p4 edit " . expand("%:p"))
            if v:shell_error == 0
                set noreadonly
            else
                echoerr "Error running '" . "p4 edit " . expand("%:p") . "': " . cmdout
            endif
        endif
    endif
endfunction

function! P4_Revert()
    call Get_IsP4File()
    if exists("b:IsP4File")
        call system("p4 revert " . expand("%:p"))
    endif
endfunction

function! P4_ListFilesEditedOutsideP4()
    let cmd = "echo 'List of files edited outside of perforce in '`pwd`':' && p4 diff -se"
    tabnew
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
    execute '$read !' . cmd
    setlocal nomodifiable
endfunction


function! P4_SetGuiMenu()
    if strlen(expand("%:p")) > 0
        call Get_IsP4File()
        if exists("b:IsP4File")
            amenu Perforce.Checkout :call P4_Checkout()<CR>
            amenu Perforce.Files\ Edited\ Outside\ P4 :call P4_ListFilesEditedOutsideP4()<CR>
        else
            " We're not in a P4 project: remove p4 menu, if any
            silent! aunmenu Perforce
        endif
    endif
endfunction

if !exists("au_p4_commands")
  let au_p4_commands = 1
  autocmd FileChangedRO * call P4_Checkout()
  autocmd BufEnter * call P4_SetGuiMenu()
endif





" Find&Grep command wrapper: execute cmd, shows the results in a scratch buffer
function! FG_EvalSysCmdInNewBuff(cmd)
    tabnew
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
    let verboseCmd = 'echo "`pwd`\$ ' . a:cmd . '" && ' . a:cmd
    execute '$read !' . verboseCmd
    setlocal nomodifiable
endfunction

" Wrap a normal action: ask the user for input, then call func with it
function! FG_RequestInput_AndDo(msg, func)
    let needle = input(a:msg)
    if strlen(needle) > 0
        execute 'let cmd = ' . a:func . '("'.needle.'")'
        call FG_EvalSysCmdInNewBuff(cmd)
    endif
endfunction

" Wrap a visual action: call func with whatever is selected under the cursor
function! FG_V_GetTextForVisual_AndDo(func)
    " Copy whatever is selected in visual mode
    try
        silent! let a_save = @a
        silent! normal! gv"ay
        silent! let needle = @a
    finally
        silent! let @a = a_save
    endtry

    " Remove whitespaces
    let needle = substitute(needle, "\\n\\+","","g") 
    let needle = substitute(needle, "\\r\\+","","g") 
    let needle = substitute(needle, "^\\s\\+\\|\\s\\+$","","g") 

    if strlen(needle) > 0
        execute 'let cmd = ' . a:func . '("'.needle.'")'
        call FG_EvalSysCmdInNewBuff(cmd)
    endif
endfunction

" Wrap a normal action: call func with whatever is under the cursor
function! FG_N_GetTextUnderCursor_AndDo(func)
    let needle = expand("<cword>")
    if strlen(needle) > 0
        execute 'let cmd = ' . a:func . '("'.needle.'")'
        call FG_EvalSysCmdInNewBuff(cmd)
    endif
endfunction


" Wrap a find command: search for file "needle", show results in a new window
function! FG_FindFile(needle)
    return 'find . -type f | grep -i ' . a:needle
endfunction

" Wrap a grep command: search for needle, show results in a new window
function! FG_SearchText(needle)
    return '~/Nico.rc/fastgrep.sh "' . a:needle . '"'
endfunction

nmap <leader>f :call FG_N_GetTextUnderCursor_AndDo("FG_FindFile")<CR>
vmap <leader>f :call FG_V_GetTextForVisual_AndDo("FG_FindFile")<CR>
map  <leader>S :call FG_RequestInput_AndDo("Text search: ", "FG_SearchText")<CR>
menu Pro&ject.Text\ &Search :call FG_RequestInput_AndDo("Text search: ", "FG_SearchText")<CR>

nmap <leader>s :call FG_N_GetTextUnderCursor_AndDo("FG_SearchText")<CR>
vmap <leader>s :call FG_V_GetTextForVisual_AndDo("FG_SearchText")<CR>
map  <leader>F :call FG_RequestInput_AndDo("Find file: ", "FG_FindFile")<CR>
menu Pro&ject.&Find\ File :call FG_RequestInput_AndDo("Find file: ", "FG_FindFile")<CR>



noremap <leader>X :<C-R>*



function! MoveTab(relOffset)
    let newPos = tabpagenr() - 1 + a:relOffset
    if newPos < 0
        let newPos = 0
    endif
    execute "tabmove" newPos
endfunction

noremap <C-S-PageDown> :call MoveTab(1)<CR>
noremap <C-S-PageUp>   :call MoveTab(-1)<CR>





