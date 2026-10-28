# xerj 一键部署脚本（第三方指南）——按官方文档封装
# 官方文档：https://github.com/xerj-org/xerj#install-by-hand
# 更新日期：2026-10-28
# 类型：binary
$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) { throw '需要先安装 curl（Windows 10+ 自带 curl.exe）' }

New-Item -ItemType Directory -Force -Path .download | Out-Null
Set-Location -Path .download

curl.exe -L --fail -o xerj.zip https://github.com/xerj-org/xerj/releases/download/v1.0.0-rc.100/xerj-1.0.0-rc.100-x86_64-pc-windows-msvc.zip
$h = (Get-FileHash -Algorithm SHA256 xerj.zip).Hash.ToLower() ; if ($h -ne 'a58f293c1002c4ce5ce1793afd6fa4d3e7a509916a34044c91a38d4a53937812') { throw "SHA256 校验失败，文件可能不完整，请重试" }
Expand-Archive -Path xerj.zip -DestinationPath xerj-bin -Force ; $exe = Get-ChildItem -Path xerj-bin -Recurse -Filter xerj.exe | Select-Object -First 1 ; $dir = Join-Path $env:USERPROFILE 'xerj-data' ; New-Item -ItemType Directory -Force -Path $dir | Out-Null ; Start-Process -FilePath $exe.FullName -ArgumentList '--insecure','--data-dir',$dir -WindowStyle Hidden ; Write-Host "已启动 xerj，接口在 http://127.0.0.1:9200；程序在 $($exe.DirectoryName)"

Write-Host ''
$url = 'http://127.0.0.1:9200'
Write-Host "等待服务启动：$url"
$ready = $false
for ($i = 0; $i -lt 30; $i++) {
  try {
    Invoke-WebRequest -UseBasicParsing -Uri $url -TimeoutSec 3 | Out-Null
    $ready = $true
    break
  } catch {
    Start-Sleep -Seconds 2
  }
}
if (-not $ready) { throw "60 秒内未探测到 $url，请手动打开确认或查看日志" }
Write-Host '服务已就绪'
Write-Host '部署完成：接口在 http://127.0.0.1:9200；先运行 xerj autoindex <目录>，再用 xerj init 接入 Claude Code / Cursor'
Write-Host '若结果异常或需要改配置，请参考官方文档：https://github.com/xerj-org/xerj#install-by-hand'
