let SessionLoad = 1
if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim
imap <silent> <F3> :if g:formOpt == 1:set formatoptions=tcqa:let g:formOpt = 0:set statusline=\[tcqa\]\ line=%03l,col=%02c%Velse:set formatoptions=tcq:let g:formOpt = 1:set statusline=\[tcq\]\ line=%03l,col=%02c%V:endifa
imap <C-BS> k$a
cnoremap <C-F4> c
inoremap <C-F4> c
cnoremap <C-Tab> w
inoremap <C-Tab> w
imap <S-Insert> 
cmap <S-Insert> +
xnoremap  ggVG
snoremap  gggHG
onoremap  gggHG
nnoremap  gggHG
vnoremap  "+y
nnoremap <silent> <NL> :call JumpInFile("\", "\	")
nnoremap <silent>  :call JumpInFile("\	", "\")
map  :RainbowToggle
noremap  
vnoremap  :update
nnoremap  :update
onoremap  :update
nnoremap  :GundoToggle
nmap  "+gP
omap  "+gP
vnoremap  "+x
noremap  u
vnoremap   zf
nnoremap   za
nmap ,ic :call InsertComment()
nmap ,sp :call SavePosition()
vmap ,gq :s/\s\+/ /ggvgq
nmap ,gq :%s/\s\+/ /ggq1G
xmap ,e <Plug>CamelCaseMotion_e
xmap ,b <Plug>CamelCaseMotion_b
xmap ,w <Plug>CamelCaseMotion_w
omap ,e <Plug>CamelCaseMotion_e
omap ,b <Plug>CamelCaseMotion_b
omap ,w <Plug>CamelCaseMotion_w
nmap ,e <Plug>CamelCaseMotion_e
nmap ,b <Plug>CamelCaseMotion_b
nmap ,w <Plug>CamelCaseMotion_w
cnoremap   :simalt ~
inoremap   :simalt ~
map F :so ~/.vim/plugin/jpythonfold.vim
map T :TlistToggle
vmap [% [%m'gv``
vmap \C <Plug>DeComment
map \p gqap
map \d :silent !mozilla "http://www.onelook.com/?w=<cword>&ls=a"&
vmap <silent> \x <Plug>VisualTraditional
vmap <silent> \c <Plug>VisualTraditionalj
nmap <silent> \x <Plug>Traditional
nmap <silent> \c <Plug>Traditionalj
vmap ]% ]%m'gv``
vmap _j :call Justify('tw',4)
nmap _j :%call Justify('tw',4)
vmap a% [%v]%
nmap b <Plug>CamelCaseMotion_b
xmap b <Plug>CamelCaseMotion_b
omap b <Plug>CamelCaseMotion_b
nmap e <Plug>CamelCaseMotion_e
xmap e <Plug>CamelCaseMotion_e
omap e <Plug>CamelCaseMotion_e
nmap gx <Plug>NetrwBrowseX
xmap i,e <Plug>CamelCaseMotion_ie
xmap i,b <Plug>CamelCaseMotion_ib
xmap i,w <Plug>CamelCaseMotion_iw
omap i,e <Plug>CamelCaseMotion_ie
omap i,b <Plug>CamelCaseMotion_ib
omap i,w <Plug>CamelCaseMotion_iw
map so :so ~/.vim/sessions/Session.vim
map ss :mksession! ~/.vim/sessions/Session.vim
map t :tag 
nmap w <Plug>CamelCaseMotion_w
xmap w <Plug>CamelCaseMotion_w
omap w <Plug>CamelCaseMotion_w
map <S-F4> :!wc -w %
map <S-F12> :call ClearBpt()
map <S-F9> :call ClAll()
map <F6> :call DbSync()
map <S-F5> :call DbQuit()
map <F5> :call DbCont()
map <F4> "*y:call system("screen -S mats -X stuff '" . @* . "\015'")
map <F1> :NERDTreeToggle
map <silent> <F3> :if g:formOpt == 1:set formatoptions=tcqa:let g:formOpt = 0:set statusline=\[tcqa\]\ line=%03l,col=%02c%Velse:set formatoptions=tcq:let g:formOpt = 1:set statusline=\[tcq\]\ line=%03l,col=%02c%V:endif
map <silent> <S-F2> :if g:toggleTool == 1:set guioptions-=T:set lines+=3:let g:toggleTool = 0:else:set lines-=3:set guioptions+=T:let g:toggleTool = 1:endif
map <silent> <S-F1> :if g:toggleMenu == 1:set guioptions-=m:set lines+=1:let g:toggleMenu = 0:else:set guioptions+=m:let g:toggleMenu = 1:endif
map <F9> :w!:!aspell --lang=en -c %:e! %
map <F12> :call SetBpt()
map <F10> :call DbStep()
map <F8> :so tags.vim
map <F7> :sp tags:%s/^\([^	:]*:\)\=\([^	]*\).*/syntax keyword Tag \2/:wq! tags.vim/^<F8>
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#NetrwBrowseX(expand("<cWORD>"),0)
map <F11> :call DbStepIn()
vnoremap <silent> <Plug>CamelCaseMotion_ie :call camelcasemotion#InnerMotion('e',v:count1)
vnoremap <silent> <Plug>CamelCaseMotion_ib :call camelcasemotion#InnerMotion('b',v:count1)
vnoremap <silent> <Plug>CamelCaseMotion_iw :call camelcasemotion#InnerMotion('w',v:count1)
onoremap <silent> <Plug>CamelCaseMotion_ie :call camelcasemotion#InnerMotion('e',v:count1)
onoremap <silent> <Plug>CamelCaseMotion_ib :call camelcasemotion#InnerMotion('b',v:count1)
onoremap <silent> <Plug>CamelCaseMotion_iw :call camelcasemotion#InnerMotion('w',v:count1)
vnoremap <silent> <Plug>CamelCaseMotion_e :call camelcasemotion#Motion('e',v:count1,'v')
vnoremap <silent> <Plug>CamelCaseMotion_b :call camelcasemotion#Motion('b',v:count1,'v')
vnoremap <silent> <Plug>CamelCaseMotion_w :call camelcasemotion#Motion('w',v:count1,'v')
onoremap <silent> <Plug>CamelCaseMotion_e :call camelcasemotion#Motion('e',v:count1,'o')
onoremap <silent> <Plug>CamelCaseMotion_b :call camelcasemotion#Motion('b',v:count1,'o')
onoremap <silent> <Plug>CamelCaseMotion_w :call camelcasemotion#Motion('w',v:count1,'o')
nnoremap <silent> <Plug>CamelCaseMotion_e :call camelcasemotion#Motion('e',v:count1,'n')
nnoremap <silent> <Plug>CamelCaseMotion_b :call camelcasemotion#Motion('b',v:count1,'n')
nnoremap <silent> <Plug>CamelCaseMotion_w :call camelcasemotion#Motion('w',v:count1,'n')
noremap <Plug>VisualFirstLine :call EnhancedCommentify('', 'first',				    line("'<"), line("'>"))
noremap <Plug>VisualTraditional :call EnhancedCommentify('', 'guess',				    line("'<"), line("'>"))
noremap <Plug>VisualDeComment :call EnhancedCommentify('', 'decomment',				    line("'<"), line("'>"))
noremap <Plug>VisualComment :call EnhancedCommentify('', 'comment',				    line("'<"), line("'>"))
noremap <Plug>FirstLine :call EnhancedCommentify('', 'first')
noremap <Plug>Traditional :call EnhancedCommentify('', 'guess')
noremap <Plug>DeComment :call EnhancedCommentify('', 'decomment')
noremap <Plug>Comment :call EnhancedCommentify('', 'comment')
onoremap <C-F4> c
nnoremap <C-F4> c
vnoremap <C-F4> c
vmap <S-Insert> 
nmap <S-Insert> "+gP
omap <S-Insert> "+gP
vnoremap <C-Insert> "+y
vnoremap <S-Del> "+x
vnoremap <BS> d
cnoremap  gggHG
inoremap  gggHG
imap  la
inoremap  :update
cmap  +
inoremap  
inoremap  u
imap "" ""i
imap $$ $$i
imap () ()i
inoremap ) )<Left>%:sleep 500m%a
imap <> <>i
noremap   :simalt ~
map ð g}
map Ý :pop
imap [] []i
imap \k %{    @@@@^i%}k$hi
imap \C <Plug>DeComment
imap <silent> \x <Plug>Traditional
imap {} {}i
abbr cknb \citeA{kaschak+borreggine:2008}
abbr ccdb \citeA{chang+dell+bock:2006}
let &cpo=s:cpo_save
unlet s:cpo_save
set autoindent
set backspace=indent,eol,start
set copyindent
set noequalalways
set expandtab
set fileencodings=ucs-bom,utf-8,latin1
set grepprg=grep\ -nH\ $*
set guicursor=n-v-c:block-Cursor/lCursor,ve:ver35-Cursor,o:hor50-Cursor,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor,sm:block-Cursor-blinkwait175-blinkoff150-blinkon175,a:blinkon0
set guifont=Droid\ Sans\ Mono\ 12
set guiheadroom=-50
set guioptions=aegirLt
set helplang=en
set iminsert=0
set imsearch=0
set keymodel=startsel,stopsel
set laststatus=2
set mouse=a
set mousemodel=popup
set ruler
set runtimepath=~/.vim,~/.vim/bundle/gundo,~/.vim/bundle/pyflakes,~/.vim/bundle/vim-json-master,/usr/share/vim/vimfiles,/usr/share/vim/vim74,/usr/share/vim/vimfiles/after,~/.vim/after
set selection=exclusive
set selectmode=mouse,key
set shiftround
set shiftwidth=4
set smartcase
set smarttab
set statusline=[tcq]\ line=%03l,col=%02c%V
set suffixes=.bak,~,.o,.h,.info,.swp,.obj,.asv
set noswapfile
set tabstop=4
set tags=./tags,~/work/vb/repo/tags
set termencoding=utf-8
set viminfo=
set whichwrap=b,s,<,>,[,]
set window=95
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/work/dmr/bvi/dnoise/dnoise_xpt
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +244 expt.m
badd +35 block.m
badd +46 trial.m
badd +1 gen_stimtex.m
badd +1 create_blob.m
badd +35 init_params.m
badd +75 calibrate.m
argglobal
silent! argdel *
argadd expt.m
edit calibrate.m
set splitbelow splitright
wincmd _ | wincmd |
split
1wincmd k
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
exe '1resize ' . ((&lines * 1 + 48) / 96)
exe '2resize ' . ((&lines * 92 + 48) / 96)
argglobal
enew
file -TabBar-
let s:cpo_save=&cpo
set cpo&vim
nnoremap <buffer> 	 :call search('\[[0-9]*:[^\]]*\]'):<BS>
nnoremap <buffer> p :wincmd p:<BS>
nnoremap <buffer> <S-Tab> :call search('\[[0-9]*:[^\]]*\]','b'):<BS>
let &cpo=s:cpo_save
unlet s:cpo_save
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal backupcopy=
setlocal balloonexpr=
setlocal nobinary
setlocal nobreakindent
setlocal breakindentopt=
setlocal bufhidden=delete
setlocal nobuflisted
setlocal buftype=nofile
setlocal nocindent
setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:-
setlocal commentstring=/*%s*/
setlocal complete=.,w,b,u,t,i
setlocal concealcursor=
setlocal conceallevel=0
setlocal completefunc=
setlocal copyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
setlocal nocursorline
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != ''
setlocal filetype=
endif
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
set foldtext=substitute(getline(v:foldstart),'\\t','\ \ \ \ ','g')
setlocal foldtext=substitute(getline(v:foldstart),'\\t','\ \ \ \ ','g')
setlocal formatexpr=
setlocal formatoptions=tcq
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=0
setlocal include=
setlocal includeexpr=
setlocal indentexpr=
setlocal indentkeys=0{,0},:,0#,!^F,o,O,e
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
setlocal lispwords=
setlocal nolist
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal nomodifiable
setlocal nrformats=octal,hex
setlocal nonumber
setlocal numberwidth=4
setlocal omnifunc=
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norelativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal shiftwidth=4
setlocal noshortname
setlocal nosmartindent
setlocal softtabstop=0
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=
setlocal noswapfile
setlocal synmaxcol=3000
if &syntax != ''
setlocal syntax=
endif
setlocal tabstop=4
setlocal tags=
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal undolevels=-123456
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
lcd ~/work/dmr/bvi/dnoise/dnoise_xpt
wincmd w
argglobal
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal backupcopy=
setlocal balloonexpr=
setlocal nobinary
setlocal nobreakindent
setlocal breakindentopt=
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:-
setlocal commentstring=/*%s*/
setlocal complete=.,w,b,u,t,i
setlocal concealcursor=
setlocal conceallevel=0
setlocal completefunc=
setlocal copyindent
setlocal cryptmethod=
setlocal nocursorbind
setlocal nocursorcolumn
setlocal nocursorline
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'matlab'
setlocal filetype=matlab
endif
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
set foldtext=substitute(getline(v:foldstart),'\\t','\ \ \ \ ','g')
setlocal foldtext=substitute(getline(v:foldstart),'\\t','\ \ \ \ ','g')
setlocal formatexpr=
setlocal formatoptions=tcq
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal grepprg=
setlocal iminsert=0
setlocal imsearch=0
setlocal include=
setlocal includeexpr=
setlocal indentexpr=GetMatlabIndent(v:lnum)
setlocal indentkeys=!,o,O=end,=case,=else,=elseif,=otherwise,=catch
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
setlocal lispwords=
setlocal nolist
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=octal,hex
setlocal nonumber
setlocal numberwidth=4
setlocal omnifunc=
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norelativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal shiftwidth=4
setlocal noshortname
setlocal nosmartindent
setlocal softtabstop=0
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=.m
setlocal noswapfile
setlocal synmaxcol=3000
if &syntax != 'matlab'
setlocal syntax=matlab
endif
setlocal tabstop=4
setlocal tags=
setlocal textwidth=0
setlocal thesaurus=
setlocal noundofile
setlocal undolevels=-123456
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 73 - ((72 * winheight(0) + 46) / 92)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
73
normal! 033|
lcd ~/work/dmr/bvi/dnoise/dnoise_xpt
wincmd w
2wincmd w
exe '1resize ' . ((&lines * 1 + 48) / 96)
exe '2resize ' . ((&lines * 92 + 48) / 96)
tabnext 1
if exists('s:wipebuf')
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filnxtToO
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
