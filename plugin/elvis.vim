if exists('g:loaded_elvis_plugin')
	finish
endif
let g:loaded_elvis_plugin = 1

function! s:Init()
	silent execute("runtime syntax/elvis.vim")
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
			if line[1:c-1] =~ '://'
				let ret.protocol = substitute(line[1:c-1], "://.*", "", "")
			endif
			let ret.target = substitute(line[1:c-1], "^.*://", "", "")
			let ret.text   = line[c+2:-2]
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
		let out = systemlist(link.target)

		let i = 0
		while out[i] =~ '^elvis:'
			silent execute(out[i][6:])
			let i = i + 1
		endwhile
		let out = out[i:]

		silent execute(":setlocal buftype=nofile")
		silent execute(":setlocal bufhidden=delete")
		silent execute(":setlocal noswapfile")
		silent execute("1,$d")

		let i = 0
		for line in out
			silent execute(":". i . "put =line")
			let i = i + 1
		endfor

		if link.text != ""
			silent execute(":f -/" . link.text)
		endif
		call <SID>Init()
		return
	endif

	if link.protocol == "open"
		let filename = substitute(link.target, "#[^#]*$", "", "")
		let lineno = substitute(link.target, "^.*#", "", "")
		let cmd = ":tabedit"
		if lineno != link.target
			let cmd .= " +:" . str2nr(lineno)
		endif
		let cmd .= " " . fnameescape(filename)
		silent execute(cmd)
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
