" Impl Switcher: switches between implementation and header files (for
" example, between .h and .cpp files).
"
" Note: only compatible with Linux systems that have the following programs
" available: dirname, find


"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Exit when already loaded in compatible mode
if exists("g:loaded_ImplSwitcher") || &cp
  "finish " TODO: for development
endif
let g:loaded_ImplSwitcher = 1
let s:keepcpo = &cpo



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Configuration

" Alt-extensions configuration: the alternative extensions are found via an
" intermediate index. For example, if we have "example.h" and the following
" configuration:
"
" g:knownExtensions  = ['h', 'c', 'hpp', 'cpp']
" g:alternativeIndex = [1, 0, 3, 2]
" g:alternativeExtensions = [
"               \   ['h'],
"               \   ['c'],
"               \   ['h', 'hpp'],
"               \   ['cpp', 'cxx'],
"           \]
"
" Then:
" 1. example.h has extension "h"
" 2. extension "h" has index 2 in g:knownExtensions
" 3. Index 2 in g:alternativeIndex has number 3
" 4. Index 3 in g:alternativeExtensions has list ['3']
" 5. Possible alt files are "example.cpp" and "example.cxx"

" The file types known by this plugin
if !exists("g:ImplSwitcher_knownExtensions")
    let g:ImplSwitcher_knownExtensions = ['c', 'cpp', 'cxx', 'cc', 'h', 'hpp']
endif

" Each known file type has a list of possible impl files, for example 
" 'cpp' -> ['h', 'hpp']. These indexes should map a known extension
" to an position in g:alternativeExtensions, which contains the alt flies
if !exists("g:ImplSwitcher_alternativeIndex")
    let g:ImplSwitcher_alternativeIndex = [  1,     1,     1,   1,   0,      0]
endif

" Alternative extensions: a list of possible extensions that are the
" alternative for the knownExtensions
if !exists("g:ImplSwitcher_alternativeExtensions")
    let g:ImplSwitcher_alternativeExtensions = [
                \   ['c', 'cpp', 'cxx', 'cc'],
                \   ['h', 'hpp']
                \]
endif

" Set to 1 to get a verbose description of the lookup process
let g:ImplSwitcher_debugMode = 0

" The maximum number of directories up to look for. For example, for file
" a/b/c/d/e.file, and a searchMaxDirUps=3 will look into a/b/c/d, /a/b/c and
" /a/b will be the last directory to be searched
if !exists("g:ImplSwitcher_searchMaxDirUps")
    let g:ImplSwitcher_searchMaxDirUps = 3
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set mappings

noremap <F4> :call OpenCurrentImplFile()<cr>
noremap <leader>h :call OpenCurrentImplFile()<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Impl

" Creates a new tab with the alt-file for the current buffer
function! ImplSwitcher_OpenCurrentImplFile()
    let alt_file = FindAlternativeFiles(expand('%:p'))
    if alt_file == ''
        echo 'No alternative file found for ' . expand('%:p')
    else
        execute 'tabnew '.alt_file
    endif
endfunction


" Given a file path, it will try to locate an alt-file by looking in the
" file's path, or in its parent directory, til the file is found or the
" directory is not valid anymore
function! FindAlternativeFiles(fpath)
    let [cwd, fname] = SplitDirname(a:fpath)
    let alt_fnames = GetAlternativeFileNames(fname)

    let dir_up_count = 0
    while CwdValidForAltSearch(cwd, dir_up_count)
        let alt_file_path = IsAltFileInDir(cwd, alt_fnames)
        if alt_file_path != ''
            return alt_file_path
        else
            let cwd = OneDirUp(cwd)
            let dir_up_count = dir_up_count + 1
        endif
    endwhile

    return ''
endfunction


