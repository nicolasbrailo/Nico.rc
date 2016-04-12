" Minimalistic perforce integration: just a few commands that I frequently use


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Exit when already loaded or in compatible mode
if exists("g:loaded_MinP4Integration") || &cp
   finish
endif
let g:loaded_MinP4Integration = 1
let s:keepcpo = &cpo


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set entry points

autocmd FileChangedRO * call P4_Checkout()
autocmd BufEnter * call P4_SetGuiMenu()


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Impl


function! Get_IsP4File()
    if $P4CONFIG != ""
        " If no cfg is found, break after $N dirs
        let max_up_dirs=15
        let p4cfgpath = expand("%:p")
        while (max_up_dirs != 0)
            let p4cfgpath = system("dirname '" . p4cfgpath . "'")
            let p4cfgpath = substitute(p4cfgpath, '\n$', '', '')
            let max_up_dirs = max_up_dirs - 1

            if (p4cfgpath == "/")
                let max_up_dirs = 0
            endif

            let p4cfg = p4cfgpath . "/" . $P4CONFIG
            if filereadable(glob(p4cfg))
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
    let cmd = "echo 'List of files edited outside of perforce in '`pwd`':' && p4 diff -se && echo '' && echo 'List of files to be pushed' && `p4 diff -sa`"
    tabnew
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
    execute '$read !' . cmd
    setlocal nomodifiable
endfunction

function! P4_AddFileForCheckin()
    call Get_IsP4File()
    if exists("b:IsP4File")
        let cmdout = system("p4 add " . expand("%:p"))
        if v:shell_error == 0
            echo "Added " . expand("%:p") . " to depot"
        else
            echoerr "Error running '" . "p4 edit " . expand("%:p") . "': " . cmdout
        endif
    endif
endfunction

function! P4_GetDiffPatch()
    let cmd = "p4 diff " . expand("%:p")
    tabnew
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
    execute '$read !' . cmd
endfunction

function! P4_SetGuiMenu()
    if !has("gui_running")
        return
    endif

    if strlen(expand("%:p")) > 0
        call Get_IsP4File()
        if exists("b:IsP4File")
            amenu Perforce.Checkout :call P4_Checkout()<CR>
            amenu Perforce.Add\ This\ File\ to\ Depot :call P4_AddFileForCheckin()<CR>
            amenu Perforce.Files\ Edited\ Outside\ P4 :call P4_ListFilesEditedOutsideP4()<CR>
            amenu Perforce.Get\ Patch :call P4_GetDiffPatch()<CR>
        else
            " We're not in a P4 project: remove p4 menu, if any
            silent! aunmenu Perforce
        endif
    endif
endfunction



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Cleanup

let &cpo= s:keepcpo
unlet s:keepcpo

