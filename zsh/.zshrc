#!/bin/zsh
# =============================================================================
#  ~/.zshrc  ——  macOS Zsh 配置
# =============================================================================
# 性能测试: hyperfine --warmup 3 --min-runs 10 "zsh -i -c exit"
# =============================================================================


# =============================================================================
#  基础环境变量
# =============================================================================

# web search
export EXA_API_KEY="REDACTED"
export TAVILY_API_KEY="REDACTED"
export FIRECRAWL_API_KEY="REDACTED"

# 区域与编码
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# 默认编辑器
export EDITOR="nvim"
export GIT_EDITOR="nvim"

# 文件描述符上限
ulimit -n 65535

# XDG 目录
export XDG_CACHE_HOME="$HOME/.cache"

# 代理白名单
export NO_PROXY="localhost,127.0.0.1,0.0.0.0,192.168.*,10.*,*.local"
export no_proxy="$NO_PROXY"

# Homebrew 国内镜像（中科大）
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"


# =============================================================================
#  Homebrew 初始化
# =============================================================================

if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi


# =============================================================================
#  PATH 管理
# =============================================================================

# PATH 去重（必须在赋值前声明）
typeset -U path fpath

path=($HOME/bin $HOME/.local/bin $HOME/.cargo/bin $path)

# 可选路径（仅在存在时添加）
[[ -d "$HOME/adb" ]]           && path=("$HOME/adb" $path)
[[ -d "$HOME/.lmstudio/bin" ]] && path=("$HOME/.lmstudio/bin" $path)
[[ -d "/Applications/Wireshark.app/Contents/MacOS" ]] && path=("/Applications/Wireshark.app/Contents/MacOS" $path)

# Homebrew 特定版本软件
if command -v brew >/dev/null; then
    local brew_prefix="$(brew --prefix)"
    [[ -d "$brew_prefix/opt/node@22/bin" ]] && path=("$brew_prefix/opt/node@22/bin" $path)
    [[ -d "$brew_prefix/opt/curl/bin" ]]    && path=("$brew_prefix/opt/curl/bin" $path)
fi

# Zellij 补全路径
fpath=("$HOME/.local/share/zsh/site-functions" $fpath)


# =============================================================================
#  历史记录与补全
# =============================================================================

HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE="$HOME/.zsh_history"

setopt SHARE_HISTORY          # 多终端共享历史
setopt HIST_IGNORE_ALL_DUPS   # 忽略重复命令
setopt HIST_REDUCE_BLANKS     # 去除多余空格
setopt EXTENDED_GLOB          # 高级通配符
setopt INTERACTIVE_COMMENTS   # 命令行支持注释

# 补全系统
autoload -Uz compinit
compinit -d "${ZDOTDIR:-$HOME}/.zcompdump"

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select


# =============================================================================
#  工具初始化（顺序敏感）
# =============================================================================

# Zoxide（智能 cd，需在 Starship 之前）
if command -v zoxide >/dev/null; then
    eval "$(zoxide init zsh --cmd cd)"
fi

# FZF
if command -v fzf >/dev/null; then
    source <(fzf --zsh)

    local fd_base="fd --strip-cwd-prefix --hidden --follow --exclude .git"

    export FZF_DEFAULT_COMMAND="$fd_base --type f"
    export FZF_DEFAULT_OPTS=" \
        --height 40% \
        --layout=reverse \
        --border \
        --inline-info \
        --color='header:italic' \
        --bind 'ctrl-/:toggle-preview'"

    export FZF_CTRL_T_COMMAND="$fd_base --type f"
    export FZF_CTRL_T_OPTS="--preview '[[ -d {} ]] && eza --tree --color=always --level=2 {} || bat --style=numbers --color=always --line-range=:500 {}'"

    export FZF_ALT_C_COMMAND="$fd_base --type d"
    export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons=auto --level=2 {}'"
fi

# Starship Prompt
if command -v starship >/dev/null; then
    eval "$(starship init zsh)"
fi

