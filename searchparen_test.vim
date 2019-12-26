function! s:find_match_from_end(str, start_paren_index)
    let l:found_right = 1 
    let l:i = a:start_paren_index -1

    while l:found_right !=# 0 && l:i >= 0
	if a:str[l:i] ==# ')'
	    let l:found_right += 1
	endif
	if a:str[l:i] ==# '('
	    let l:found_right -= 1
	endif
	
	let l:i -= 1
    endwhile
    return l:i + 1
endfunction

let a = "a()bcd(fasf)"
let n = 2

"this will be weird when the parens are stuff like 
"   3)(^3

echo s:find_match_from_end(a, match(a, ')', 0, n)) . "should be" . match(a, '(', 0, n)



