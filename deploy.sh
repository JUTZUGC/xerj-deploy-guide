#!/usr/bin/env bash
set -euo pipefail
# xerj 一键部署脚本（第三方指南）——按官方文档封装
# 官方文档：https://github.com/xerj-org/xerj#install-by-hand
# 更新日期：2026-10-28
# 类型：binary
cd "$(dirname "${BASH_SOURCE[0]}")"

command -v curl >/dev/null 2>&1 || { echo "需要先安装 curl"; exit 1; }

mkdir -p .download
cd .download

if [ "$(uname -s)" = "Darwin" ]; then case "$(uname -m)" in arm64) url=https://github.com/xerj-org/xerj/releases/download/v1.0.0-rc.100/xerj-1.0.0-rc.100-aarch64-apple-darwin.tar.gz ; want=c88fdcb99c4155d2f7260138c3a5898d0f3cf6b07cd208895137ff03c52b9d1a ;; *) url=https://github.com/xerj-org/xerj/releases/download/v1.0.0-rc.100/xerj-1.0.0-rc.100-x86_64-apple-darwin.tar.gz ; want=30f6148c68c584ab990eeaa9bc9a05209c2ba2374a5ae90651be17f588edac91 ;; esac ; else url=https://github.com/xerj-org/xerj/releases/download/v1.0.0-rc.100/xerj-1.0.0-rc.100-x86_64-unknown-linux-musl.tar.gz ; want=4b12a47e8433e9d01d2b3f505b17b342a6e28d41edaabd274eba5a759e9cde1e ; fi
curl -fL -o xerj.tar.gz "$url"
if command -v sha256sum >/dev/null 2>&1; then echo "$want  xerj.tar.gz" | sha256sum -c - ; else echo "$want  xerj.tar.gz" | shasum -a 256 -c - ; fi
tar -xzf xerj.tar.gz ; bin=$(find . -type f -name xerj | head -n 1) ; mkdir -p "$HOME/.local/bin" ; install -m 755 "$bin" "$HOME/.local/bin/xerj"
export PATH="$HOME/.local/bin:$PATH" ; mkdir -p "$HOME/xerj-data" ; nohup xerj --insecure --data-dir "$HOME/xerj-data" > "$HOME/xerj-data.log" 2>&1 & sleep 2 ; xerj --help >/dev/null 2>&1 || echo "已安装，但服务可能还没起来，看 ~/xerj-data.log"

echo ""
if command -v curl >/dev/null 2>&1; then
  echo "等待服务启动：http://127.0.0.1:9200"
  ready=0
  for _ in $(seq 1 30); do
    if curl -sS -o /dev/null "http://127.0.0.1:9200" 2>/dev/null; then ready=1; break; fi
    sleep 2
  done
  if [ "$ready" = "1" ]; then
    echo "服务已就绪"
  else
    echo "警告：60 秒内未探测到 http://127.0.0.1:9200，请手动打开确认或查看日志"
    exit 1
  fi
else
  echo "未检测到 curl，跳过启动探测；请手动访问 http://127.0.0.1:9200 确认"
fi
echo "部署完成：接口在 http://127.0.0.1:9200；先运行 xerj autoindex <目录>，再用 xerj init 接入 Claude Code / Cursor"
echo "若结果异常或需要改配置，请参考官方文档：https://github.com/xerj-org/xerj#install-by-hand"
