" Find & Grep integration: creates a few shortcuts for using find and grep.


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Exit when already loaded or in compatible mode
if exists("g:loaded_FG_Cmd_integration") || &cp
  finish
endif
let g:loaded_FG_Cmd_integration = 1
let s:keepcpo = &cpo


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set mappings

nmap <leader>s :call FG_N_GetTextUnderCursor_AndDo("FG_SearchText")<CR>
vmap <leader>s :call FG_V_GetTextForVisual_AndDo("FG_SearchText")<CR>
map  <leader>F :call FG_RequestInput_AndDo("Find file: ", "FG_FindFile")<CR>
menu Pro&ject.&Find\ File :call FG_RequestInput_AndDo("Find file: ", "FG_FindFile")<CR>

nmap <leader>f :call FG_N_GetTextUnderCursor_AndDo("FG_FindFile")<CR>
vmap <leader>f :call FG_V_GetTextForVisual_AndDo("FG_FindFile")<CR>
map  <leader>S :call FG_RequestInput_AndDo("Text search: ", "FG_SearchText")<CR>
menu Pro&ject.Text\ &Search :call FG_RequestInput_AndDo("Text search: ", "FG_SearchText")<CR>




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Impl


" Wrap a grep command: search for needle
function! FG_SearchText(needle)
    let grep_cmd = "grep"
    if exists("g:FG_grepCommand")
        let grep_cmd = g:FG_grepCommand
    endif

    return grep_cmd . ' "' . a:needle . '"'
endfunction

" Wrap a find command: search for file "needle"
function! FG_FindFile(needle)
    return 'find . -type f | grep -i ' . a:needle
endfunction



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



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Cleanup

let &cpo= s:keepcpo
unlet s:keepcpo

