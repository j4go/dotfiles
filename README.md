# dotfiles

macOS 个人开发环境配置集合，通过符号链接统一管理，支持一键部署到新机器。

## 快速开始

```bash
# 克隆仓库（默认放在 ~/dotfiles）
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 一键部署
chmod +x install.sh && ./install.sh

# 编辑私有配置，填入代理地址和 API Keys
nvim ~/.zshrc.local

# 重新加载 Shell
source ~/.zshrc
```

## 配置概览

| 工具 | 用途 | 仓库路径 | 部署位置 |
|------|------|----------|----------|
| **Zsh** | Shell | `zsh/.zshrc` | `~/.zshrc` |
| **Git** | 版本控制 | `git/.gitconfig` | `~/.gitconfig` |
| **Neovim** | 主编辑器 | `nvim/init.lua` `nvim/lazy-lock.json` | `~/.config/nvim/` |
| **Vim** | 备用编辑器 | `vim/.vimrc` | `~/.vimrc` |
| **Kitty** | GPU 终端 | `kitty/kitty.conf` `kitty/current-theme.conf` | `~/.config/kitty/` |
| **Alacritty** | 备用终端 | `alacritty/alacritty.toml` `alacritty/alacritty-theme/` | `~/.config/alacritty/` |
| **Starship** | 跨 Shell 提示符 | `starship/starship.toml` | `~/.config/starship.toml` |
| **Zellij** | 终端复用器 | `zellij/config.kdl` | `~/.config/zellij/config.kdl` |
| **Yazi** | 终端文件管理器 | `yazi/` (含 plugins & flavors) | `~/.config/yazi/` |
| **Fastfetch** | 系统信息展示 | `fastfetch/config.jsonc` | `~/.config/fastfetch/config.jsonc` |
| **direnv** | 目录级环境变量 | `direnv/direnvrc` | `~/.config/direnv/direnvrc` |
| **Rime (Squirrel)** | 输入法 | `rime/default.yaml` `rime/squirrel.yaml` | `~/Library/Rime/` |
| **SSH** | 远程连接 | `ssh/config` | `~/.ssh/config` |
| **macmon** | Apple Silicon 监控 | `macmon/macmon.json` | `~/.config/macmon.json` |

## 核心依赖

通过 Homebrew 安装：

```bash
# Shell 增强
brew install starship zoxide fzf eza bat fd procs direnv \
  zsh-autosuggestions zsh-syntax-highlighting pay-respects

# 终端 & 工具链
brew install kitty neovim zellij yazi fastfetch lazygit

# 现代 CLI 替代
brew install dust doggo gping btop p7zip trash-cli figlet

# 输入法
brew install --cask squirrel
```

字体：[Maple Mono NF CN](https://github.com/subframe7536/maple-font)（Alacritty 和 Kitty 均使用此字体）。

## 目录结构

```
dotfiles/
├── install.sh              # 一键部署脚本
├── README.md
├── .gitignore              # 忽略 .DS_Store 和 *.local
├── alacritty/              # Alacritty 终端配置 + 主题
├── direnv/                 # direnv 自定义 layout 函数
├── fastfetch/              # Fastfetch 系统信息配置
├── git/                    # Git 全局配置与别名
├── kitty/                  # Kitty 终端配置 + 主题
├── macmon/                 # macmon 监控配置
├── nvim/                   # Neovim 配置 (Lazy.nvim 插件管理)
├── rime/                   # Rime/Squirrel 输入法配置
├── ssh/                    # SSH 客户端配置
├── starship/               # Starship 提示符配置
├── vim/                    # Vim 配置
├── yazi/                   # Yazi 文件管理器 (含插件和主题)
├── zellij/                 # Zellij 终端复用器配置
└── zsh/                    # Zsh 配置
    ├── .zshrc              # 主配置文件
    └── .zshrc.local.example  # 私有配置模板（敏感信息）
```

## 敏感信息管理

仓库通过 `.gitignore` 排除 `*.local` 文件。敏感信息（代理地址、API Keys 等）存放在 `~/.zshrc.local` 中，不纳入版本控制。

首次部署时 `install.sh` 会自动将 `zsh/.zshrc.local.example` 复制到 `~/.zshrc.local`，你需要手动填入以下内容：

- 代理地址（`PROXY_URL`、`SOCKS_URL`）
- AI 服务 API Keys（Gemini、DashScope、Ark 等）
- 开发工具 Token（GitHub、Logfire 等）

`.zshrc.local` 会在 `.zshrc` 末尾被 `source`，可以覆盖上游的任何设置。

## 设计思路

**现代工具替代**：用更高效的 Rust/Go 工具替代传统 Unix 命令，所有替代均通过 `command -v` 检测后才激活，确保配置在不同机器上的兼容性。

| 传统命令 | 替代工具 | 说明 |
|----------|----------|------|
| `ls` | `eza` | 支持图标、Git 状态、树形视图 |
| `cat` | `bat` | 语法高亮、Git diff 集成 |
| `find` | `fd` | 更快、默认忽略 .gitignore |
| `cd` | `zoxide` | 智能目录跳转，学习使用习惯 |
| `top` | `btop` | 现代化系统监控界面 |
| `du` | `dust` | 更直观的磁盘占用可视化 |
| `dig` | `doggo` | 彩色 DNS 查询输出 |
| `ping` | `gping` | 图形化 ping 结果 |
| `ps` | `procs` | 更好的进程列表展示 |
| `rm` | `trash-cli` | 安全删除，移入回收站 |

**按需加载**：`.zshrc` 中所有工具初始化都包裹在 `command -v` 条件判断中，未安装的工具不会报错，也不会拖慢 Shell 启动速度。

**敏感隔离**：`.zshrc.local` 机制将私密配置与公开仓库完全隔离，安全且便于维护。

**符号链接部署**：所有配置通过 symlink 链接，修改即时生效，无需手动同步。`install.sh` 会自动备份已存在的目标文件。

## 许可证

[MIT License](./LICENSE) © 2026 j4
