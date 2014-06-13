" Better tab new: replaces the default tabnew command with a slightly smarter
" version, capable of understanding line numbers. This is very useful for
" programming, where filenames are usually expressed as "fname:line number".
" Even when grepping, the output format will usualy be "path/to/file:42". BTN
" won't reject these strings, it will instead open them and move the cursor to
" the appropiate line.

" TODO: Bug: filenames with spaces get treated by f-args as two args, then
" breaks tabnew

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Exit when already loaded, there's no GUI or in compatible mode
if exists("g:loaded_BetterTabNew") || !has("gui_running") || &cp
  " finish TODO: Development
endif
let g:loaded_BetterTabNew = 1
let s:keepcpo = &cpo


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set mappings

" TODO: It'd be interesting to see what -complete=custom,{func} does...
command! -complete=file -nargs=* TabNew call BetterTabNew(<f-args>)
" Replace the default tabnew with our improved version
cabbrev tabnew TabNew



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Impl

function! BetterTabNew(...)
    let argc = a:0

    if argc == 0
        let fname = ''
        let linenum = 0
    elseif argc == 1
        let fname = a:1
        let linenum = 0
    elseif argc == 2
        let fname = a:1
        let linenum = a:2
    else
        echoerr "Don't know what to open!"
    endif

    let userLineNo = BTN_GuessLineNumParam(linenum)
    let [checked_fname, fnameSuffixLineNo] = BTN_GuessFileAndLineParam(fname)

    " If fname is empty, then the file requested by the user doesn't exists.
    " This will happen when trying to create a new file: just tabnew to
    " whatever the user requested, not our problem!
    if len(checked_fname) == 0
        echo a:1
        echo ':tabnew "' . fname . '"'
        "execute ':tabnew "' . fname . '"'
        return
    endif

    " Give preference to the user speficied line number. If there's none, try
    " using the file name suffic line number
    let lineNum = userLineNo
    if lineNum == 0 && fnameSuffixLineNo != 0
        let lineNum = fnameSuffixLineNo
    endif

    execute 'tabnew ' . checked_fname
    execute ':' . lineNum
endfunction


" Better Tab New: tries to guess which line the user wants, from the common
" formats: "+N", ":N" or plain "N"
function! BTN_GuessLineNumParam(lineNum)
    let lineExpr = a:lineNum

    " If lineExpr is already a number, just return it as is
    if lineExpr != 0
        return lineExpr
    endif

    " lineExpr is not a number: trim whitespaces
    let lineExpr = substitute(a:lineNum, "^\\s\\+\\|\\s\\+$","","g")

    " Is the expr prefixed by an accepted line-number start prefix?
    let BTN_accepted_lineNum_prefixes = ['+', ':']
    if index(BTN_accepted_lineNum_prefixes, lineExpr[0]) != -1
        " Found an accepted line number start prefix, remove it and see if
        " that's a valid line number
        return BTN_GuessLineNumParam( lineExpr[1:] )
    endif

    " Unknown line expresion, return 0
    return 0
endfunction


" Better Tab New: tries to guess the filename for a new buffer. If the path
" doesn't exists, it will check if the filename has a suffix (eg, line number
" info)
function! BTN_GuessFileAndLineParam(fname)
    let suffix_pos = len(a:fname)
    let fname = a:fname

    " Tries trimming chars from fname til a valid fname is found
    while (len(fname) > 0) && !filereadable(glob(fname))
        let suffix_pos = suffix_pos - 1
        let fname = fname[0:suffix_pos]
    endwhile

    let lineNum = 0
    if suffix_pos != len(a:fname)
        " The fname has a suffix: try to see if it's a line number
        let suffix = a:fname[ suffix_pos+1 : ]
        let lineNum = BTN_GuessLineNumParam( suffix )
    endif

    return [fname, lineNum]
endfunction



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Cleanup

let &cpo= s:keepcpo
unlet s:keepcpo

