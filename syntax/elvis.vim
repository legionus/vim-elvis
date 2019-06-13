" Vim syntax file
" Language: Elvis file

" Quit when a syntax file was already loaded
if exists("b:current_syntax_elvis")
	finish
endif

let b:current_syntax_elvis = 1

syntax match hyperlink "\[\{2}[^][]*\(\]\[[^][]*\)\?\]\{2}" contains=hyperlinkBracketsLeft,hyperlinkURL,hyperlinkBracketsRight containedin=.*
syntax match hyperlinkBracketsLeft      contained "\[\{2}#\?"  conceal
syntax match hyperlinkURL               contained "[^][]*\]\[" conceal
syntax match hyperlinkBracketsRight     contained "\]\{2}"     conceal
highlight default link hyperlink Underlined

