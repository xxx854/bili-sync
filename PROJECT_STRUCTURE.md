# bili-sync 项目结构分析

## 项目概述

**bili-sync** 是一款专为 NAS 用户编写的哔哩哔哩同步工具，由 Rust & Tokio 驱动。该项目能够自动下载B站的收藏夹、视频列表、视频合集、稍后再看和UP主投稿视频，并生成媒体服务器（如 Emby、Jellyfin）可识别的文件结构。

- **版本**: 2.11.1
- **作者**: amtoaer
- **许可证**: MIT
- **项目地址**: https://github.com/amtoaer/bili-sync

## 技术栈

### 后端 (Rust)
- **异步运行时**: Tokio
- **Web框架**: Axum
- **数据库**: SQLite (通过 SeaORM)
- **HTTP客户端**: Reqwest
- **序列化**: Serde
- **日志**: Tracing
- **模板引擎**: Handlebars

### 前端 (SvelteKit)
- **框架**: SvelteKit + Svelte 5
- **UI组件**: bits-ui + shadcn-svelte
- **样式**: TailwindCSS 4
- **构建工具**: Vite 7
- **包管理**: Bun

## 项目目录结构

```
bili-sync/
├── .github/                    # GitHub Actions 配置
│   └── workflows/
│       ├── build-binary.yaml   # 二进制构建
│       ├── build-doc.yaml      # 文档构建
│       ├── commit-build.yaml   # 提交构建
│       ├── pr-check.yaml       # PR检查
│       └── release-build.yaml  # 发布构建
│
├── assets/                     # 项目截图资源
│   ├── detail.webp
│   ├── dir.webp
│   ├── overview.webp
│   ├── play.webp
│   └── webui.webp
│
├── crates/                     # Rust 工作空间 crates
│   ├── bili_sync/              # 主应用程序
│   ├── bili_sync_entity/       # 数据库实体定义
│   └── bili_sync_migration/    # 数据库迁移
│
├── docs/                       # VitePress 文档站点
│   ├── .vitepress/
│   ├── assets/
│   ├── public/
│   └── *.md
│
├── scripts/                    # 辅助脚本
│   ├── tools/
│   │   └── compress_image.py   # 图片压缩工具
│   └── 2.0.3_add_fanart.py     # 迁移脚本
│
├── web/                        # SvelteKit 前端
│   ├── src/
│   │   ├── lib/
│   │   └── routes/
│   └── static/
│
├── Cargo.toml                  # Rust 工作空间配置
├── Cargo.lock
├── Dockerfile                  # Docker 构建配置
├── Justfile                    # Just 命令配置
├── License                     # MIT 许可证
├── README.md                   # 项目说明
├── rust-toolchain.toml         # Rust 工具链配置
└── rustfmt.toml                # 代码格式化配置
```

## Rust Crate 详细结构

### 1. bili_sync (主应用)

主应用程序 crate，包含所有核心业务逻辑。

