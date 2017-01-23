" Vim compiler file
" Language:		TSL
" Function:		Syntax check and/or error reporting
" Maintainer:		Huan Li <yrlihuan@gmail.com>
" ----------------------------------------------------------------------------

if exists("current_compiler")
  finish
endif
let current_compiler = "tsl"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo-=C

" default settings runs script normally
" add '-c' switch to run syntax check only:
"
"   CompilerSet makeprg=ruby\ -wc\ $*
"
" or add '-c' at :make command line:
"
"   :make -c %<CR>
"
CompilerSet makeprg=tsl.exe\ %\ \\\|\ c:\\python27\\python.exe\ c:\\alpha\\scripts\\rewrite_tsl_msg.py
CompilerSet errorformat=%l:%m

"CompilerSet errorformat="%*[^:]:%f:%*[^:]%l%*[^:]"
"CompilerSet errorformat=%*[^:]:reviewshelper:%s:%*[^0-9:]%l%*[^0-9:]:%m

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: nowrap sw=2 sts=2 ts=8:
