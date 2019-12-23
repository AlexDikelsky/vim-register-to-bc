let g:RegForBCSolving = "z"
function! ReplaceSuperscriptsFromChosenRegister()
    "Matches any number of ⁰¹²³⁴⁵⁶⁷⁸⁹
    "characters, then replaces them with ^(0123456789)
    "Examples: 
    "	3³     -> 3^(3)
    "   3¹⁰    -> 3^(10)
    "   e^(2⁸) -> e^(2^(8))
    "
    let input_expression = g:RegForBCSolving

    let l:added_carrots = substitute(a:input_expression, "[⁰¹²³⁴⁵⁶⁷⁸⁹]\\+", "^(&)", "g")
    "let l:bc_readable = substitute(l:added_carrots, "\\([⁰¹²³⁴⁵⁶⁷⁸⁹]\\)", "\\=FromSuperToNormal(\"\\1\")", "g")
    let l:bc_readable = substitute(l:added_carrots, "⁰", 0, "g")
    let l:bc_readable = substitute(l:bc_readable, "¹", 1, "g")
    let l:bc_readable = substitute(l:bc_readable, "²", 2, "g")
    let l:bc_readable = substitute(l:bc_readable, "³", 3, "g")
    let l:bc_readable = substitute(l:bc_readable, "⁴", 4, "g")
    let l:bc_readable = substitute(l:bc_readable, "⁵", 5, "g")
    let l:bc_readable = substitute(l:bc_readable, "⁶", 6, "g")
    let l:bc_readable = substitute(l:bc_readable, "⁷", 7, "g")
    let l:bc_readable = substitute(l:bc_readable, "⁸", 8, "g")
    let l:bc_readable = substitute(l:bc_readable, "⁹", 9, "g")
    let l:bc_readable = substitute(l:bc_readable, "\\n", ";", "g")
    return l:bc_readable
endfunction

"function! FromSuperToNormal(char)  "{{{
"    if a:char ==# "⁰"
"	return "0"
"    elseif a:char ==# "¹"
"	return "1"
"    elseif a:char ==# "²"
"	return "2"
"    elseif a:char ==# "³"
"	return "3"
"    elseif a:char ==# "⁴"
"	return "4"
"    elseif a:char ==# "⁵"
"	return "5"
"    elseif a:char ==# "⁶"
"	return "6"
"    elseif a:char ==# "⁷"
"	return "7"
"    elseif a:char ==# "⁸"
"	return "8"
"    elseif a:char ==# "⁹"
"	return "9"
"    else
"	return a:char  "This is if its not in the range
"endfunction "}}}

echom ReplaceSuperscripts("a")
echom ReplaceSuperscripts("³")
echom ReplaceSuperscripts("2^²")
echom ReplaceSuperscripts("3³")
echom ReplaceSuperscripts("3¹³")
echom ReplaceSuperscripts("3¹³ + 2²")
echom ReplaceSuperscripts("e^(2⁸)")

echom ReplaceSuperscripts("
	    \ 3³     -> 3^(3)
	    \ 3¹⁰    -> 3^(10)
	    \ e^(2⁸) -> e^(2^(8))
	    \ ")

echom ReplaceSuperscripts(getreg('z'))

nnoremap <leader>bc :!bc -l < call ReplaceSuperscripts("<c-r>z")
