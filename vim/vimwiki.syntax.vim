if !exists("b:current_syntax") || (b:current_syntax!="vimwiki")
    finish
endif

" cterm modifiers:
" bold
" underline
" reverse
" italic
" none
" 
" *cterm-colors*
" 
" NR-16   NR-8    COLOR NAME
" 0       0       Black
" 1       4       DarkBlue
" 2       2       DarkGreen
" 3       6       DarkCyan
" 4       1       DarkRed
" 5       5       DarkMagenta
" 6       3       Brown, DarkYellow
" 7       7       LightGray, LightGrey, Gray, Grey
" 8       0*      DarkGray, DarkGrey
" 9       4*      Blue, LightBlue
" 10      2*      Green, LightGreen
" 11      6*      Cyan, LightCyan
" 12      1*      Red, LightRed
" 13      5*      Magenta, LightMagenta
" 14      3*      Yellow, LightYellow
" 15      7*      White

syn region vimwikiTODO start="{TODO " end="}"
highlight vimwikiTODO cterm=bold,underline ctermbg=DarkBlue ctermfg=DarkRed

syn region vimwikiHeader1 start="\n= " end=" =\n"
highlight vimwikiHeader1 cterm=underline ctermbg=Black ctermfg=Green
syn region vimwikiHeader2 start="\n== " end=" ==\n"
highlight vimwikiHeader2 cterm=underline ctermbg=Black ctermfg=Cyan
syn region vimwikiHeader3 start="\n=== " end=" ===\n"
highlight vimwikiHeader3 cterm=underline ctermbg=Black ctermfg=Yellow

