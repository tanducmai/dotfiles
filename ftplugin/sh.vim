" Shell filetype plugin

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                         ____  _   _ _____ _     _
"                        / ___|| | | | ____| |   | |
"                        \___ \| |_| |  _| | |   | |
"                         ___) |  _  | |___| |___| |___
"                        |____/|_| |_|_____|_____|_____|
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

setl ts=2
setl sts=2
setl shiftwidth=2

" Maximum width of text that is being inserted set to 88.
" The column 89 is highlighted.
setl tw=88

" Source: https://gist.github.com/romainl/eabe0fe8c564da1b6cfe1826e1482536
aug TooLong
    au!
    au WinEnter,BufEnter * cal clearmatches()
          \| cal matchadd('ColorColumn', '\%>88v', 100)
aug END

" Seamlessly treat visual lines as actual lines when moving around.
nn j gj
nn k gk
