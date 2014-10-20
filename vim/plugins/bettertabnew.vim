" Better tab new: replaces the default tabnew command with a slightly smarter
" version, capable of understanding line numbers. This is very useful for
" programming, where filenames are usually expressed as "fname:line number".
" Even when grepping, the output format will usualy be "path/to/file:42". BTN
" won't reject these strings, it will instead open them and move the cursor to
" the appropiate line.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Exit when already loaded, there's no GUI or in compatible mode
if exists("g:loaded_BetterTabNew") || !has("gui_running") || &cp
    finish
endif
let g:loaded_BetterTabNew = 1
let s:keepcpo = &cpo


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Configuration

" Set to 1 to get a verbose description of the lookup process
if !exists("g:BTN_debugMode")
    let g:BTN_debugMode = 0
endif

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
        return BTN_OpenBlankTab()

    elseif (argc == 2) && BTN_IsFnameValid(a:1) && BTN_CoerceToLineNum(a:2)
        " User called BTN with a valid path and line number, we don't
        " have to do anything fancy
        return BTN_OpenTab(a:1, BTN_CoerceToLineNum(a:2))
    endif

    " If we reached this point, we have two or more params and we can't
    " make sense out of them. We'll just paste them all together (that way
    " fnames with spaces will be handled correctly) and try to figure out
    " if that string results in a valid fname.
    let stuffToOpen = join(a:000, ' ')
    let [fname, suffix] = BTN_GuessFname(stuffToOpen)
    if g:BTN_debugMode
        echoerr 'Trying to guess fname from input '.stuffToOpen
        echoerr 'Guessed fname: '.fname
    endif

    if (len(fname) != 0)
        return BTN_OpenTab(fname, BTN_GuessLineNum(suffix))
    endif

    " If fname is empty, we were not able to find a file from whatever the
    " user wanted. It may be because the file doesn't exist yet. We'll just
    " forward whatever we got from the user to the default tabnew impl, with
    " spaces and all.
    let defaultArgs = fnameescape(join(a:000, " "))

    if g:BTN_debugMode
        echoerr "Don't know how to interpret the input."
        echoerr "Forwarding to default tabnew ".defaultArgs
    endif

    execute 'tabnew ' . defaultArgs
endfunction


" When called with no arguments, BTN will open a blank new tab (defualt
" behavior for :tabnew too)
function! BTN_OpenBlankTab()
    if g:BTN_debugMode
        echoerr 'Requested new blank tab'
    endif

    execute 'tabnew'
endfunction


" Open a new tab for fname, jump to lineNum
function! BTN_OpenTab(fname, lineNum)
    let fname = fnameescape(a:fname)

    if g:BTN_debugMode
        echoerr 'Requested new tab with file '.fname.' at line '.a:lineNum
        echoerr 'tabnew "'.fname.'"'
    endif

    execute 'tabnew '.fname
    execute ':'.a:lineNum
endfunction


" Checks if a file path is valid
function! BTN_IsFnameValid(fname)
    return filereadable(glob(a:fname))
endfunction


" Checks if a line number is valid.
" This function is cheatty, it will say anything starting with an int is
" valid: "42:foobar" will be OK (42 should be returned)
function! BTN_CoerceToLineNum(lineNum)
    if a:lineNum != 0
        return ((a:lineNum+1)-1)
    else
        return 0
    endif
endfunction


" Finds a valid file from a string which may contain garbage at the end, then
" returns a string with a valid path and a second string with the "garbage"
" part. Returns ['', fname] if no valid file can be found.
" EG: If a file exists in the path /tmp/foobar, then:
"
"   f(/tmp/foobar:garbageAfterTheEnd) -> [/tmp/foobar, :garbageAfterTheEnd]
"
function! BTN_GuessFname(fname)
    let suffix_pos = len(a:fname)
    let fname = a:fname

    " Tries trimming chars from fname til a valid fname is found
    while (len(fname) > 0) && !BTN_IsFnameValid(fname)
        let suffix_pos = suffix_pos - 1
        let fname = fname[0:suffix_pos]
    endwhile

    let suffix = a:fname[ suffix_pos+1 : ]
    return [fname, suffix]
endfunction


" Better Tab New: tries to guess which line the user wants, from the common
" formats: "+N", ":N" or plain "N". Formats like ":N:garbage" are also
" accepted. Everything after the (valid) number should be discarded. This
" makes BTN easy to use with, for example, the output of grep.
function! BTN_GuessLineNum(lineNum)
    let lineExpr = a:lineNum

    " If lineExpr is already a number, just return it as is
    if lineExpr != 0
        " The number-check will also be true for stuff like 42:garbage
        " so we'll hammer that stuff into an int when returning. Most times
        " this does what we want.
        return BTN_CoerceToLineNum(lineExpr)
    endif

    " lineExpr is not a number: trim whitespaces
    let lineExpr = substitute(a:lineNum, "^\\s\\+\\|\\s\\+$","","g")

    " Is lineExpr a number now?
    if lineExpr != 0
        " The number-check will also be true for stuff like 42:garbage
        " so we'll hammer that stuff into an int when returning. Most times
        " this does what we want.
        return BTN_CoerceToLineNum(lineExpr)
    endif

    " Is the expr prefixed by an accepted line-number start prefix?
    let BTN_accepted_lineNum_prefixes = ['+', ':']
    if index(BTN_accepted_lineNum_prefixes, lineExpr[0]) != -1
        " Found an accepted line number start prefix, remove it and see if
        " that's a valid line number
        return BTN_GuessLineNum( lineExpr[1:] )
    endif

    " Unknown line expresion, return 0
    return 0
endfunction



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Cleanup

let &cpo= s:keepcpo
unlet s:keepcpo

