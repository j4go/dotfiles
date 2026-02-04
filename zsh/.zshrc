# =============================================================================
# Mac ZSH 专用配置 ~/.zshrc

# 测试zsh启动延迟 brew install hyperfine
# zsh -f 参数表示禁用配置文件
# hyperfine --warmup 3 --min-runs 10 "zsh -i -c exit"  "zsh -f -i -c exit"

# =============================================================================


# =============================================================================
#  Basic Settings & Secrets & Proxy
# =============================================================================
ulimit -n 65535

# 检查是否存在本地私密配置文件，如果有则加载
if [[ -f "$HOME/.zshrc.local" ]]; then
    source "$HOME/.zshrc.local"
fi

export NO_PROXY="localhost,127.0.0.1,0.0.0.0,192.168.*,10.*,*.local"
export no_proxy=$NO_PROXY

alias setproxy='export all_proxy=$PROXY_URL http_proxy=$PROXY_URL https_proxy=$PROXY_URL'
alias unproxy='unset all_proxy http_proxy https_proxy'
# curl 代理 示例: curlproxy -I https://www.google.com/
alias curlproxy="curl --socks5-hostname $SOCKS_URL --http2"

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export EDITOR="vim"
export GIT_EDITOR="vim"
#export GIT_EDITOR="code --wait"

# 让 Man 手册使用 Bat 渲染 (带语法高亮和自动分页)
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"


# =============================================================================
# Homebrew环境
# =============================================================================
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi


# =============================================================================
# PATH 路径管理 (使用 Zsh 自动去重语法)
# =============================================================================
typeset -U path fpath

# zellij 补全配置 以下被注释掉的命令需要执行一次,初始化之后就不用动了
# mkdir -p ~/.local/share/zsh/site-functions
# zellij setup --generate-completion zsh > ~/.local/share/zsh/site-functions/_zellij
# ls -l ~/.local/share/zsh/site-functions/_zellij
# rm -f ~/.zcompdump; compinit
fpath=($HOME/.local/share/zsh/site-functions $fpath)


path=(
    $HOME/bin
    $HOME/.local/bin
    $HOME/.cargo/bin
    $HOME/.lmstudio/bin
    $(brew --prefix)/opt/node@22/bin
    $(brew --prefix)/opt/curl/bin
    /Applications/Wireshark.app/Contents/MacOS
    $path
)


# =============================================================================
# Conda/Mamba 配置 (Lazy Load)
# =============================================================================
export MAMBA_EXE='/Users/cela/miniforge3/bin/mamba'
export MAMBA_ROOT_PREFIX='/Users/cela/miniforge3'

mamba_setup() {
    if [[ -f "$MAMBA_ROOT_PREFIX/etc/profile.d/conda.sh" ]]; then
        source "$MAMBA_ROOT_PREFIX/etc/profile.d/conda.sh"
        source "$MAMBA_ROOT_PREFIX/etc/profile.d/mamba.sh"
    fi
    unalias mamba conda 2>/dev/null
    unfunction mamba_setup
}

alias mamba='mamba_setup; mamba'
alias conda='mamba_setup; conda'


# =============================================================================
# ZSH history与现代补全
# =============================================================================
HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE="$HOME/.zsh_history"

setopt SHARE_HISTORY          # 多个终端会话共享历史记录
setopt HIST_IGNORE_ALL_DUPS   # 忽略重复命令
setopt HIST_REDUCE_BLANKS     # 删除多余空格
setopt EXTENDED_GLOB          # 开启高级通配符
setopt INTERACTIVE_COMMENTS   # 允许命令行输入注释

# 启用现代补全系统
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.m-1) ]]; then
  compinit -C
else
  compinit
fi
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # 补全忽略大小写
zstyle ':completion:*' menu select                  # 补全菜单可选择


# =============================================================================
# 别名系统 (Aliases)
# =============================================================================
alias zew="zellij a w"
alias zels="zellij list-sessions"

alias ps='procs'
alias pst="procs --tree"
alias print="figlet"
alias rocky='ssh rocky'
alias fedora='ssh fedora'
alias m='macmon'
alias so="source ~/.zshrc"
alias h="history"
alias lsblk='diskutil list'
alias update_all='brew update && brew upgrade && brew cleanup'
alias gitup='git add . && git commit -m "update: $(date +%Y-%m-%d)" && git push'

# AI/Dev 服务
alias serve='OLLAMA_ORIGINS="*" OLLAMA_KEEP_ALIVE=20m ollama serve'
alias jupyter="jupyter lab --port 9999"

# Eza (替代 ls)
if command -v eza >/dev/null; then
    alias ls='eza --icons=always --group-directories-first --time-style iso'
    alias l='eza -lh --icons=auto'
    alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
    alias la='eza -a --icons=auto'
    alias lt='eza --tree --level=2 --icons=auto'
fi

# Bat (替代 cat & man)
if command -v bat >/dev/null; then
    alias bgrep='batgrep'
    alias bdiff='batdiff'
    alias man='batman'
fi

