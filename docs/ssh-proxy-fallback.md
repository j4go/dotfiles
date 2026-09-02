# SSH / GitHub 连接：代理不可用时自动回退直连

**解决的问题：** 开本地代理（clash 等）时走 SOCKS5 代理访问 GitHub，代理关闭、只挂 VPN 或直连可用时自动直连，省去每次手动改 SSH 配置。

**原理：** 把 SSH 的 `ProxyCommand` 指向一个包装脚本。脚本在建立连接前探测本地代理端口是否在监听——在监听就把 TCP 连接经 SOCKS5 代理转发到目标，否则直连目标。git 通过 SSH 访问 GitHub，因此 git push/pull 自动继承这套逻辑，无需额外配置。

---

## macOS 方案

本仓库已配置并实测可用。脚本位于 `ssh/proxy-or-direct.sh`，`install.sh` 会把它软链到 `~/.ssh/` 并加执行位。

### 1. 脚本内容

`~/dotfiles/ssh/proxy-or-direct.sh`：

```sh
#!/bin/sh
# ProxyCommand 包装：连接时若本地代理端口在监听则走 SOCKS5 代理，
# 否则直连（适配挂 VPN/TUN 但不启本地代理的场景）。
#
# 用法（在 ~/.ssh/config 中）：
#     ProxyCommand ~/.ssh/proxy-or-direct.sh %h %p
#
# 如需更换代理端口，改下面这一行即可。
PROXY_PORT=10809
host=$1
port=$2

if /usr/bin/nc -z -w 1 127.0.0.1 "$PROXY_PORT" 2>/dev/null; then
    exec /usr/bin/nc -X 5 -x "127.0.0.1:$PROXY_PORT" "$host" "$port"
else
    exec /usr/bin/nc "$host" "$port"
fi
```

要点：

- `PROXY_PORT=10809` 是示例值，换成你自己的代理端口；macOS 脚本用系统自带 `/usr/bin/nc`，无需额外安装。
- `nc -z -w 1` 只探测端口是否监听（1 秒超时），不真正收发数据。
- `-X 5` 是 SOCKS5 模式。不要改用 `-X connect`（HTTP CONNECT）：macOS 自带 nc 的该模式有 bug，实测会把代理返回的 `200 Connection established` 误判为 Proxy error 后断开，报 `Connection closed by UNKNOWN port 65535`。clash 等混合端口同时支持 HTTP 和 SOCKS5，用 SOCKS5 即可。

### 2. ~/.ssh/config 里的 GitHub 块

```ssh-config
Host github.com
    HostName ssh.github.com
    Port 443
    User git
    IdentityFile ~/.ssh/id_rsa
    IdentitiesOnly yes
    PreferredAuthentications publickey
    ProxyCommand ~/.ssh/proxy-or-direct.sh %h %p
```

说明：

- `HostName ssh.github.com` + `Port 443` 是 GitHub 的 SSH over HTTPS 端口；直连时也走这个 443 端口，VPN/TUN 隧道会自动接管。
- `%h %p` 由 ssh 展开为实际主机名和端口，作为脚本的两个参数传入。
- `IdentityFile` 换成你自己的私钥路径。

### 3. 纳入 dotfiles 一键部署

`install.sh` 的 SSH 段包含：

```bash
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
link_file "$DOTFILES/ssh/config"            "$HOME/.ssh/config"
link_file "$DOTFILES/ssh/proxy-or-direct.sh" "$HOME/.ssh/proxy-or-direct.sh"
chmod 600 "$HOME/.ssh/config" 2>/dev/null || true
chmod +x  "$HOME/.ssh/proxy-or-direct.sh" 2>/dev/null || true
```

运行 `./install.sh` 后，脚本即软链到 `~/.ssh/proxy-or-direct.sh` 并带执行位。

### 4. macOS 验证

在代理开着与关着（只挂 VPN/直连可用）时各执行一次：

```bash
ssh -T github.com
```

两次都应输出 `Hi <你的用户名>! You've successfully authenticated, but GitHub does not provide shell access.`

---

## Windows 方案

> **注意：** 本方案按 Windows 自带 OpenSSH + Git for Windows 的 `connect.exe` 编写，未在 Windows 实机验证；命令中的路径需按你机器上的实际情况微调。

