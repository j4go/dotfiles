#!/usr/bin/env bash
# =============================================================================
#  dotfiles 一键部署脚本
#  用法: chmod +x install.sh && ./install.sh
#  说明: 将仓库中的配置文件通过符号链接部署到系统对应位置
#        已存在的非软链接文件会自动备份为 .bak
# =============================================================================

set -e

DOTFILES="$HOME/dotfiles"

echo "🔗 开始部署 dotfiles..."
echo "   仓库路径: $DOTFILES"
echo ""

# ---------------------------------------------------------------------------
#  链接函数
# ---------------------------------------------------------------------------

# 链接单个文件: link_file <源文件> <目标文件>
link_file() {
    local src="$1"
    local dst="$2"

    if [[ -L "$dst" ]]; then
        local current_target
        current_target=$(readlink "$dst")
        if [[ "$current_target" == "$src" ]]; then
            echo "  ✓ 已链接: $dst"
            return
        fi
    fi

    if [[ -f "$dst" ]] && [[ ! -L "$dst" ]]; then
        echo "  💾 备份: $dst → $dst.bak"
        mv "$dst" "$dst.bak"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    echo "  🔗 $dst → $src"
}

# 链接整个目录: link_dir <源目录> <目标目录>
link_dir() {
    local src="$1"
    local dst="$2"

    if [[ -L "$dst" ]]; then
        local current_target
        current_target=$(readlink "$dst")
        if [[ "$current_target" == "$src" ]]; then
            echo "  ✓ 已链接: $dst/"
            return
        fi
    fi

    if [[ -d "$dst" ]] && [[ ! -L "$dst" ]]; then
        echo "  💾 备份: $dst/ → $dst.bak/"
        mv "$dst" "$dst.bak"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    echo "  🔗 $dst/ → $src/"
}

# ---------------------------------------------------------------------------
#  Shell & Git
# ---------------------------------------------------------------------------
echo "📦 Shell & Git"
link_file "$DOTFILES/zsh/.zshrc"            "$HOME/.zshrc"
link_file "$DOTFILES/git/.gitconfig"        "$HOME/.gitconfig"

# ---------------------------------------------------------------------------
#  编辑器
# ---------------------------------------------------------------------------
echo ""
echo "📦 编辑器"
link_file "$DOTFILES/vim/.vimrc"            "$HOME/.vimrc"
link_file "$DOTFILES/nvim/init.lua"         "$HOME/.config/nvim/init.lua"
link_file "$DOTFILES/nvim/lazy-lock.json"   "$HOME/.config/nvim/lazy-lock.json"

# ---------------------------------------------------------------------------
#  终端模拟器
# ---------------------------------------------------------------------------
echo ""
echo "📦 终端模拟器"
link_file "$DOTFILES/kitty/kitty.conf"           "$HOME/.config/kitty/kitty.conf"
link_file "$DOTFILES/kitty/current-theme.conf"   "$HOME/.config/kitty/current-theme.conf"
link_file "$DOTFILES/alacritty/alacritty.toml"   "$HOME/.config/alacritty/alacritty.toml"
link_dir  "$DOTFILES/alacritty/alacritty-theme"  "$HOME/.config/alacritty/alacritty-theme"

# ---------------------------------------------------------------------------
#  终端工具
# ---------------------------------------------------------------------------
echo ""
echo "📦 终端工具"
link_file "$DOTFILES/starship/starship.toml"     "$HOME/.config/starship.toml"
link_file "$DOTFILES/zellij/config.kdl"          "$HOME/.config/zellij/config.kdl"

# Yazi 文件管理器（含插件和主题）
echo ""
echo "📦 Yazi 文件管理器"
link_file "$DOTFILES/yazi/yazi.toml"        "$HOME/.config/yazi/yazi.toml"
link_file "$DOTFILES/yazi/keymap.toml"      "$HOME/.config/yazi/keymap.toml"
link_file "$DOTFILES/yazi/theme.toml"       "$HOME/.config/yazi/theme.toml"
link_file "$DOTFILES/yazi/init.lua"         "$HOME/.config/yazi/init.lua"
link_file "$DOTFILES/yazi/package.toml"     "$HOME/.config/yazi/package.toml"
link_dir  "$DOTFILES/yazi/flavors"          "$HOME/.config/yazi/flavors"
link_dir  "$DOTFILES/yazi/plugins"          "$HOME/.config/yazi/plugins"

# ---------------------------------------------------------------------------
#  系统工具
# ---------------------------------------------------------------------------
echo ""
echo "📦 系统工具"
link_file "$DOTFILES/fastfetch/config.jsonc"    "$HOME/.config/fastfetch/config.jsonc"
link_file "$DOTFILES/direnv/direnvrc"           "$HOME/.config/direnv/direnvrc"
link_file "$DOTFILES/macmon/macmon.json"        "$HOME/.config/macmon.json"

# ---------------------------------------------------------------------------
#  输入法
# ---------------------------------------------------------------------------
echo ""
echo "📦 输入法（Rime/Squirrel）"
link_file "$DOTFILES/rime/default.yaml"     "$HOME/Library/Rime/default.yaml"
link_file "$DOTFILES/rime/squirrel.yaml"    "$HOME/Library/Rime/squirrel.yaml"

# ---------------------------------------------------------------------------
#  SSH
# ---------------------------------------------------------------------------
echo ""
echo "📦 SSH"
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
link_file "$DOTFILES/ssh/config"            "$HOME/.ssh/config"
link_file "$DOTFILES/ssh/proxy-or-direct.sh" "$HOME/.ssh/proxy-or-direct.sh"
chmod 600 "$HOME/.ssh/config" 2>/dev/null || true
chmod +x  "$HOME/.ssh/proxy-or-direct.sh" 2>/dev/null || true

# ---------------------------------------------------------------------------
#  本地私有配置（敏感信息，不纳入版本控制）
# ---------------------------------------------------------------------------
echo ""
echo "📦 本地私有配置"
if [[ ! -f "$HOME/.zshrc.local" ]]; then
    cp "$DOTFILES/zsh/.zshrc.local.example" "$HOME/.zshrc.local"
    chmod 600 "$HOME/.zshrc.local"
    echo "  📝 已创建 ~/.zshrc.local（请填入代理地址和 API Keys）"
else
    echo "  ✓ ~/.zshrc.local 已存在，跳过"
fi

# ---------------------------------------------------------------------------
#  完成
# ---------------------------------------------------------------------------
echo ""
echo "=========================================="
echo "  ✅ dotfiles 部署完成！"
echo "=========================================="
echo ""
echo "后续步骤："
echo "  1. 编辑 ~/.zshrc.local，填入代理地址和 API Keys"
echo "  2. 执行 source ~/.zshrc 或重新打开终端"
echo "  3. Neovim 首次启动会自动安装 Lazy.nvim 插件管理器"
echo ""
