" Custom config for gnupg.vim plugin

if !exists("g:GPGFileDefaults")
    echoerr "g:GPGFileDefaults not defined, gnupg.vim won't work"
endif

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

    highlight Folded guibg=gray20 guifg=linen

    " Make sure fold content is hidden, even if fold is a single line
    function! PwdHideFoldText()
        " Foldmarker is defined as $start_tok,$end_tok
        let l:fold_start_tok = &foldmarker[0 : match(&foldmarker, ',')-1]
        let l:first_ln = getline(v:foldstart)
        let l:fold_start_pos = match(l:first_ln, l:fold_start_tok) - 1
        return l:first_ln[0 : l:fold_start_pos]
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