```
crates/bili_sync/
├── src/
│   ├── adapter/                # 视频源适配器
│   │   ├── mod.rs              # VideoSource trait 定义
│   │   ├── collection.rs       # 视频合集/列表适配器
│   │   ├── favorite.rs         # 收藏夹适配器
│   │   ├── submission.rs       # UP主投稿适配器
│   │   └── watch_later.rs      # 稍后再看适配器
│   │
│   ├── api/                    # HTTP API 服务
│   │   ├── routes/             # 路由处理
│   │   │   ├── config/         # 配置管理 API
│   │   │   ├── dashboard/      # 仪表盘 API
│   │   │   ├── login/          # 登录 API
│   │   │   ├── me/             # 用户信息 API
│   │   │   ├── task/           # 任务管理 API
│   │   │   ├── video_sources/  # 视频源 API
│   │   │   ├── videos/         # 视频 API
│   │   │   └── ws/             # WebSocket
│   │   ├── error.rs            # 错误处理
│   │   ├── helper.rs           # 辅助函数
│   │   ├── request.rs          # 请求处理
│   │   ├── response.rs         # 响应处理
│   │   └── wrapper.rs          # 包装器
│   │
│   ├── bilibili/               # B站 API 客户端
│   │   ├── danmaku/            # 弹幕处理
│   │   │   ├── canvas/         # 弹幕画布
│   │   │   ├── ass_writer.rs   # ASS 字幕写入
│   │   │   ├── danmu.rs        # 弹幕数据
│   │   │   └── model.rs        # 弹幕模型
│   │   ├── analyzer.rs         # 视频流分析器
│   │   ├── client.rs           # HTTP 客户端
│   │   ├── collection.rs       # 合集 API
│   │   ├── credential.rs       # 凭据管理
│   │   ├── dynamic.rs          # 动态 API
│   │   ├── error.rs            # 错误定义
│   │   ├── favorite_list.rs    # 收藏夹 API
│   │   ├── me.rs               # 用户信息 API
│   │   ├── submission.rs       # 投稿 API
│   │   ├── subtitle.rs         # 字幕处理
│   │   ├── video.rs            # 视频 API
│   │   └── watch_later.rs      # 稍后再看 API
│   │
│   ├── config/                 # 配置管理
│   │   ├── args.rs             # 命令行参数
│   │   ├── current.rs          # 当前配置
│   │   ├── default.rs          # 默认配置
│   │   ├── handlebar.rs        # 模板配置
│   │   ├── item.rs             # 配置项定义
│   │   ├── versioned_cache.rs  # 版本缓存
│   │   └── versioned_config.rs # 版本配置
│   │
│   ├── notifier/               # 通知系统
│   │   ├── info.rs             # 通知信息
│   │   ├── message.rs          # 消息格式
│   │   └── mod.rs              # 通知模块
│   │
│   ├── task/                   # 任务调度
│   │   ├── http_server.rs      # HTTP 服务任务
│   │   ├── video_downloader.rs # 视频下载任务
│   │   └── mod.rs              # 任务模块
│   │
│   ├── utils/                  # 工具函数
│   │   ├── convert.rs          # 类型转换
│   │   ├── download_context.rs # 下载上下文
│   │   ├── filenamify.rs       # 文件名处理
│   │   ├── format_arg.rs       # 格式化参数
│   │   ├── model.rs            # 模型操作
│   │   ├── nfo.rs              # NFO 生成
│   │   ├── notify.rs           # 通知工具
│   │   ├── rule.rs             # 规则引擎
│   │   ├── signal.rs           # 信号处理
│   │   ├── status.rs           # 状态管理
│   │   └── validation.rs       # 验证工具
│   │
│   ├── database.rs             # 数据库初始化
│   ├── downloader.rs           # 文件下载器
│   ├── error.rs                # 错误定义
│   ├── main.rs                 # 程序入口
│   └── workflow.rs             # 工作流定义
│
├── Cargo.toml                  # Crate 依赖配置
└── build.rs                    # 构建脚本
```

### 2. bili_sync_entity (数据库实体)

定义数据库表结构和实体模型。

```
crates/bili_sync_entity/
├── src/
│   ├── custom_type/            # 自定义类型
│   │   ├── mod.rs
│   │   ├── rule.rs             # 规则类型
│   │   ├── string_vec.rs       # 字符串数组
│   │   └── upper_vec.rs        # UP主数组
│   │
│   ├── entities/               # 实体定义
│   │   ├── collection.rs       # 合集实体
│   │   ├── config.rs           # 配置实体
│   │   ├── favorite.rs         # 收藏夹实体
│   │   ├── page.rs             # 分页实体
│   │   ├── submission.rs       # 投稿实体
│   │   ├── video.rs            # 视频实体
│   │   └── watch_later.rs      # 稍后再看实体
│   │
│   └── lib.rs                  # 库入口
│
└── Cargo.toml
```

### 3. bili_sync_migration (数据库迁移)

管理数据库 schema 的版本迁移。

