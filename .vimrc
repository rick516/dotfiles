set encoding=utf-8 "文字kコード指定
set fileencoding=utf-8 "書き込み時に指定 
set fileformats=unix,dos,mac "改行コードの自動認識
set ambiwidth=double "全角記号崩れを防ぐ
set number "行番号表示
set virtualedit=block "矩形選択で自由に移動
set wildmenu "タブでファイル名補完
set backspace=indent,eol,start "insertモードでバックスペース
set ignorecase "大文字小文字無視
set wrapscan "検索末尾まで行ったら先頭に戻る
set showmatch matchtime=1 "対応するかっこにカーソルが飛ぶ
set cmdheight=2 "メッセージ表示2行
set history=10000 "コマンドライン履歴1000件保存
set shiftwidth=2 "自動インデント幅
set softtabstop=2 "連続した空白に対しタブで動く幅
set tabstop=2  "画面上でタブが占める幅
set guioptions-=m "メニューバー非表示
set noswapfile "swpファイル作成しない"
set title "タイトルを表示
set clipboard=unnamed,autoselect "ヤンクでクリップボードにコピー
set whichwrap=b,s,h,l,<,>,[,],~ "行またいで移動
set hlsearch   " 検索文字列をハイライトする
set confirm    " 保存されていないファイルがあるときは終了前に保存確認
set visualbell t_vb= "ビープ無効 
set noerrorbells "エラーメッセージの表示時にビープを鳴らさない
"esc2回押したらハイライト消去
nnoremap <Esc><Esc> :nohlsearch<CR><ESC>  
syntax on "シンタックスハイライト

"カーソル復元
augroup source-vimrc
  autocmd!
  autocmd BufWritePost *vimrc source $MYVIMRC | set foldmethod=marker
  autocmd BufWritePost *gvimrc if has('gui_running') source $MYGVIMRC
augroup END
if has("autocmd")
  augroup redhat
    autocmd BufRead *.txt set tw=78
    autocmd BufReadPost *
    \ if line("'\"") > 0 && line ("'\"") <= line("$") |
    \   exe "normal! g'\"" |
    \ endif
  augroup END
endif

"dein scripts
set runtimepath+=$HOME/.cache/dein/repos/github.com/Shougo/dein.vim

if dein#load_state('$HOME/.cache/dein')
  call dein#begin('$HOME/.cache/dein')
  call dein#add('$HOME/.cache/dein/repos/github.com/Shougo/dein.vim')

	" Add or remove your plugins here:
  call dein#add('Shougo/neosnippet.vim')
	call dein#add('Shougo/neosnippet-snippets')
	call dein#add('tpope/vim-rails')
	call dein#add('tpope/vim-endwise')
  call dein#add('tomtom/tcomment_vim')
  call dein#add('vim-scripts/AnsiEsc.vim')
  call dein#add('w0rp/ale')
  call dein#add('tpope/vim-fugitive')
	call dein#add('junegunn/fzf', {'build': './install --all'})
 	call dein#add('junegunn/fzf.vim')
  call dein#add('yuezk/vim-js')
	call dein#add('maxmellon/vim-jsx-pretty')
	call dein#add('posva/vim-vue')
	call dein#add('kchmck/vim-coffee-script')
	call dein#add('soramugi/auto-ctags.vim')
  call dein#add('Shougo/deoplete.nvim')
  if !has('nvim')
    call dein#add('roxma/nvim-yarp')
    call dein#add('roxma/vim-hug-neovim-rpc')
  endif
  call dein#add('mattn/emmet-vim')
	" You can specify revision/branch/tag.

	call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable

if dein#check_install()
  call dein#install()
endif

"テーマ
colorscheme iceberg

"閉じかっこ補完 コピペの時は :set paste!を押してから（解除も同じコマンド）
inoremap { {}<LEFT>
inoremap [ []<LEFT>
inoremap ( ()<LEFT>
inoremap " ""<LEFT>
inoremap ' ''<LEFT>

"fzf周り
nnoremap <C-p> :FZFFileList<CR>
command! FZFFileList call fzf#run({
            \ 'source': 'find . -type d -name .git -prune -o ! -name .DS_Store',
 						\ 'sink': 'e'})
":Agで全文検索
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, {'options': '--delimiter : --nth 4..'}, <bang>0)
map <C-g> :Ag

"閉じタグ補完
augroup HTMLANDXMLANDJSX
	autocmd!
	autocmd Filetype xml inoremap <buffer> </ </<C-x><C-o><ESC>F<i
	autocmd Filetype html inoremap <buffer> </ </<C-x><C-o><ESC>F<i
  autocmd Filetype jsx inoremap <buffer> </ </<C-x><C-o><ESC>F<i
augroup END

"タブでauto completion
function! s:check_back_space() abort
	let col = col('.') - 1
	return !col || getline('.')[col - 1]  =~ '\s'
endfunction

" .vueファイルのハイライト対応
autocmd FileType vue syntax sync fromstart
let g:ft = ''
function! NERDCommenter_before()
  if &ft == 'vue'
	  let g:ft = 'vue'
		let stack = synstack(line('.'), col('.'))
		if len(stack) > 0
			let syn = synIDattr((stack)[0], 'name')
			if len(syn) > 0
				exe 'setf ' . substitute(tolower(syn), '^vue_', '', '')
			endif
		endif
 	endif
endfunction
function! NERDCommenter_after()
	if g:ft == 'vue'
		setf vue
		let g:ft = ''
	endif
endfunction


"coffeescript周り
" vimにcoffeeファイルタイプを認識させる
au BufRead,BufNewFile,BufReadPre *.coffee   set filetype=coffee
" インデント設定
autocmd FileType coffee    setlocal sw=2 sts=2 ts=2 et
"保存と同時にコンパイルする
autocmd BufWritePost *.coffee silent make! 
"エラーがあったら別ウィンドウで表示
autocmd QuickFixCmdPost * nested cwindow | redraw! 
" Ctrl-cで右ウィンドウにコンパイル結果を一時表示する
nnoremap <silent> <C-C> :CoffeeCompile vert <CR><C-w>h

"ctags周り
let g:auto_ctags = 1
let g:auto_ctags_directory_list = ['.git', '.svn']
let g:auto_ctags_tags_args = ['--tag-relative=yes', '--recurse=yes', '--sort=es']


" vimでファイルを開いたときに、tmuxのwindow名にファイル名を表示
if exists('$TMUX') && !exists('$NORENAME')
  au BufEnter * if empty(&buftype) | call system('tmux rename-window "[vim]"'.expand('%:t:S')) | endif
  au VimLeave * call system('tmux set-window automatic-rename on')
endif

let g:deoplete#enable_at_startup = 1

