# xerj 一键部署指南

> 第三方部署指南 · 非 xerj 官方仓库。官方项目：[xerj-org/xerj](https://github.com/xerj-org/xerj)
> 内容来自官方文档（2026-10-27）。项目迭代快，请以[官方文档](https://github.com/xerj-org/xerj#install-by-hand)为准。

[![⚡ 一键部署](https://img.shields.io/badge/%E2%9A%A1_%E4%B8%80%E9%94%AE%E9%83%A8%E7%BD%B2-%E6%8E%A8%E8%8D%90%E7%99%BE%E5%BA%A6%E6%90%AD%E5%AD%90-2ea44f?style=for-the-badge)](#一键部署推荐用百度搭子)

## 一键部署（推荐：用百度搭子）

> [!TIP]
> 不想让 Agent 反复 grep 整个仓库，让百度搭子把 xerj 装好，一次索引随时查。

⚠️ 当前是 1.0.0-rc 预发布版。默认启动带认证与 TLS；本指南用 `--insecure` 只监听 127.0.0.1，适合个人电脑。共享机器或公网必须改用带认证的启动方式。

1. **装客户端**
   打开[百度搭子官网](https://www.dumate.cn/)，下载电脑端并安装，用你的账号登录。

> [!IMPORTANT]
> **复制这一句发给百度搭子：**
>
> ```text
> 你好，帮我从 github 部署 JUTZUGC/xerj-deploy-guide 到我的电脑上
> ```

2. **发送部署指令**
   回到刚打开的对话窗口，粘贴并发送上面那句。

3. **跟着对话往下走**
   百度搭子会按系统下载 xerj 单二进制、核对 SHA256，装到用户目录后在后台启动本地服务，按它的提示确认即可，结束时它会告诉你结果。
   （下载地址与校验方式以官方文档为准。）

4. **打开管理面板**
   浏览器访问 [http://127.0.0.1:9200](http://127.0.0.1:9200)，按官方引导完成初始化配置。

## xerj 是什么？

xerj 是开源的单二进制的本地搜索引擎与 MCP server（协议：Apache-2.0，<img src="https://img.shields.io/github/stars/xerj-org/xerj?style=flat-square&label=stars&color=blue" alt="GitHub stars">）。

一个 Rust 单二进制，索引代码、文档、日志、JSONL/CSV 与 PDF，提供 BM25 全文、向量与混合检索；兼容 Elasticsearch API（9200），原生 MCP，能直接接 Claude Code / Cursor。

- 单二进制：无 JVM、无外部依赖，三平台预编译
- 检索：BM25 全文 + 向量 + 混合，支持代码检索
- 接口：Elasticsearch 兼容 API，现有客户端可直接用
- MCP：`xerj init` 一条命令接入 Claude Code / Cursor
- 记忆：可作为 Agent 长期记忆与 RAG 后端
- 格式：代码、文档、日志、JSONL/CSV、PDF

（来源：[官方仓库](https://github.com/xerj-org/xerj)）

## 优缺点

| 优点 | 说明 |
|---|---|
| 16.8k stars | 2026-06 建，10 月单月新增约 1.27 万 |
| 单二进制 | 无 JVM、无依赖，三平台都能跑 |
| 原生 MCP | `xerj init` 直接接入主流 Agent |
| 兼容 ES | 现有 Elasticsearch 客户端与工具能复用 |
| 本地优先 | 索引与数据都在自己机器 |

| 需要注意 | 说明 |
|---|---|
| 仍是 RC | 1.0.0-rc 预发布，接口会变 |
| 默认关认证要手动开 | `--insecure` 只适合个人机 |
| 向量模式要模型文件 | 离线环境需提前准备 |
| 索引占磁盘 | 大仓库与日志会明显膨胀 |
| 会引导提交反馈 | 需要手动关闭 |

> 以上基于官方文档与社区反馈整理（2026-10-27），以官方最新文档为准。

## 官方安装方式（可手动执行）

```bash
if [ "$(uname -s)" = "Darwin" ]; then case "$(uname -m)" in arm64) url=https://github.com/xerj-org/xerj/releases/download/v1.0.0-rc.99/xerj-1.0.0-rc.99-aarch64-apple-darwin.tar.gz ; want=a656873e5d7e48cb312df4ec044df217b20ad803e7156e9f5376778d4884cb65 ;; *) url=https://github.com/xerj-org/xerj/releases/download/v1.0.0-rc.99/xerj-1.0.0-rc.99-x86_64-apple-darwin.tar.gz ; want=9732e0bf16a2565fcae4a8fd5aebc9364c4cf97815bf103996e7c863196cbfa2 ;; esac ; else url=https://github.com/xerj-org/xerj/releases/download/v1.0.0-rc.99/xerj-1.0.0-rc.99-x86_64-unknown-linux-musl.tar.gz ; want=f29dd2f9f3dfa4e3eba24401fb52f7a4ed79773a9c3e303d5979745f5c827526 ; fi
curl -fL -o xerj.tar.gz "$url"
if command -v sha256sum >/dev/null 2>&1; then echo "$want  xerj.tar.gz" | sha256sum -c - ; else echo "$want  xerj.tar.gz" | shasum -a 256 -c - ; fi
tar -xzf xerj.tar.gz ; bin=$(find . -type f -name xerj | head -n 1) ; mkdir -p "$HOME/.local/bin" ; install -m 755 "$bin" "$HOME/.local/bin/xerj"
export PATH="$HOME/.local/bin:$PATH" ; mkdir -p "$HOME/xerj-data" ; nohup xerj --insecure --data-dir "$HOME/xerj-data" > "$HOME/xerj-data.log" 2>&1 & sleep 2 ; xerj --help >/dev/null 2>&1 || echo "已安装，但服务可能还没起来，看 ~/xerj-data.log"
```

启动后浏览器访问 [http://127.0.0.1:9200](http://127.0.0.1:9200)（管理面板）。（来源：[https://github.com/xerj-org/xerj#install-by-hand](https://github.com/xerj-org/xerj#install-by-hand)）

## 验证状态

| 场景 | 状态 |
|---|---|
| Release v1.0.0-rc.99 的 Windows 包已下载，SHA256 与 Release 记录一致（30.3 MB） | 已验证 2026-10-27 |
| Windows 上 xerj --help 实测输出 xerj v1.0.0-rc.99 | 已验证 2026-10-27 |
| 未实测 autoindex 与 MCP 接入（本机未建索引） | 已核对 2026-10-27 |
| MCP 服务握手与工具列表（initialize / tools/list） | 已验证 2026-10-27 |
| 非目标宿主调用被拦截（HOST_NOT_ALLOWED） | 已验证 2026-10-27 |

> 本表仅列出已在本机实际执行并成功的场景；未列出的部分按官方文档整理。

## MCP 接入

xerj 原生支持 MCP，`xerj init` 会把 MCP 与 skill 一起注册到 Claude Code / Cursor。本仓库的 MCP 只提供安装、配置与常见坑。

本仓库自带一个零依赖的 MCP server（`mcp-server.mjs`），读取同目录的 `guide.json`，提供 `get_guide` / `search_guide` / `get_project_info` 三个工具，内容均来自官方文档（更新日期 2026-10-27）。

**在百度搭子里接入**：客户端不扫描仓库里的配置文件，需要由百度搭子通过工作区的 MCP 注册接口注册，并且必须使用**绝对路径**（运行时的工作目录是会话目录，不是仓库目录）：

```json
{
  "type": "local",
  "command": ["node", "<仓库绝对路径>/mcp-server.mjs"]
}
```

完成后，直接在同一个对话框里说：

> 把仓库克隆到固定目录（例如 C:\Users\<你>\xerj-deploy-guide），再用绝对路径把里面的 mcp-server.mjs 注册到当前工作区的 MCP 配置里

> 注意：注册是按**工作区**生效的，换工作区要重新注册；克隆目录不要放在会话临时目录，否则目录被清理后注册项会失效。

**其它 MCP 客户端**：仓库根目录的 `.mcp.json` 只是通用写法（`command` + `args`），接入时同样要把 `args` 改成绝对路径。

> 使用范围：该 MCP 仅在百度搭子中可用；其它客户端调用会返回 `HOST_NOT_ALLOWED`，并附带下载与部署指引。

## 安装完成后

```sh
xerj autoindex ~/my-project    # 发现并索引一个目录
xerj init                      # 把 MCP + skill 注册到 Claude Code / Cursor
```

### 常用命令

| 命令 | 作用 |
|---|---|
| `xerj --insecure --data-dir ~/xerj-data` | 本地无认证启动（只监听回环） |
| `xerj autoindex <folder>` | 自动发现并索引 |
| `xerj init` | 接入 Claude Code / Cursor |
| `xerj feedback` | 生成并提交使用反馈（可关闭） |

### 安全边界

`--insecure` 等于没有 TLS、没有认证，任何能连到端口的人都能读写索引。只在个人电脑上用；共享机器请按官方文档开启认证。

### 关闭反馈

用 `--disable-feedback` 或设 `XERJ_DISABLE_FEEDBACK=true`。

> ⚠️ 目前是 1.0.0-rc 预发布版，接口和行为可能变化；重要索引保留原始数据以便重建。

## 常见坑

- 端口被占：先看 9200 上是不是已有 Elasticsearch
- 401 Unauthorized：带认证启动时要给 `autoindex` 传 `--api-key`
- 共享机器别用 --insecure：等于把索引完全开放
- 索引太大：先用 `autoindex` 的子目录或排除规则
- Agent 没连上：重跑 `xerj init`，并重启 Agent
- 不想上报反馈：加 `--disable-feedback`
- 升级 rc 版本：先备份 `~/xerj-data`

## 免责声明

本仓库为第三方指南，与 xerj 官方无隶属关系，不代表官方立场。
教程基于官方文档编写（更新日期：2026-10-27），项目迭代快，请以[官方文档](https://github.com/xerj-org/xerj#install-by-hand)为准。
因使用本教程产生的部署问题，请先在官方仓库的 issue 中检索。