```
crates/bili_sync_migration/
├── src/
│   ├── lib.rs                                  # 迁移注册
│   ├── m20240322_000001_create_table.rs        # 初始表创建
│   ├── m20240505_130850_add_collection.rs      # 添加合集支持
│   ├── m20240709_130914_watch_later.rs         # 添加稍后再看
│   ├── m20240724_161008_submission.rs          # 添加投稿支持
│   ├── m20250122_062926_add_latest_row_at.rs   # 添加最新行时间
│   ├── m20250612_090826_add_enabled.rs         # 添加启用标志
│   ├── m20250613_043257_add_config.rs          # 添加配置存储
│   ├── m20250712_080013_add_video_created_at_index.rs  # 添加索引
│   ├── m20250903_094454_add_rule_and_should_download.rs # 添加规则
│   ├── m20251009_123713_add_use_dynamic_api.rs # 添加动态API
│   └── m20260324_055217_add_staff.rs           # 添加staff支持
│
└── Cargo.toml
```

## 核心功能模块

### 1. 视频源适配器 (adapter)

使用 `enum_dispatch` 实现的多态适配器模式，支持多种视频来源：

- **Favorite**: B站收藏夹
- **Collection**: 视频合集/视频列表
- **Submission**: UP主投稿视频
- **WatchLater**: 稍后再看

每个适配器实现 `VideoSource` trait，提供统一的接口：
- `display_name()`: 获取显示名称
- `filter_expr()`: 获取数据库筛选条件
- `refresh()`: 刷新视频列表
- `create_dir_all()`: 创建存储目录

### 2. B站 API 客户端 (bilibili)

封装B站各种API接口：

- **BiliClient**: HTTP客户端，处理请求签名(WBI)
- **Video**: 视频信息获取、流分析
- **FavoriteList**: 收藏夹列表
- **Collection**: 视频合集
- **WatchLater**: 稍后再看
- **Submission**: UP主投稿
- **Credential**: 凭据管理(支持二维码登录)
- **DanmakuOption**: 弹幕配置

### 3. 工作流引擎 (workflow)

核心业务流程：

```
process_video_source()
    ├── create_dir_all()          # 预创建目录
    ├── refresh()                 # 获取视频列表
    ├── refresh_video_source()    # 写入新视频到数据库
    ├── fetch_video_details()     # 获取视频详情
    └── download_unprocessed_videos()  # 下载未处理视频
        └── download_video_pages()     # 下载单个视频
            ├── fetch_video_poster()   # 下载封面
            ├── generate_video_nfo()   # 生成NFO
            ├── fetch_upper_face()     # 下载UP主头像
            ├── generate_upper_nfo()   # 生成UP主NFO
            └── dispatch_download_page()  # 分发分页下载
                └── download_page()    # 下载单个分页
                    ├── fetch_page_poster()   # 分页封面
                    ├── fetch_page_video()    # 分页视频
                    ├── generate_page_nfo()   # 分页NFO
                    ├── fetch_page_danmaku()  # 分页弹幕
                    └── fetch_page_subtitle() # 分页字幕
```

### 4. 下载器 (downloader)

支持多种下载模式：

- **fetch()**: 单文件下载
- **multi_fetch()**: 多URL尝试下载(自动重试)
- **multi_fetch_and_merge()**: 视频+音频下载并合并(使用FFmpeg)
- **并行下载**: 支持分块并行下载，提高大文件下载速度

### 5. 配置管理 (config)

- **VersionedConfig**: 版本化配置，支持数据库存储
- **ARGS**: 命令行参数解析
- **PathSafeTemplate**: 路径安全的模板渲染
- **ConcurrentDownloadLimit**: 并发下载限制
- **FilterOption**: 视频流筛选选项
- **Trigger**: 定时任务触发器

### 6. HTTP API 服务 (api)

基于 Axum 的 RESTful API：

- `/api/config`: 配置管理
- `/api/dashboard`: 仪表盘数据
- `/api/login`: 登录认证(支持二维码)
- `/api/me`: 用户信息
- `/api/task`: 任务管理
- `/api/video_sources`: 视频源管理
- `/api/videos`: 视频管理
- `/api/ws`: WebSocket 实时日志

