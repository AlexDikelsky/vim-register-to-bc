function! s:find_match_from_end(str, start_paren_index)
    let l:found_right = 1 
    let l:i = a:start_paren_index 

    while l:found_right !=# 0 && l:i >= 0
	let l:i -= 1
	if a:str[l:i] ==# ')'
	    let l:found_right += 1
	endif
	if a:str[l:i] ==# '('
	    let l:found_right -= 1
	endif
    endwhile
    return l:i
endfunction

"let a = "a()bcd(fa()s()f)"
"	"0123456789012345
"
"echo s:find_match_from_end(a, 15)
