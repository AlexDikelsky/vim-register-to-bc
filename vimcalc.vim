"" calculate expression entered on command line and give answer, e.g.:
" :Calculate sin (3) + sin (4) ^ 2
command! -nargs=+ Calculate echo "<args> = " . Calculate ("<args>")

"" calculate expression from visual selection
vnoremap <leader>ca "ey:call CalcLines(1)<cr>

"" calculate expression in the current unnamed register
noremap  <leader>ca "eyy:call CalcLines(0)<cr>

" ---------------------------------------------------------------------
"  Calculate:
"    clean up an expression, pass it to bc, return answer
function! Calculate (input_str)

	let l:str= a:input_str


	" remove newlines
	let l:str= substitute (l:str, "[\n|;]", "|", "g")

	" alternate exponentiation symbols
	let l:str = substitute (l:str, '\*\*', '^', "g")

	" Only allow these commands. I'm doing this
	" so if you accidently type ca on a dangerous line
	" it won't do anything dangerous
	let l:str = s:delete_illegal_functions(l:str)

	" Substitute superscript characters like ² to become ^(²)
	    "First put them in parenthesis and add a carrot
	    let l:str = substitute(l:str, "[⁰¹²³⁴⁵⁶⁷⁸⁹]\\+", "^(&)", "g")

	
	    "This changes all numbers like ² to 2
	    "First, it changes the string to a list of characters
	    "Next it maps 2 to ², and so on for all the numbers
	    "Finally it joins all of the returned characters
	    let l:str = join(map(split(l:str, '\zs'), 'FromSuperToNormal(v:val)'), "")

	    "next remove the ^ and change it to pow(base, exponent)
	    let l:str = 

	" escape chars for shell
	let l:str = escape (l:str, '*();&><|')

	let l:preload = exists ("g:bccalc_preload") ? g:bccalc_preload : ""

	" run bc
	let l:answer = system ("echo " . l:str . " \| bc -l " . l:preload)

	" strip newline
	let l:answer = substitute (l:answer, "\n", "", "")

	" strip trailing 0s in decimals
	let l:answer = substitute (l:answer, '\.\(\d*[1-9]\)0\+', '.\1', "")

	return l:answer
endfunction

function! FromSuperToNormal(char)  "{{{
    "Have to use a list rather than a string because you're 
    "not using ascii characters
    let l:super = split("⁰¹²³⁴⁵⁶⁷⁸⁹", '\zs')    
    let l:location = match(l:super, a:char)  

    if l:location ==# -1
	return a:char
    elseif a:char ==# '^'  
	"The ^ character is interprated as the anchor regex, so you have to manually
	"do this or else l:location becomes 0. You might run into other problems,
	"but multiplication and addition seem fine. 
	return '^'
    else
	return l:location
	"You can just return location here because the 0th index is ⁰, the
	"1st is ¹, and so on
    endif
endfunction "}}}

" ---------------------------------------------------------------------
" CalcLines:
"
" take expression from lines, either visually selected or the current line, as
" passed determined by arg vsl
function! CalcLines()

	" replace newlines with semicolons and remove trailing spaces
	let @e = substitute (@e, "\n", ";", "g")
	let @e = substitute (@e, '\s*$', "", "g")

	let l:answer = Calculate (@e)

	" append answer or echo
	echo "answer = " . l:answer
	call setreg('"', l:answer)
endfunction

function! s:delete_illegal_functions(str)    "{{{
    "Takes string, then returns a list with illegal commands removed
    "This can run into problems if the string starts with an illegal command,
    "or the command is one letter because vim slice expressions can be weird.
    "legal commands{{{
    let l:legal_commands = [ 
     	\ "abs",
     	\ "acos",
     	\ "asin",
     	\ "atan",
     	\ "atan2",
     	\ "ceil",
     	\ "cos",
     	\ "cosh",
     	\ "exp",
     	\ "floor",
     	\ "fmod",
     	\ "log",
     	\ "log10",
     	\ "max",
     	\ "min",
     	\ "pow",
     	\ "round",
     	\ "sin",
     	\ "sinh",
     	\ "sqrt",
     	\ "tan",
     	\ "tanh",
        \ ] 
    "}}}
    let l:i = 0
    let l:re  = '\zs[a-zA-Z0-9]\+\ze\s*('

    let l:final_str = ""
    let l:writable = a:str

    let l:start = match(a:str, a:regex, l:i)
    let l:end = matchend(a:str, a:regex, l:i)
    let l:length = len(a:str)
    while (l:i < l:length) && (l:start !=# -1)
        if index(l:legal_commands, l:writable[l:start : l:end -1]) ==# -1
	    "If there is a function, but it's not a legal command, remove it
	    "from the string
	    echo "unrecognized function, recheck input line"
            let l:writable = l:writable[ : s:if_neg_be_zero(l:start -1)] . l:writable[l:end:]
	    
	    "This will leave a single character if you have a range like [0:0]
	    "but you probably didn't mean to execute that command anyway, and 
	    "hopefully you don't have particularly dangerous single letter
	    "commands

	    "Move the start position to the end, then fix the index
	    let l:i = l:end 
            let l:i -= abs(l:length - len(l:writable))
            let l:length = len(l:writable)
	else
	    "don't delete the thing and continue to the next word
	    let l:i = l:end
        endif
            
	"get new values. Theres probably a great way to do this with recursion
        let l:length = len(l:writable)
        let l:start = match(l:writable, a:regex, l:i)
        let l:end = matchend(l:writable, a:regex, l:i)
    endwhile
    return l:writable
endfunction "}}}

function! s:if_neg_be_zero(x)
    "This is defined because if you take a range that
    "starts with -1, it startes at the wrong index
    if a:x < 0 
	return 0
    else
	return a:x
    endif
endfunction

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