# Trash-CLI (替代 rm)
if command -v trash-put >/dev/null; then
    alias rm='trash-put'
fi

# SevenZip (替代 7z)
if command -v 7zz >/dev/null; then
    alias 7z='7zz'
fi

if command -v pay-respects >/dev/null; then
    alias f='pay-respects'
    alias fuck='pay-respects'
fi

if command -v dust >/dev/null; then
    alias disk='dust'
fi

if command -v lazygit >/dev/null; then
    alias lg='lazygit'
fi

if command -v doggo >/dev/null; then
    alias dig='doggo'
    alias nslookup='doggo'
fi

if command -v gping >/dev/null; then
    alias ping='gping'
fi

if command -v btop >/dev/null; then
    alias top='btop'
fi

if command -v fastfetch >/dev/null; then
    alias os="macchina"
    alias neo="fastfetch"
    alias fetch="fastfetch"
fi


# =============================================================================
# 插件与工具初始化
# =============================================================================

# Zoxide (智能目录跳转 - 必须先于 Starship 加载)
eval "$(zoxide init zsh --cmd cd)"

# FZF (模糊搜索 - 同步自 Nix 配置)
if command -v fzf >/dev/null; then
    source <(fzf --zsh)
    
    # --- 变量定义 (对应 bash.nix 逻辑) ---
    # 基础 fd 命令：排除 .git，显示隐藏文件，跟随链接，移除 ./ 前缀
    local fd_base="fd --strip-cwd-prefix --hidden --follow --exclude .git"
    
    # 1. 默认配置 (UI 与 行为)
    # 对应 defaultCommand 和 defaultOptions
    export FZF_DEFAULT_COMMAND="$fd_base --type f"
    export FZF_DEFAULT_OPTS=" \
        --height 40% \
        --layout=reverse \
        --border \
        --inline-info \
        --color='header:italic' \
        --bind 'ctrl-/:toggle-preview'"

    # 2. 文件组件 (CTRL-T)
    # 对应 fileWidgetCommand 和 fileWidgetOptions
    export FZF_CTRL_T_COMMAND="$fd_base --type f"
    # Preview: 目录用 eza 树状显示，文件用 bat 显示前500行
    export FZF_CTRL_T_OPTS="--preview '[[ -d {} ]] && eza --tree --color=always --level=2 {} || bat --style=numbers --color=always --line-range=:500 {}'"

    # 3. 目录组件 (ALT-C)
    # 对应 changeDirWidgetCommand 和 changeDirWidgetOptions
    export FZF_ALT_C_COMMAND="$fd_base --type d"
    # Preview: 使用 eza 显示目录树
    export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons=auto --level=2 {}'"
fi

# Starship (Prompt 主题)
eval "$(starship init zsh)"

# Zsh 功能插件 (必须最后加载)
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# =============================================================================
# 自定义函数
# =============================================================================

# Mac下使用默认的aplle文本编辑器(不是Vim)
function edit() {
    for file in "$@"; do
        [[ ! -e "$file" ]] && touch "$file" && echo "📄 Created: $file"
    done
    open -e "$@"
}

# =============================================================================
# 自动切换输入法
# brew tap daipeihust/tap
# brew install im-select
# =============================================================================
# 强制切换到 macOS 系统自带的纯英文输入法 (需在系统设置里添加 "ABC")
if command -v im-select >/dev/null; then
    # 这里的 ID 必须是系统 ABC 的 ID，而不是 Rime 的 ID
    target_im="com.apple.keylayout.ABC"

    # 获取当前输入法
    current_im=$(im-select)

    # 如果当前不是 ABC，则切换
    if [[ "$current_im" != "$target_im" ]]; then
        im-select "$target_im"
    fi
fi

# ===============================================
# yazi y function
# macOS / Zsh 专属适配版
function y() {
    # 使用更符合 BSD 规范的临时文件创建方式
    local tmp="$(mktemp -t yazi-cwd)"

    # 显式使用 command 执行，防止 alias 循环
    command yazi "$@" --cwd-file="$tmp"

    # Zsh 的判断语法更强大，但为了兼容性保留此写法
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    \rm -f -- "$tmp"
}

# =============================================================================
# Zellij 自动启动与环境集成
# =============================================================================

# 1. 注入补全 (适配 Zsh) 这里改成上面的一次性引入了 不改的话source会报错
#if command -v zellij >/dev/null; then
#    eval "$(zellij setup --generate-completion zsh)"
#fi

# 2. 自动启动逻辑 (带 IDE 防护)
# 只有在非 Zellij 环境、非 SSH、且非 IDE 内置终端时才启动
#if [[ -z "$ZELLIJ" && -z "$SSH_CONNECTION" ]]; then
#    if [[ "$TERM_PROGRAM" != "vscode" && "$TERM_PROGRAM" != "JetBrains-JediTerm" ]]; then
#        if command -v zellij >/dev/null; then
#            zellij attach -c w
#            # 自动连接名为 'w' 的会话；退出 Zellij 时直接关闭终端窗口
#            # exec zellij attach -c w
#        fi
#    fi
#fi
