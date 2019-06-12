if exists('g:loaded_elvis_plugin')
	finish
endif
let g:loaded_elvis_plugin = 1

function! s:Init()
	if exists('b:initialized_elvis')
		return
	endif
	let b:initialized_elvis = 1

	syntax match hyperlink "\[\{2}[^][]*\(\]\[[^][]*\)\?\]\{2}" contains=hyperlinkBracketsLeft,hyperlinkURL,hyperlinkBracketsRight containedin=ALL
	syntax match hyperlinkBracketsLeft      contained "\[\{2}#\?"  conceal
	syntax match hyperlinkURL               contained "[^][]*\]\[" conceal
	syntax match hyperlinkBracketsRight     contained "\]\{2}"     conceal
	hi def link hyperlink Underlined
endfunction

function! s:FindLink()
	let line = getline('.')
	let curpos = col('.')

	let ret = { 'protocol': "", 'target': "", 'text': "" }
	let pos = [0, 0]

	let c = curpos
	while c > 0
		if line[c-1:c] == ']]'
			return ret
		endif
		if line[c-1:c] == '[['
			let pos[0] = c
			break
		endif
		let c -= 1
	endwhile

	let c = curpos
	while c < strlen(line)
		if line[c:c+1] == '[['
			return ret
		endif
		if line[c:c+1] == ']]'
			let pos[1] = c
			break
		endif
		let c += 1
	endwhile

	if pos == [0, 0]
		return ret
	endif

	let line = line[pos[0]:pos[1]]

	let c = 0
	while c < strlen(line)
		if line[c:c+1] == ']['
			let ret.protocol = substitute(line[1:c-1], "://.*", "", "")
			let ret.target   = substitute(line[1:c-1], "^.*://", "", "")
			let ret.text     = line[c+2:-2]
			break
		endif
		let c += 1
	endwhile

	return ret
endfunction

function! s:EvalLink()
	let link = s:FindLink()
	if link.protocol == '' && link.target == '' && link.text == ''
		echo("not a link")
		return
	endif

	if link.protocol == "exec"
		silent execute("1,$d")
		silent execute(".!" . link.target)
		if link.text != ""
			silent execute(":f " . link.text)
		endif
		return
	endif

	if link.protocol == "open"
		let filename = substitute(link.target, "#[^#]*$", "", "")
		let lineno = substitute(link.target, "^.*#", "", "")
		silent tabnew
		silent execute("open " . fnameescape(filename))
		if lineno != link.target
			silent execute(":" . str2nr(lineno))
		endif
		call <SID>Init()
		return
	endif

	if link.protocol == "vim"
		execute(link.target)
		return
	endif

	echo(link)
endfunction

command! -range=% Elvis     call <SID>Init()
command! -range=% ElvisEval call <SID>EvalLink()

nmap <silent> <C-r> :ElvisEval<CR>
