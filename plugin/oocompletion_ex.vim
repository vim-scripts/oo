"
"
"this script is used for Java code complete.
"1. generate the tags
"
"
" Commmands {{{1
" call this command to generate the correct tag file.
" this command will ALWAYS generate the tag file, even if it's
" not necessary (if the tags are up-to-date)
command! -nargs=0 GenerateTags call s:GenerateTags()

" list the possible functions for the identifier under the cursor.
" it will first quickly display its class.
" Functions {{{1

function! s:GenerateTags() " {{{2
	silent! call system("ctags --file-scope=no -R --fields=+ia *")
endfunction


function! s:GettypeName(var) " {{{2
    let l:firsttime = 0
    let l:firstpos = 0
    let l:oldl= line('.')
    let l:oldc= col('.')
    let l:pattern = "\\<\\i\\+\\>[\\[\\]\\t\\* ]\\+\\<".a:var."\\>"
    let l:ldefine=search(l:pattern,"b")
    while l:ldefine > 0 
        let l:curr_line = getline(l:ldefine)
        let l:col_index = match(l:curr_line,l:pattern)
        if synIDattr(synID(l:ldefine,l:col_index,1),"name") == ""
            "let l:ldefine=search("\\<\\i\\+\\>\\s\\+\\<".a:var."\\>","nb")
            call cursor(l:oldl,l:oldc)
            return matchstr(l:curr_line,"\\<\\i\\+\\>",l:col_index)
        else
            if ( l:firsttime == 0 )
                let l:firsttime = 1
                let l:firstpos = l:ldefine
            else
                if ( l:firstpos == l:ldefine)
                    call cursor(l:oldl,l:oldc)
                    return ""
                endif
            endif
            let l:ldefine=search(l:pattern,"b")
            "cursor(l:oldl,l:oldc)
            "return ""
        endif
    endw
"    let l:ldefine=search("\\<\\i\\+\\>\\s\\+\\<".a:var."\\>","n")
"    if l:ldefine > 0
"        let l:curr_line = getline(l:ldefine)
"        let l:col_index = match(l:curr_line,"\\<\\i\\+\\>\\s\\+\\<".a:var."\\>")
"        "echo l:ldefine." ".l:col_index
"        echo synIDattr(synID(l:ldefine,l:col_index,1),"name")
"        if matchend(synIDattr(synID(l:ldefine,l:col_index,1),"name"),"Comment")==-1
"            "let l:ldefine=search("\\<\\i\\+\\>\\s\\+\\<".a:var."\\>","n")
"            return matchstr(l:curr_line,"\\<\\i\\+\\>",l:col_index)
"        else
"            return ""
"        endif
"    endif
    call cursor(l:oldl,l:oldc)
    return ""
endf 
function! Oocompletefun(line,base,col,findstart) " {{{2
    "let var = matchstr(a:line,"\\w\\+$")
    "echo 'line'.a:line."|base".a:base."|col".a:col."\n"

    "let l:langmode=0
    let s:str = a:line 
    let s:beginning = a:base
    "matchstr(a:line.a:base,"\\w\\+\\.\\w*$")
    "
    "if s:str == ""
    "    let s:str =matchstr(a:line.a:base,"\\w\\+->\\w*$") 
    "    let l:langmode=1
    "endif

    let l:var = substitute(s:str,"^\\s*\\(\\i\\+\\)\\(\\.\\|::\\|->\\)","\\1","")
    if l:var=="this"
        let l:ldefine = search("^\\(\\<\\i\\+\\>\\s\\+\\)*\\<class\\>\\s\\+\\<\\i\\+\\>","nb")
        if l:ldefine >0
            let l:tmp= getline(l:ldefine) 
            let l:index_def = match(l:tmp,"\\<class\\>")
            let l:index_def = match(l:tmp,"\\<\\i\\+\\>",l:index_def+6)
            let s:type=matchstr(l:tmp,"\\<\\i\\+\\>",l:index_def)
        endif
    else
        if match(s:str,"::$")!= -1
            let s:type = l:var
        else
            let s:type = s:GettypeName(l:var)
        endif
    endif
    let s:pre_beginning = "" 
    "strpart(a:line."|".a:base,0,strlen(a:line.a:base)-strlen(s:beginning)+1)


    if ( s:type == "" ) 
        "return l:var
        let s:type=l:var
    endif
    if (s:beginning == "")
        "
    endif
    let s:retstr=""
    if a:findstart
		    " locate start column of word
		    let start = a:col
		    while start > 0 && a:line[start - 1] =~ '\a'
		      let start = start - 1
		    endwhile
		    return start
    endif
ruby<<EOF
# this file separator API is badly broken
# or I missed something..

# puts "ruby invoked : " + Time.now.min.to_s + ":"+ Time.now.sec.to_s
$keepAllInfo = false 
taglist = TagList.new(VIM::evaluate("&tags"))
taglist.listMethods(VIM::evaluate("s:type"), VIM::evaluate("s:beginning"),1)
str = taglist.methodsToLine()
#taglist.putsMethods()
VIM::command("let s:retstr=\""+str+"\"");
EOF
return s:retstr
endf

function! s:Oocomplete(type,beginning)
ruby <<EOF
$keepAllInfo = false 
taglist = TagList.new(VIM::evaluate("&tags"))
taglist.listMethods(VIM::evaluate("a:type"), VIM::evaluate("a:beginning"),1)
#str = taglist.methodsToLine()
taglist.putsMethods()
EOF
endf

"command setup {{{2
rubyf $VIM/vimfiles/plugin/oocompletion.rb
command! -nargs=+ Oofun call <SID>Oocomplete(<f-args>)
command! -nargs=1 Ootype echo s:GettypeName(<f-args>)  
" ======================================================================
" vim600: set fdm=marker:
"
