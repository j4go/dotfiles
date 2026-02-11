" =============================================================================
" 插件管理 (使用 vim-plug)
"
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"
" 在命令模式输入 :PlugInstall 并回车
"
" =============================================================================
" 自动下载并安装插件管理器 (如果不存在)
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
    " 核心主题：Everforest
    Plug 'sainnhe/everforest'
    " 轻量级状态栏
    Plug 'itchyny/lightline.vim'  
call plug#end()

" =============================================================================
" Lightline 状态栏增强配置
" =============================================================================

" 1. 必须设置：隐藏原生 -- INSERT -- 等模式提示（因为 Lightline 已经显示了）
set noshowmode

" 2. Lightline 核心设置
let g:lightline = {
      \ 'colorscheme': 'everforest',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'filename': 'LightlineFilename',
      \ },
      \ }

" 3. 自定义文件名显示（可选：显示相对路径，更有利于开发）
function! LightlineFilename()
  return expand('%:f') !=# '' ? expand('%:f') : '[No Name]'
endfunction


" =============================================================================
" 主题与视觉设置
" =============================================================================
syntax on
set nocompatible
filetype plugin indent on

" 开启真彩色支持
if (has('termguicolors'))
    set termguicolors
endif

"
"Everforest Light 的三种“口味”对比
"Everforest 的魅力在于它不提供单一的白色，而是通过调节背景的“有机感”来适应不同的环境光线。
"
"对比度等级    背景色特征         视觉感受                              适用场景
"Hard          较冷的象牙白       清晰度最高；文字跳跃感强              强光环境；需要极高辨识度时
"Medium        温暖的米黄色       最平衡的视觉体验；经典Everforest感    日常办公；全天候使用
"Soft          带有绿色调的暗白   极度柔和；几乎没有视觉刺激            眼睛易疲劳者；长时间逻辑思考

" Everforest 核心配置
set background=dark
let g:everforest_background = 'medium'  " 对比度：hard, medium, soft (推荐 medium)
let g:everforest_enable_italic = 1    " 允许斜体
let g:everforest_better_performance = 0 " 关闭性能优化

try
    colorscheme everforest
catch
    colorscheme desert
endtry

" 背景半透明设置
" Normal: 普通文本背景设为 None
highlight Normal     ctermbg=NONE guibg=NONE
" NonText: 文件末尾的波浪线等
highlight NonText    ctermbg=NONE guibg=NONE
" LineNr: 行号背景 (可选，看你喜好)
highlight LineNr     ctermbg=NONE guibg=NONE
" SignColumn: git 状态栏等 (可选)
highlight SignColumn ctermbg=NONE guibg=NONE

" 界面基础
set number              " 显示行号
set ruler               " 显示光标位置
set cursorline          " 高亮当前行
set laststatus=2        " 始终显示状态栏
set showmode            " 显示当前模式
set noerrorbells        " 禁用错误响铃
set wildmenu            " 增强命令行补全
set encoding=utf-8
set fileencodings=utf-8,gb18030,latin1,gbk


" =============================================================================
" 剪切板与寄存器 (macOS 优化)
" =============================================================================
" 禁用 x 键污染剪切板 (映射到黑洞寄存器)
nnoremap x "_x

let mapleader=";"
set timeoutlen=600

" 系统剪贴板交互 (;; 前缀)
" 复制当前行/选中内容到系统剪贴板
nnoremap <Leader><Leader>y "+yy
vnoremap <Leader><Leader>y "+y
" 复制全文
nnoremap <Leader><Leader>a :%y+<CR>
" 从系统剪贴板粘贴
nnoremap <Leader><Leader>p "+p


" =============================================================================
" 快捷键映射 (逻辑增强)
" =============================================================================
" 翻页与重做
nnoremap <Leader>r <C-r>
nnoremap <Leader>d <C-d>
nnoremap <Leader>u <C-u>
nnoremap <Leader>f <C-f>
nnoremap <Leader>b <C-b>

" 取消高亮
nnoremap <silent> <Esc> :nohlsearch<CR><Esc>


" =============================================================================
" 排版与缩进
" =============================================================================
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set expandtab           " Tab 转空格
set list listchars=tab:▸\ 

" 特定文件类型保持真实 Tab
autocmd FileType make,go setlocal noexpandtab


" =============================================================================
" 文件安全与撤销管理
" =============================================================================
set undofile
set undodir=~/.vim/undodir
if !isdirectory(&undodir) | call mkdir(&undodir, 'p', 0700) | endif

set swapfile
set directory=~/.vim/swap//
if !isdirectory(&directory) | call mkdir(&directory, 'p', 0700) | endif

set nobackup
set autoread
augroup AutoCheckTime
    autocmd!
    " 只有在非命令行窗口时执行
    autocmd FocusGained,BufEnter,CursorHold * if getcmdwintype() == '' | checktime | endif
augroup END


" =============================================================================
" 搜索与匹配
" =============================================================================
set ignorecase
set smartcase
set hlsearch
set incsearch
set path+=**


" =============================================================================
" 自动化与专项优化 (Markdown)
" =============================================================================
" 自动切换 cursorline：插入模式下关闭以提升响应速度
augroup CursorLineToggle
    au!
    au InsertEnter * set nocursorline
    au InsertLeave * set cursorline
    au WinLeave * set nocursorline
    au WinEnter * set cursorline
augroup END

" Markdown 视觉优化
let g:markdown_disable_html = 1
let g:markdown_exclude_embed = 1
let g:markdown_disable_flow = 1

augroup MarkdownCustom
    autocmd!
    autocmd FileType markdown call MarkdownStyle()
augroup END

function! MarkdownStyle()
    " 清除讨厌的红色报错块
    highlight link markdownError Normal
    highlight markdownError term=NONE cterm=NONE gui=NONE
    " 强化 Everforest 的代码块视觉
    highlight link markdownCodeBlock Green
    highlight link markdownCode Green
endfunction
