"   vim: set foldmarker={,} foldlevel=0 spell:
"
"   This is my personal .vimrc, I don't recommend you copy it, just
"   use the "   pieces you want(and understand!).  When you copy a
"   .vimrc in its entirety, weird and unexpected things can happen.
"
"   If you find an obvious mistake hit me up at:
"   http://robertmelton.com/contact (many forms of communication)
" }

" Basics {

    if has("unix")
      let s:uname = system("uname")
      if s:uname == "Darwin\n"
        let g:vimrc_system="mac"
      elseif s:uname == "Linux\n"
        let g:vimrc_system="linux"
      endif
    else
      let g:vimrc_system="win"
    endif

    if g:vimrc_system == "win"
      set runtimepath=D:\Dropbox\ApplicationData\vimfiles,D:\Dropbox\ApplicationData\vimfiles\after,$VIMRUNTIME
    endif

    set updatetime=250
    set nocompatible " explicitly get out of vi-compatible mode
    set noexrc " don't use local version of .(g)vimrc, .exrc
    set background=dark " we plan to use a dark background
    set cpoptions=aABceFsmq
    "             |||||||||
    "             ||||||||+-- When joining lines, leave the cursor
    "             |||||||      between joined lines
    "             |||||||+-- When a new match is created (showmatch)
    "             ||||||      pause for .5
    "             ||||||+-- Set buffer options when entering the
    "             |||||      buffer
    "             |||||+-- :write command updates current file name
    "             ||||+-- Automatically add <CR> to the last line
    "             |||      when using :@r
    "             |||+-- Searching continues at the end of the match
    "             ||      at the cursor position
    "             ||+-- A backslash has no special meaning in mappings
    "             |+-- :write updates alternative file name
    "             +-- :read updates alternative file name
    syntax on " syntax highlighting on
    set fencs=utf-8,gb18030,utf-16
    set fenc=utf-8
    set updatetime=200
    " this enable vim to edit crontab file on mac
    au BufEnter /private/tmp/crontab.* setl backupcopy=yes
" }

