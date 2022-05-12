" Python filetype plugin

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                      ______   _______ _   _  ___  _   _
"                     |  _ \ \ / /_   _| | | |/ _ \| \ | |
"                     | |_) \ V /  | | | |_| | | | |  \| |
"                     |  __/ | |   | | |  _  | |_| | |\  |
"                     |_|    |_|   |_| |_| |_|\___/|_| \_|
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
    finish
endif
let b:did_indent = 1

setl ts=4
setl sts=4
setl shiftwidth=4
setl indentexpr=GetPythonIndent(v:lnum)
setl indentkeys=!^F,o,O,<:>,0),0],0},=elif,=except
setl fdm=indent
setl cot-=preview

" Run Python script.
nn <F5> :w<CR>:!clear && python3 %<CR>
nn <Bslash><F5> :w<CR>:!clear && python3 -m pytest %<CR>
nn <Leader><F5> :w<CR>:!clear && rm -f flake8.txt && flake8 %<CR>

" Maximum width of text that is being inserted set to 79.
" The column 80 is highlighted.
setl tw=79

" Source: https://gist.github.com/romainl/eabe0fe8c564da1b6cfe1826e1482536
aug TooLong
    au!
    au WinEnter,BufEnter * cal clearmatches()
          \| cal matchadd('ColorColumn', '\%>79v', 100)
aug END

setl omnifunc=pythoncomplete#Complete
setl define=^\s*\\(def\\\\|class\\)

if exists("python_space_error_highlight")
  unlet python_space_error_highlight
end

" Five characters of punctuation for a damn string?
ino <buffer> <d-'> _(u'')<left><left>

let python_highlight_all = 1
syn keyword pythonDecorator True None False self

setl foldmethod=indent

ino <buffer> $r return
ino <buffer> $i import
ino <buffer> $p print
map <buffer> <leader>1 /class
map <buffer> <leader>2 /def
map <buffer> <leader>C ?class
map <buffer> <leader>D ?def


let s:maxoff = 50

" Find backwards the closest open parenthesis/bracket/brace.
fu! s:SearchParensPair()
    let line = line('.')
    let col = col('.')

    " Skip strings and comments and don't look too far
    let skip = "line('.') < " . (line - s:maxoff) . " ? dummy :" .
                \ 'synIDattr(synID(line("."), col("."), 0), "name") =~? ' .
                \ '"string\\|comment"'

    " Search for parentheses
    cal cursor(line, col)
    let parlnum = searchpair('(', '', ')', 'bW', skip)
    let parcol = col('.')

    " Search for brackets
    cal cursor(line, col)
    let par2lnum = searchpair('\[', '', '\]', 'bW', skip)
    let par2col = col('.')

    " Search for braces
    cal cursor(line, col)
    let par3lnum = searchpair('{', '', '}', 'bW', skip)
    let par3col = col('.')

    " Get the closest match
    if par2lnum > parlnum || (par2lnum == parlnum && par2col > parcol)
        let parlnum = par2lnum
        let parcol = par2col
    end
    if par3lnum > parlnum || (par3lnum == parlnum && par3col > parcol)
        let parlnum = par3lnum
        let parcol = par3col
    end

    " Put the cursor on the match
    if parlnum > 0
        cal cursor(parlnum, parcol)
    end
    retu parlnum
endf

" Find the start of a multi-line statement
fu! s:StatementStart(lnum)
    let lnum = a:lnum
    wh 1
        if getline(lnum - 1) =~ '\\$'
            let lnum = lnum - 1
        el
            cal cursor(lnum, 1)
            let maybe_lnum = s:SearchParensPair()
            if maybe_lnum < 1
                retu lnum
            el
                let lnum = maybe_lnum
            end
        end
    endw
endf

" Find the block starter that matches the current line
fu! s:BlockStarter(lnum, block_start_re)
    let lnum = a:lnum
    let maxindent = 10000       " whatever
    wh lnum > 1
        let lnum = prevnonblank(lnum - 1)
        if indent(lnum) < maxindent
            if getline(lnum) =~ a:block_start_re
                retu lnum
            el
                let maxindent = indent(lnum)
                " It's not worth going further if we reached the top level
                if maxindent == 0
                    retu -1
                end
            end
        end
    endw
    retu -1
endf

