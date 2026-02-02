# chmod +x install.sh 然后 ./install.sh

# 定义仓库路径
DOTFILES=$HOME/dotfiles

echo "开始同步 dotfiles..."

# 定义一个链接函数：避免重复写 ln -s
link_file() {
    local src=$1
    local dst=$2

    # 如果目标已存在且不是软链接，先备份
    if [ -f "$dst" ] && [ ! -L "$dst" ]; then
        echo "备份旧文件: $dst"
        mv "$dst" "$dst.bak"
    fi

    echo "链接: $dst -> $src"
    ln -sf "$src" "$dst"
}

# 执行链接操作
link_file "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"

echo "完成！"