" General {
    filetype plugin indent on " load filetype plugins/indent settings
    set backspace=indent,eol,start " make backspace a more flexible
    set bs=2
    " set backup " make backup files
    " set backupdir=~/.vim/backup " where to put backup files
    " set fileformats=unix,dos,mac " support all three, in this order
    " set hidden " you can change buffers without saving
    " (XXX: #VIM/tpope warns the line below could break things)
    set iskeyword+=_,$,@,%,# " none of these are word dividers
    set noerrorbells " don't make noise
    set whichwrap=b,s,h,l,<,>,~,[,] " everything wraps
    "             | | | | | | | | |
    "             | | | | | | | | +-- "]" Insert and Replace
    "             | | | | | | | +-- "[" Insert and Replace
    "             | | | | | | +-- "~" Normal
    "             | | | | | +-- <Right> Normal and Visual
    "             | | | | +-- <Left> Normal and Visual
    "             | | | +-- "l" Normal and Visual (not recommended)
    "             | | +-- "h" Normal and Visual (not recommended)
    "             | +-- <Space> Normal and Visual
    "             +-- <BS> Normal and Visual
    set wildmenu " turn on command line completion wild style
    " ignore these list file extensions
    set wildignore=*.dll,*.o,*.obj,*.bak,*.exe,*.pyc,
                    \*.jpg,*.gif,*.png
    set wildmode=list:longest " turn on wild mode huge list
" }

" Vim UI {
    " set cursorcolumn " highlight the current column
    " set cursorline " highlight current line
    set incsearch " BUT do highlight as you type you
                   " search phrase
    set mouse-=a " Prevent entering visual mode when selecting
                 " using mouse
    set laststatus=2 " always show the status line
    set lazyredraw " do not redraw while running macros
    set linespace=0 " don't insert any extra pixel lines
                     " betweens rows
    set list " we do what to show tabs, to ensure we get them
              " out of my files
    set listchars=tab:>-,trail:- " show tabs and trailing
    set matchtime=5 " how many tenths of a second to blink
                     " matching brackets for
    set hlsearch " do highlight searched for phrases
    set nostartofline " leave my cursor where it was
    set novisualbell " don't blink
    set number " turn on line numbers
    set numberwidth=2 " We are good up to 99999 lines
    set report=0 " tell us when anything is changed via :...
    set ruler " Always show current positions along the bottom
    set scrolloff=10 " Keep 10 lines (top/bottom) for scope
    set shortmess=aOstT " shortens messages to avoid
                         " 'press a key' prompt
    set showcmd " show the command being typed
    set showmatch " show matching brackets
    set sidescrolloff=10 " Keep 5 lines at the size
    set statusline=%F%m%r%h%w[%L][%{&ff}]%y[%p%%][%04l,%04v]
    "              | | | | |  |   |      |  |     |    |
    "              | | | | |  |   |      |  |     |    + current
    "              | | | | |  |   |      |  |     |       column
    "              | | | | |  |   |      |  |     +-- current line
    "              | | | | |  |   |      |  +-- current % into file
    "              | | | | |  |   |      +-- current syntax in
    "              | | | | |  |   |          square brackets
    "              | | | | |  |   +-- current fileformat
    "              | | | | |  +-- number of lines
    "              | | | | +-- preview flag in square brackets
    "              | | | +-- help flag in square brackets
    "              | | +-- readonly flag in square brackets
    "              | +-- rodified flag in square brackets
    "              +-- full path to file in the buffer
" }

" Text Formatting/Layout {
    set completeopt=menu " don't use a pop up menu for completions
    set expandtab " no real tabs please!
    set formatoptions=rq " Automatically insert comment leader on return,
                          " and let gq format comments
    set infercase " case inferred by default
    set nowrap " do not wrap line
    set shiftround " when at 3 spaces, and I hit > ... go to 4, not 5
    set smartcase " if there are caps, go case-sensitive
    set autoindent
    set shiftwidth=2 " auto-indent amount when using cindent,
                      " >>, << and stuff like that
    set softtabstop=2 " when hitting tab or backspace, how many spaces
                       "should a tab be (see expandtab)
    set tabstop=2 " real tabs should be 8, and they will show with
                   " set list on
" }

" Folding {
    set foldenable " Turn on folding
    set foldmarker={,} " Fold C style code (only use this as default
                        " if you use a high foldlevel)
    set foldmethod=marker " Fold on the marker
    set foldlevel=100 " Don't autofold anything (but I can still
                      " fold manually)
    set foldopen=block,hor,mark,percent,quickfix,tag " what movements
                                                      " open folds
    function SimpleFoldText() " {
        return getline(v:foldstart).' '
    endfunction " }
    set foldtext=SimpleFoldText() " Custom fold text function
                                   " (cleaner than default)
" }

" Plugin Settings {
    let b:match_ignorecase = 1 " case is stupid
    let perl_extended_vars=1 " highlight advanced perl vars
                              " inside strings

    " TagList Settings {
        let Tlist_Auto_Open=0 " let the tag list open automagically
        let Tlist_Compact_Format = 1 " show small menu
        let Tlist_Ctags_Cmd = 'ctags' " location of ctags
        let Tlist_Enable_Fold_Column = 0 " do show folding tree
        let Tlist_Exist_OnlyWindow = 1 " if you are the last, kill
                                        " yourself
        let Tlist_File_Fold_Auto_Close = 0 " fold closed other trees
        let Tlist_Sort_Type = "order" " order by 'name' or 'order'
        let Tlist_Use_Right_Window = 1 " split to the right side
                                        " of the screen
        let Tlist_WinWidth = 40 " 40 cols wide, so i can (almost always)
                                 " read my functions
        " Language Specifics {
            " just functions and classes please
            let tlist_aspjscript_settings = 'asp;f:function;c:class' 
            " just functions and subs please
            let tlist_aspvbs_settings = 'asp;f:function;s:sub' 
            " don't show variables in freaking php
            let tlist_php_settings = 'php;c:class;d:constant;f:function' 
            " just functions and classes please
            let tlist_vb_settings = 'asp;f:function;c:class' 
        " }
    " }

    " FuzzyFinder Settings {
      let g:fuf_coveragefile_globPatterns=['**/*.rb', '**/*.py', '**/*.h', '**/*.cpp', '**/*.cc', '**/*.c', '**/*.hpp']
    " }

    " ClangComplete Settings {
    if filereadable(".clang_complete")
      if g:vimrc_system == "mac"
        let g:clang_library_path="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/"
      elseif g:vimrc_system == "linux"
        let g:clang_library_path="/usr/lib/x86_64-linux-gnu/"
      endif

      let g:clang_complete_auto=0
      let g:clang_make_default_keymappings=1
      let g:clang_auto_select=1
      "let g:clang_snippets = 1
      "let g:clang_snippets_engine = 'clang_complete'

      inoremap <expr> <buffer> <C-O> ClangCompleteLaunchCompletion()

    else
      let g:clang_complete_loaded=1
    endif

    " }

    " SnipMate Settings {
    "let g:snippets_dir="C:\\Users\\ThinkPad\\Dropbox\\ApplicationData\\vimfiles\\snippets"
    "imap <C-w> <c-r>=TriggerSnippet()<cr>
    " }
" }

" Mappings {
    set pastetoggle=<C-i>
    " cygwin clipboard {
      vnoremap <silent> <leader>y :call Putclip(visualmode(), 1)<CR>
      nnoremap <silent> <leader>y :call Putclip('n', 1)<CR>
    " }
    " ctags {
      " nmap <C-[> :ts <C-R>=expand("<cword>")<CR><CR>	
    " }
    " TagList {
      nnoremap <silent> <C-p> :TlistToggle<CR>
    " }
    " Insert Moves {
        imap <C-j> <Down>
        imap <C-k> <Up>
        imap <C-h> <Left>
        imap <C-l> <Right>
        imap <C-e> <End>
        imap <C-a> <Esc>
        imap <C-o> <Esc>o
    " }
    " Window Control {
        nmap - <C-W>-
        nmap = <C-W>+
        nmap > <C-W>>
        nmap < <C-W><
    " }
    " Tab Control {
        nnoremap <C-k> gT
        nnoremap <C-l> gt
        nnoremap <C-y> :tabnew <CR>
    " }
    " NerdTree Control {
        nnoremap ,nn :NERDTreeToggle<CR>
    " }
    " FuzzyFinder {
        nnoremap ,tt :tabf %<CR>:FufFileWithCurrentBufferDir<CR>
        :noremap ,ff :FufFile<CR>
        :noremap ,fz :FufFileWithCurrentBufferDir<CR>
        :noremap ,fb :FufBuffer<CR>
        :noremap ,fm :FufMruFile<CR>
        :noremap ,f; :FufMruCmd<CR>
        :noremap ,fk :FufBookmarkFile<CR>
        :noremap ,fa :FufBookmarkFileAdd<CR>
        :noremap ,fr :FufBookmarkDir<CR>
        :noremap ,fe :FufBookmarkDirAdd<CR>
        :noremap ,fd :FufDir<CR>
        ":noremap ,ft :FufTaggedFile<CR>
        :noremap ,fg :FufTag<CR>
        :noremap ,f] :FufTag! <C-r>=expand('<cword>')<CR><CR>
        :noremap ,fl :FufLine<CR>
        :noremap ,fq :FufQuickfix<CR>
        :noremap ,fp :FufChangeList<CR>
        :noremap ,fj :FufJumpList<CR>
        :noremap ,fi :FufEditDataFile<CR>
         :noremap ,fc :FufRenewCache<CR>
        :noremap ,fc :FufCoverageFile<CR>
        :noremap ,fh :FufBufferTag<CR>
    " }