fu! GetPythonIndent(lnum)

    " First line has indent 0
    if a:lnum == 1
        retu 0
    end

    " If we can find an open parenthesis/bracket/brace, line up with it.
    cal cursor(a:lnum, 1)
    let parlnum = s:SearchParensPair()
    if parlnum > 0
        let parcol = col('.')
        let closing_paren = match(getline(a:lnum), '^\s*[])}]') != -1
        if match(getline(parlnum), '[([{]\s*$', parcol - 1) != -1
            if closing_paren
                retu indent(parlnum)
            else
                retu indent(parlnum) + &shiftwidth
            end
        el
            if closing_paren
                retu parcol - 1
            else
                retu parcol
            end
        end
    end

    " Examine this line
    let thisline = getline(a:lnum)
    let thisindent = indent(a:lnum)

    " If the line starts with 'elif' or 'else', line up with 'if' or 'elif'
    if thisline =~ '^\s*\(elif\|else\)\>'
        let bslnum = s:BlockStarter(a:lnum, '^\s*\(if\|elif\)\>')
        if bslnum > 0
            retu indent(bslnum)
        else
            retu -1
        end
    end

    " If the line starts with 'except' or 'finally', line up with 'try'
    " or 'except'
    if thisline =~ '^\s*\(except\|finally\)\>'
        let bslnum = s:BlockStarter(a:lnum, '^\s*\(try\|except\)\>')
        if bslnum > 0
            retu indent(bslnum)
        else
            retu -1
        end
    end

    " Examine previous line
    let plnum = a:lnum - 1
    let pline = getline(plnum)
    let sslnum = s:StatementStart(plnum)

    " If the previous line is blank, keep the same indentation
    if pline =~ '^\s*$'
        retu -1
    end

    " If this line is explicitly joined, try to find an indentation that looks
    " good.
    if pline =~ '\\$'
        let compound_statement = '^\s*\(if\|while\|for\s.*\sin\|except\)\s*'
        let maybe_indent = matchend(getline(sslnum), compound_statement)
        if maybe_indent != -1
            retu maybe_indent
        el
            retu indent(sslnum) + &sw * 2
        end
    end

    " If the previous line ended with a colon, indent relative to
    " statement start.
    if pline =~ ':\s*$'
        retu indent(sslnum) + &sw
    end

    " If the previous line was a stop-execution statement or a pass
    if getline(sslnum) =~ '^\s*\(break\|continue\|raise\|return\|pass\)\>'
        " See if the user has already dedented
        if indent(a:lnum) > indent(sslnum) - &sw
            " If not, recommend one dedent
            retu indent(sslnum) - &sw
        end
        " Otherwise, trust the user
        retu -1
    end

    " In all other cases, line up with the start of the previous statement.
    retu indent(sslnum)
endf

" Format paragraph (selected or not) to 80 character lines
nn fp gqap     :ec 'Format Paragraph Successfully !' <CR>
xn fp gqa<Esc> :ec 'Format Paragraph Successfully !' <CR>

" ------------------------------------------------------------------------------
" ABBREVIATIONS {{{
" ------------------------------------------------------------------------------

" ----------------------------------------------------------------------------
" General, common key bindings
" ----------------------------------------------------------------------------
ia cc #
ia tr True
ia fa False
ia """ """<CR><CR>"""<Esc>kh
ia var # Variable initialisation.<CR>
ia validanswers VALID_ANSWERS = ['y', 'yes', 'n', 'no']<CR>

" ----------------------------------------------------------------------------
" List all functions in current buffer
" ----------------------------------------------------------------------------
nn <Leader>lf :ilist def.*<CR>:

" ----------------------------------------------------------------------------
" Function docstring
" ----------------------------------------------------------------------------
ia df def :<CR>"""<CR><CR>Parameters<CR>----------<CR><CR><CR>Returns<CR>-------<CR><CR>"""<CR><CR><Esc>12kllli<Del>

" ----------------------------------------------------------------------------
" Section headings
" ----------------------------------------------------------------------------
ia -constant-  # ------------------------------- Named Constant ------------------------------<Esc>

ia -constants- # ------------------------------- Named Constants -----------------------------<Esc>

ia -global-    # ------------------------------ Global Constant ------------------------------<Esc>

ia -globals-   # ------------------------------ Global Constants -----------------------------<Esc>

ia -import-    # ------------------------------- Module Import -------------------------------<Esc>

ia -imports-   # ------------------------------- Module Imports ------------------------------<Esc>

ia -func-      # ---------------------------- Function Definition ----------------------------<Esc>

ia -funcs-     # ---------------------------- Function Definitions ---------------------------<esc>

ia -class-     # ------------------------------ Class Definition -----------------------------<Esc>

ia -classes-   # ------------------------------ Class Definitions ----------------------------<Esc>

ia -program-   # ---------------------------------- Program ----------------------------------<Esc>

ia -m-         # ------------------------------- Main Function -------------------------------<CR>def main():<Esc>

ia -main-      # --------------------------- Call the Main Function --------------------------<CR>if __name__ == '__main__':<CR>main()<Esc>

" }}}