" Checks if a path is still valid for alt-files lookup
" @param path the path to check if is still valid
" @param dir_up_count the number of times a dir-up has been done
function! CwdValidForAltSearch(path, dir_up_count)
    if g:ImplSwitcher_debugMode
        echo 'Checking if '.a:path.' is a valid lookup directory'
    endif

    if a:dir_up_count >= g:ImplSwitcher_searchMaxDirUps
        if g:ImplSwitcher_debugMode
            echo "  It's not, we've already looked ".a:dir_up_count." dirs up."
        endif
        return 0
    endif

    if len(a:path) == 0
        if g:ImplSwitcher_debugMode
            echo "  It's not, looks empty"
        endif
        return 0
    endif

    if a:path == glob('~')
        if g:ImplSwitcher_debugMode
            echo "  It's not, looks like the home directory"
        endif
        return 0
    endif

    if g:ImplSwitcher_debugMode
        echo "  It is"
    endif
    return 1
endfunction

" Verifies if any of the files specified in alt_files are currently in path
" @param alt_files A list of possible alt-file names
" @param path the path to look into
" Returns the complete file path, if any is found, or an empty string if no
"         alt file is found
function! IsAltFileInDir(path, alt_files)
    for alt_file in a:alt_files
        if g:ImplSwitcher_debugMode
            echo "Looking for ".alt_file." in ".a:path
        endif

        let alt_file_path = system("find ".a:path." -type f -iname '".alt_file."'")
        if len(alt_file_path) > 0
            if g:ImplSwitcher_debugMode
                echo "Found ".alt_file_path
            endif
            return alt_file_path
        endif
    endfor

    if g:ImplSwitcher_debugMode
        echo "Nothing found in ".a:path
    endif
    return ""
endfunction



function! SplitDirname(fpath)
    let dir = system('dirname ' . a:fpath)
    " Remove whitespaces
    let dir = substitute(dir, "\\n\\+","","g") 
    let dir = substitute(dir, "\\r\\+","","g") 
    let dir = substitute(dir, "^\\s\\+\\|\\s\\+$","","g") 

    if v:shell_error != 0
        " TODO?
    endif

    if dir == '.'
        return ['', a:fpath]
    endif

    return [ dir, a:fpath[ len(dir)+1 : len(a:fpath) ] ]
endfunction

function! OneDirUp(path)
    " SplitDirname will behave just as dirname, so for 'foo/bar/' we'll get
    " back 'foo'
    let [new_dir, old_dir] = SplitDirname(a:path)
    return new_dir
endfunction


function! SplitExtension(fname)
    let pos = len(a:fname)
    while pos > 0 && a:fname[pos] != '.'
        let pos = pos - 1
    endwhile

    let ext = a:fname[ pos+1 : len(a:fname) ]
    let name = a:fname[ 0 : pos-1 ]
    return [name, ext]
endfunction

function! GetAlternativeExtensionsFor(extension)
    let ext_idx = index(g:ImplSwitcher_knownExtensions, a:extension)

    if g:ImplSwitcher_debugMode
        for ext in g:ImplSwitcher_knownExtensions
            echo 'Known extension: ' . ext
        endfor
        echo 'Extension '.a:extension.' (index '.ext_idx.') detected.'
    endif

    if ext_idx == -1
        return []
    endif

    let alt_idx = g:ImplSwitcher_alternativeIndex[ext_idx]

    if g:ImplSwitcher_debugMode
        echo 'Alternatives for ' . a:extension . ':'
        for alt in g:ImplSwitcher_alternativeExtensions[alt_idx]
            echo '  '.alt
        endfor
    endif

    return g:ImplSwitcher_alternativeExtensions[alt_idx]
endfunction

function! GetAltFileNames(name, extensions)
    let alt_names = []
    for ext in a:extensions
        let alt_name = a:name . '.' . ext
        call add(alt_names, alt_name)
    endfor
    return alt_names
endfunction

function! GetAlternativeFileNames(fname)
    if g:ImplSwitcher_debugMode
        echo "Looking alt files for " . a:fname
    endif

    let [name, ext] = SplitExtension(a:fname)
    let alt_exts = GetAlternativeExtensionsFor(ext)
    let alt_names = GetAltFileNames(tolower(name), alt_exts)

    if g:ImplSwitcher_debugMode
        echo "Possible alt names for " . a:fname . ":"
        for alt_name in alt_names
            echo "  " . alt_name
        endfor
    endif

    return alt_names
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Cleanup

let &cpo= s:keepcpo
unlet s:keepcpo


