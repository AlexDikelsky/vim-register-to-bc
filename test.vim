"let str = "echo 'words'\necho 'abc'"
"let str = substitute (str, "[\n|;]", "|", "g")
"
"execute(str)

"Replace all things that are like some_fun_not_in_this_list( 
"Hopefully this prevents accidental execution of dangerous code

    "First idea
"Count the open parens in the expression
"for each paren: 
    "Check if there is a legal function name before it
	"If there is, read that function name
	    "If the function name is legal
		"do nothing
	    "else
	    	"remove the function name.
		"   #This might be a bad move, maybe deleting
		"   #until the matching paren would be better

    "Better
"use a regex to match anything that looks like a function
"   Then check if the matched string is in the list
"
"   f(x)
"   fghi (x)
"   sdf () sdf() other()
"   g2(x)
"   h2 (x)
"   h 2 (x)
    "   \zs[a-zA-Z]\+\ze\s*(
"     looks okay. One problem is that functions like log10(x) won't be
"     recognized. There's only 2 though, and both (log10(x) and atan2(x)) 
"     can be made through other function. This also dosn't match stuff with
"     dots or underscores, but none of the functions in the math section use
"     those anyway. Also, if you have a dangerous function that ends with
"     a valid function, it will not be removed

"let b = match(a, "a")
"let c = matchend(a, "c") - 1
function! s:get_matches(str, regex)  
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

    let l:final_str = ""
    let l:writable = a:str

    let l:start = match(a:str, a:regex, l:i)
    let l:end = matchend(a:str, a:regex, l:i)
    let l:length = len(a:str)
    while (l:i < l:length) && (l:start !=# -1)
	echo l:writable
	echo l:writable
        if index(l:legal_commands, l:writable[l:start : l:end -1]) ==# -1
	    "If there is a function, but it's not a legal command, remove it
	    "from the string
            let l:writable = l:writable[:l:start -1] . l:writable[l:end:]

	    "Move the start position to the end, then fix the index
	    let l:i = l:end 
            let l:i -= abs(l:length - len(l:writable))
            let l:length = len(l:writable)
	else
	    "don't delete the thing and continue to the next word
	    let l:i = l:end
        endif
	echo l:writable
            
	"get new values. Theres probably a great way to do this with recursion
        let l:length = len(l:writable)
        let l:start = match(l:writable, a:regex, l:i)
        let l:end = matchend(l:writable, a:regex, l:i)
    endwhile
    return l:writable
endfunction

let b:re  = '\zs[a-zA-Z]\+\ze\s*('
let b:testlist = [
	    \"asdf(3)"]

for b:x in b:testlist
    echo s:get_matches(b:x, b:re)
endfor
