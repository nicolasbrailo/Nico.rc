" Tab mover: moving tabs in gui mode doesn't always work, even if at all
" available. This script should make this functionality available for vanilla
" installs.


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Exit when already loaded or in compatible mode
if exists("g:loaded_TabMover") || &cp
  finish
endif
let g:loaded_TabMover = 1
let s:keepcpo = &cpo


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set mappings

" noremap <C-S-PageDown> :call MoveTab(2)<CR>
" noremap <C-S-PageUp>   :call MoveTab(-1)<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Impl


function! MoveTab(relOffset)
    let newPos = tabpagenr() - 1 + a:relOffset
    if newPos < 0
        let newPos = 0
    endif
    execute "tabmove" newPos
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Cleanup

let &cpo= s:keepcpo
unlet s:keepcpo