## 前端结构 (web)

### SvelteKit 路由

```
web/src/routes/
├── +layout.svelte              # 主布局
├── +layout.ts                  # 布局数据加载
├── +page.svelte                # 首页/仪表盘
├── logs/                       # 日志页面
├── me/                         # 用户相关
│   ├── collections/            # 合集管理
│   ├── favorites/              # 收藏夹管理
│   └── uppers/                 # UP主管理
├── settings/                   # 设置页面
├── video/[id]/                 # 视频详情
├── video-sources/              # 视频源管理
└── videos/                     # 视频列表
```

### UI 组件

使用 shadcn-svelte 组件库，包含：
- 基础组件: Button, Input, Card, Dialog 等
- 布局组件: Sidebar, Breadcrumb, Sheet 等
- 数据展示: Table, Badge, Progress 等
- 反馈组件: AlertDialog, Tooltip, Sonner 等
- 自定义组件: QR登录, 规则编辑器, 状态编辑器等

## 数据库设计

### 主要表结构

1. **favorite**: 收藏夹
   - id, f_id, name, path, latest_row_at, rule, enabled

2. **collection**: 视频合集
   - id, s_id, m_id, name, type, path, latest_row_at, rule, enabled

3. **submission**: UP主投稿
   - id, mid, name, path, latest_row_at, rule, enabled

4. **watch_later**: 稍后再看
   - id, path, latest_row_at, enabled

5. **video**: 视频
   - id, collection_id, favorite_id, watch_later_id, submission_id
   - upper_id, upper_name, upper_face, staff
   - name, path, category, bvid, intro, cover
   - ctime, pubtime, favtime
   - download_status, valid, should_download
   - tags, single_page, created_at

6. **page**: 视频分页
   - id, video_id, cid, pid, name
   - width, height, duration
   - path, image, download_status, created_at

7. **config**: 配置存储
   - id, content, version, created_at

## 构建与部署

### 本地开发

```bash
# 安装依赖
cd web && bun install

# 启动前端开发服务器
bun run dev

# 构建前端
bun run build

# 运行后端
cargo run
```

### Docker 部署

```bash
# 使用 Just 构建 Docker 镜像
just build-docker

# 或手动构建
cargo build --release --target x86_64-unknown-linux-musl
docker build -t bili-sync .
```

### 环境变量

- `RUST_LOG`: 日志级别 (默认: `None,bili_sync=info`)
- `TZ`: 时区 (默认: `Asia/Shanghai`)

### 命令行参数

- `--config-dir`: 配置文件目录
- `--ffmpeg-path`: FFmpeg 路径
- `--log-level`: 日志级别
- `--scan-only`: 仅扫描模式
- `--bind-address`: 绑定地址

## 关键依赖

### Rust 依赖

| 依赖 | 用途 |
|------|------|
| tokio | 异步运行时 |
| axum | Web 框架 |
| sea-orm | ORM 框架 |
| reqwest | HTTP 客户端 |
| serde | 序列化 |
| tracing | 日志 |
| handlebars | 模板引擎 |
| clap | 命令行解析 |
| chrono | 时间处理 |
| futures | 异步工具 |

### 前端依赖

| 依赖 | 用途 |
|------|------|
| svelte | UI 框架 |
| sveltekit | 应用框架 |
| tailwindcss | 样式框架 |
| bits-ui | UI 组件库 |
| vite | 构建工具 |
| typescript | 类型系统 |

## 项目特点

1. **高性能**: 基于 Tokio 异步运行时，支持并发下载
2. **跨平台**: 支持 Linux、macOS、Windows，提供多架构二进制
3. **Docker 友好**: 提供开箱即用的 Docker 镜像
4. **媒体库兼容**: 生成 Emby/Jellyfin 等媒体服务器可识别的文件结构
5. **Web UI**: 提供现代化的 Web 管理界面
6. **智能重试**: 自动处理失败重试和风控检测
7. **灵活配置**: 支持自定义文件命名模板和下载规则
8. **增量同步**: 基于数据库记录，避免重复下载