# Zsh 插件（必须最后加载）
if command -v brew >/dev/null; then
    local brew_prefix="$(brew --prefix)"
    [[ -f "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
        source "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [[ -f "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
        source "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# direnv（自动加载 .envrc）
if command -v direnv >/dev/null; then
    eval "$(direnv hook zsh)"
fi


# =============================================================================
#  别名系统
# =============================================================================

# 编辑器
alias vi='nvim'
alias vim='nvim'

# 系统
alias so="source ~/.zshrc"
alias h="history"
alias lsblk='diskutil list'

# 代理
alias setproxy='export all_proxy=$PROXY_URL http_proxy=$PROXY_URL https_proxy=$PROXY_URL'
alias unproxy='unset all_proxy http_proxy https_proxy'
alias curlproxy="curl --socks5-hostname \$SOCKS_URL --http2"

# Homebrew
alias brewclean='brew update && brew autoremove && brew cleanup -s'
alias brewup='brew update && brew upgrade && brew autoremove && brew cleanup -s'

# 磁盘分析
alias du_home="dust -X Library -x"
alias du_lib="ncdu -x ~/Library"

# 文件隐藏/显示
alias hide="chflags hidden"
alias display="chflags nohidden"

# Zellij
alias zew="zellij a w"
alias zels="zellij list-sessions"

# Git 快捷
alias gitup='git add . && git commit -m "update: $(date +%Y-%m-%d)" && git push'

# Jupyter
alias jupyter="jupyter lab --port 9999"

# 现代工具替代（按需加载）
if command -v eza >/dev/null; then
    alias ls='eza --icons=always --group-directories-first --time-style iso'
    alias l='eza -lh --icons=auto'
    alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
    alias la='eza -a --icons=auto'
    alias lt='eza --tree --level=2 --icons=auto'
fi

if command -v bat >/dev/null; then
    alias bgrep='batgrep'
    alias bdiff='batdiff'
    alias man='batman'
    # Man 手册使用 Bat 渲染
    export MANROFFOPT="-c"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

if command -v procs >/dev/null; then
    alias ps='procs'
    alias pst='procs --tree'
fi

if command -v lazygit >/dev/null; then
    alias lg='lazygit'
fi

if command -v btop >/dev/null; then
    alias top='btop'
fi

if command -v fastfetch >/dev/null; then
    alias os='fastfetch'
    alias neo='fastfetch'
    alias fetch='fastfetch'
fi

if command -v pay-respects >/dev/null; then
    alias f='pay-respects'
    alias fuck='pay-respects'
fi

if command -v dust >/dev/null; then
    alias disk='dust'
fi

if command -v doggo >/dev/null; then
    alias dig='doggo'
    alias nslookup='doggo'
fi

if command -v gping >/dev/null; then
    alias ping='gping'
fi

if command -v 7zz >/dev/null; then
    alias 7z='7zz'
fi

if command -v trash-put >/dev/null; then
    alias rm='trash-put'
fi

if command -v figlet >/dev/null; then
    alias print='figlet'
fi

if command -v macmon >/dev/null; then
    alias m='macmon'
fi

# SSH 快捷
alias rocky='ssh rocky'
alias fedora='ssh fedora'


# =============================================================================
#  自定义函数
# =============================================================================

# 使用 macOS 默认文本编辑器打开（自动创建不存在的文件）
function edit() {
    for file in "$@"; do
        [[ ! -e "$file" ]] && touch "$file" && echo "📄 Created: $file"
    done
    open -e "$@"
}

# Yazi 文件管理器集成（退出后自动切换目录）
function y() {
    local tmp="$(mktemp -t yazi-cwd)"
    command yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
        builtin cd -- "$cwd"
    fi
    \rm -f -- "$tmp"
}


# =============================================================================
#  输入法自动切换
# =============================================================================

if command -v im-select >/dev/null; then
    target_im="com.apple.keylayout.ABC"
    current_im=$(im-select)
    [[ "$current_im" != "$target_im" ]] && im-select "$target_im"
fi


# =============================================================================
#  启动时显示系统信息
# =============================================================================

if command -v fastfetch >/dev/null; then
    fastfetch
fi


# =============================================================================
#  本地私有配置（最后加载，覆盖上述设置）
# =============================================================================

[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# DeepSeek API key（omp / codex / 通用）
export DEEPSEEK_API_KEY="REDACTED"
