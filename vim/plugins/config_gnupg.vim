" Custom config for gnupg.vim plugin

" Add to bashrc if GPG complains " GPG_TTY=`tty`
" Add to bashrc if GPG complains " export GPG_TTY
" Still not working? Maybe IDE has no key agent. Try gpg-connect-agent


let g:GPGPreferArmor=1
let g:GPGPreferSign=0
let g:GPGPreferSymmetric=1





" let g:GPGPreferArmor=1
" let g:GPGPreferSign=1
" let gpgLvl1 = {'ext': 'secure.pwd', 'key': 'nicolasbrailo+pwd+secure@gmail.com'}
" let gpgLvl2 = {'ext': 'general.pwd', 'key': 'nicolasbrailo+pwd+general@gmail.com'}
" let g:GPGFileDefaults = [gpgLvl1, gpgLvl2]
" "let g:GPGDebugLevel=99999
" "let g:GPGDebugLog='~/gpg.vim.log'
" 
" 
" function! GpgDecrypt()
"   let encFile = expand("%")
"   tabnew
"   setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
"   let verboseCmd = 'gpg --quiet --no-symkey-cache -d "' . encFile . '"'
"   execute '$read !' . verboseCmd
" endfunction
" 
" function! GpgEncrypt()
"   echo "HOLA"
" endfunction
" 
" 
" 
" 
" 
" if !exists("g:GPGFileDefaults")
"     echoerr "g:GPGFileDefaults not defined, gnupg.vim won't work"
" endif
" 
" " When using GPG_ClipboardCopyField, the clipboard will be wiped
" " $GPGClipboardWipeTimeout seconds after copying
" if !exists("g:GPGClipboardWipeTimeout")
"     let g:GPGClipboardWipeTimeout = 30
" endif
" 
" if !exists("g:GPGLoginToken_User")
"     let g:GPGLoginToken_User = "user: "
" endif
" 
" if !exists("g:GPGLoginToken_Pass")
"     let g:GPGLoginToken_Pass = "pass: "
" endif
" 
" function! GPG_BuildFileFilter(fileDefaults)
"     " Build a GPG file extension filter out of the GPGFileDefaults config
"     let filter = ''
"     let sep = ''
"     for cfg in a:fileDefaults
"         let filter = filter . sep . cfg.ext
"         let sep = '\|'
"     endfor
"     return '*.\(' . filter . '\)'
" endfunction
" 
" let g:GPGFilePattern = GPG_BuildFileFilter(g:GPGFileDefaults)
" 
" function! GPG_SetBufferOptions()
"     setlocal updatetime=30000 " 30 secs
"     setlocal foldmethod=marker
"     setlocal foldclose=all
"     setlocal foldopen=insert
"     setlocal foldminlines=0
" 
"     map <buffer> <leader>u :call GPG_ClipboardCopyField(g:GPGLoginToken_User)<CR>
"     map <buffer> <leader>p :call GPG_ClipboardCopyField(g:GPGLoginToken_Pass)<CR>
" 
"     highlight Folded guibg=gray20 guifg=linen
" 
"     " Make sure fold content is hidden, even if fold is a single line
"     function! PwdHideFoldText()
"         " Foldmarker is defined as $start_tok,$end_tok
"         let l:fold_start_tok = &foldmarker[0 : match(&foldmarker, ',')-1]
"         let l:first_ln = getline(v:foldstart)
"         let l:fold_start_pos = match(l:first_ln, l:fold_start_tok) - 1
"         return l:first_ln[0 : l:fold_start_pos]
"     endfunction
"     setlocal foldtext=PwdHideFoldText()
" 
"     " Set default destinatary for file type
"     for cfg in g:GPGFileDefaults
"         let curr_file = expand('%:t')
"         let ext_pos = match(curr_file, cfg.ext)
"         if len(cfg.ext) + ext_pos == len(curr_file)
"             let g:GPGDefaultRecipients=[cfg.key]
"         endif
"     endfor
" endfunction
" 
" function! GPG_GrepInFold(keyword)
"     for ln_num in range(v:foldstart, v:foldend)
"         let ln = getline(ln_num)
"         let kwrd_pos = match(ln, a:keyword)
"         if kwrd_pos != -1
"             return ln[kwrd_pos + len(a:keyword) : ]
"         endif
"     endfor
"     echo a:keyword . " not found in fold"
"     return ""
" endfunction
" 
" function! GPG_ClipboardCopyField(field_name)
"     function! GPG_ClipboardCleanTimeout(field_name, original_val, countdown, timerId)
"         " Cleans the clipboard after $countdown seconds
" 
"         if @+ != a:original_val
"             " Bail out if the clipboard changed (ie manually removed value)
"             echo ""
"             return
"         endif
" 
"         if a:countdown <= 0
"             let @+ = ""
"             echo ""
"         else
"             echo a:field_name." in clipboard. Wipe in " . a:countdown
"             call timer_start(1000, function('GPG_ClipboardCleanTimeout', [a:field_name, a:original_val, a:countdown-1]))
"         endif
"     endfunction
" 
"     let val = GPG_GrepInFold(a:field_name)
"     " If found, copy val to clipboard
"     if val != ""
"         let @+ = val
"         call GPG_ClipboardCleanTimeout(a:field_name, val, g:GPGClipboardWipeTimeout, 0)
"     endif
" endfunction
" 
" augroup GnuPGExtra
"     " Note: `autocmd EVENT $var ACTION` doesn't work, only 
"     " `autocmd EVENT PATTERN ACTION` works. Use exec to get around that
" 
"     " Set extra options for all files defined in $GPGFilePattern
"     execute "autocmd BufReadCmd,FileReadCmd " . g:GPGFilePattern . " call GPG_SetBufferOptions()"
"     " Close buffer after $updatetime
"     execute "autocmd CursorHold " . g:GPGFilePattern . " bd"
" augroup END
" 
" 