### 1. 前置：找到 connect.exe

Git for Windows 自带 `connect.exe`（一款专为 ssh `ProxyCommand` 设计的代理转发工具）。在 Git Bash 中执行 `where connect` 查看它的绝对路径，通常形如：

```
C:\Program Files\Git\mingw64\bin\connect.exe
```

若路径不同，把下面脚本里 `CONNECT` 变量的值改成实际路径。

### 2. 脚本 proxy-or-direct.cmd

放到 `C:\Users\<你的用户名>\.ssh\proxy-or-direct.cmd`：

```bat
@echo off
rem 连接时若本地代理端口在监听则走 SOCKS5，否则直连
rem 用法（在 %USERPROFILE%\.ssh\config 中）：
rem   ProxyCommand "C:\Users\<用户名>\.ssh\proxy-or-direct.cmd" %h %p

set PROXY_PORT=10809
set CONNECT="C:\Program Files\Git\mingw64\bin\connect.exe"

powershell -NoProfile -Command "$c=New-Object System.Net.Sockets.TcpClient; try{$c.Connect('127.0.0.1',%PROXY_PORT%); exit 0}catch{exit 1}"

if errorlevel 1 (
    %CONNECT% %1 %2
) else (
    %CONNECT% -S 127.0.0.1:%PROXY_PORT% %1 %2
)
```

要点：

- `powershell ... TcpClient.Connect` 探测 `127.0.0.1:端口`：连接成功返回 0，失败返回 1。
- `if errorlevel 1` 判断上一条命令退出码 ≥ 1 走直连分支，否则走代理分支。
- `connect.exe -S host:port` 是 SOCKS5；不带 `-S` 时直连。
- `%1 %2` 接收 ssh 展开后的主机名和端口。
- `PROXY_PORT=10809` 是示例值，换成你自己的代理端口。

### 3. ssh config

编辑 `C:\Users\<你的用户名>\.ssh\config`：

```ssh-config
Host github.com
    HostName ssh.github.com
    Port 443
    User git
    IdentityFile ~/.ssh/id_ed25519
    ProxyCommand "C:\Users\<你的用户名>\.ssh\proxy-or-direct.cmd" %h %p
```

注意：路径含空格必须用双引号包住；`IdentityFile` 换成你自己的私钥路径。

### 4. Windows 验证

在 cmd、PowerShell 或 Git Bash 中执行：

```bat
ssh -T github.com
```

期望输出 `Hi <你的用户名>! You've successfully authenticated...`。分别在代理开着和关着时各测一次，两次都应成功。

---

## 验证清单（两平台通用）

| 场景 | 预期结果 |
| --- | --- |
| 代理开着（端口在监听） | `ssh -T github.com` 认证成功（走 SOCKS5） |
| 代理关着，VPN/直连可用 | `ssh -T github.com` 认证成功（走直连） |
| git 操作 | `git ls-remote origin` 正常返回远端引用 |

---

## 常见问题与边界

- **换代理端口：** 只改脚本顶部的 `PROXY_PORT`（macOS 的 sh 脚本、Windows 的 cmd 脚本各改各的），SSH 配置文件无需变动。
- **判断标准是「端口在监听」，不是「代理能出网」。** 若 clash 进程开着、端口也在监听，但节点本身已失效，脚本仍会走代理分支而非退回直连。本方案只覆盖「代理没启动」的场景，这是有意取舍。
- **macOS 不要用 `nc -X connect`。** 实测 macOS 自带 nc 的 HTTP CONNECT 模式对代理响应处理有 bug，统一用 SOCKS5（`-X 5`）。
- **连接复用（ControlMaster）的 socket 目录。** 本仓库 `~/.ssh/config` 开启了 `ControlMaster` 和 `ControlPath ~/.ssh/sockets/%r@%h:%p`，需保证 `~/.ssh/sockets` 目录存在，否则复用会报错：`mkdir -p ~/.ssh/sockets && chmod 700 ~/.ssh/sockets`。首次连接建立后，后续连接会复用已有通道，不再经过 ProxyCommand。
- **凭据安全。** 整套方案只涉及代理端口和转发方式，不含任何 API key、token 或私钥值；文档中的所有端口、路径、用户名均为占位示例。