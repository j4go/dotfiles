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