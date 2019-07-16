" Vim syntax file
" Language: Elvis file

" Quit when a syntax file was already loaded
if exists("b:current_syntax_elvis")
	finish
endif

let b:current_syntax_elvis = 1

syntax region hyperlink     start="\[\["       end="\]\]"       skip="\\[\[\]]" keepend conceal contains=hyperlinkURL,hyperlinkText,hyperlinkBracketsRight containedin=.*
syntax region hyperlinkURL  start="\[\["       end="\]\["me=e-2 skip="\\[\[\]]" contained keepend conceal
syntax region hyperlinkText start="\]\["ms=s+2 end="\]\]"me=e-2 skip="\\[\[\]]" contained keepend contains=hyperlinkTextQuote
syntax match hyperlinkTextQuote "\\\([\[\]]\)\@=" contained conceal

highlight default link hyperlinkText Underlined

"highlight default hyperlink     guifg=Blue  ctermfg=Blue
"highlight default hyperlinkURL  guifg=Green ctermfg=Green
"highlight default hyperlinkText guifg=Red   ctermfg=Red

"highlight default hyperlinkBracketsLeft   guifg=Yellow ctermfg=Yellow
"highlight default hhyperlinkBracketsRight guifg=Yellow ctermfg=Yellow

