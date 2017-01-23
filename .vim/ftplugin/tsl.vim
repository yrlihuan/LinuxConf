" Vim filetype plugin file
" Language:	tsl
" Maintainer:	Huan Li <yrlihuan@gmail.com>

if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1

" Make sure the continuation lines below do not cause problems in
" compatibility mode.
let s:save_cpo = &cpo
set cpo-=C

setlocal commentstring={%s}
setlocal comments=://

" Undo the stuff we changed.
let b:undo_ftplugin = "setlocal commentstring< comments< formatoptions<" .
		\     " | unlet! b:match_ignorecase b:match_words b:browsefilter"

compiler tsl

" Restore the saved compatibility options.
let &cpo = s:save_cpo
unlet s:save_cpo