" }

" Autocommands {
    " Python {
      au BufRead,BufNewFile *.py set shiftwidth=2
      au BufRead,BufNewFile *.py set softtabstop=2
    " }
    " Ruby {
        " ruby standard 2 spaces, always
        au BufRead,BufNewFile *.rb,*.rhtml set shiftwidth=2 
        au BufRead,BufNewFile *.rb,*.rhtml set softtabstop=2 
    " }
    " Notes {
        " I consider .notes files special, and handle them differently, I
        " should probably put this in another file
        au BufRead,BufNewFile *.notes set foldlevel=2
        au BufRead,BufNewFile *.notes set foldmethod=indent
        au BufRead,BufNewFile *.notes set foldtext=foldtext()
        au BufRead,BufNewFile *.notes set listchars=tab:\ \
        au BufRead,BufNewFile *.notes set noexpandtab
        au BufRead,BufNewFile *.notes set shiftwidth=8
        au BufRead,BufNewFile *.notes set softtabstop=8
        au BufRead,BufNewFile *.notes set tabstop=8
        au BufRead,BufNewFile *.notes set syntax=notes
        au BufRead,BufNewFile *.notes set nocursorcolumn
        au BufRead,BufNewFile *.notes set nocursorline
        au BufRead,BufNewFile *.notes set guifont=Consolas:h12
        au BufRead,BufNewFile *.notes set spell
    " }
    " HTML {
        au BufRead,BufNewFile *.html set noexpandtab
        au BufRead,BufNewFile *.html set softtabstop=2
        au BufRead,BufNewFile *.html set tabstop=2
    " }
    au BufNewFile,BufRead *.ahk setf ahk 
" }

" GUI Settings {
if has("gui_running")
    " Basics {
        colorscheme desert " my color scheme (only works in GUI)
        set columns=180 " perfect size for me
        set guifont=Courier\ New:h15 " My favorite font
        set guioptions=ce 
        "              ||
        "              |+-- use simple dialogs rather than pop-ups
        "              +  use GUI tabs, not console style tabs
        set lines=55 " perfect size for me
        set mousehide " hide the mouse cursor when typing
        set mouse=a
        set guioptions+=m
    " }

    " Font Switching Binds {
        map <F8> <ESC>:set guifont=Consolas:h8<CR>
        map <F9> <ESC>:set guifont=Consolas:h10<CR>
        map <F10> <ESC>:set guifont=Consolas:h12<CR>
        map <F11> <ESC>:set guifont=Consolas:h16<CR>
        map <F12> <ESC>:set guifont=Consolas:h20<CR>
    " }
endif
" }

" Project Settings {
if filereadable(".vimrc_")
  source .vimrc_
endif

" }
