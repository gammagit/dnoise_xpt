let SessionLoad = 1
if &cp | set nocp | endif
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +1 ~/work/dmr/bvi/dnoise/dnoise_xpt/expt.m
badd +1 ~/work/dmr/bvi/dnoise/dnoise_xpt/block.m
badd +1 ~/work/dmr/bvi/dnoise/dnoise_xpt/trial.m
badd +1 ~/work/dmr/bvi/dnoise/dnoise_xpt/calibrate.m
badd +1 ~/work/dmr/bvi/dnoise/dnoise_xpt/init_params.m
args ~/work/dmr/bvi/dnoise/dnoise_xpt/expt.m
edit ~/work/dmr/bvi/dnoise/dnoise_xpt/calibrate.m
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
argglobal
let s:l = 38 - ((6 * winheight(0) + 16) / 33)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
38
normal! 026|
lcd ~/work/dmr/bvi/dnoise/dnoise_xpt
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
