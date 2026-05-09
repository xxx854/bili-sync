#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export PATH="/root/.cargo/bin:$PATH"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

TARGET="x86_64-unknown-linux-musl"
BINARY_NAME="bili-sync-rs"
RELEASE_DIR="target/${TARGET}/release"
OUTPUT_PATH="${RELEASE_DIR}/${BINARY_NAME}"

check_dependencies() {
    info "检查构建依赖..."
    local missing=0

    if ! command -v rustc &>/dev/null; then
        error "未找到 rustc，请先安装 Rust: https://rustup.rs"
        missing=1
    else
        info "rustc: $(rustc --version)"
    fi

    if ! command -v cargo &>/dev/null; then
        error "未找到 cargo，请先安装 Rust: https://rustup.rs"
        missing=1
    fi

    if ! rustup target list --installed | grep -q "${TARGET}"; then
        warn "未安装 ${TARGET}，正在添加..."
        rustup target add "${TARGET}"
    fi

    if ! command -v protoc &>/dev/null; then
        error "未找到 protoc (protobuf compiler)，请安装: apt install protobuf-compiler"
        missing=1
    else
        info "protoc: $(protoc --version)"
    fi

    if command -v bun &>/dev/null; then
        JS_RUNNER="bun"
        info "JS 运行时: bun $(bun --version)"
    elif command -v npm &>/dev/null; then
        JS_RUNNER="npm"
        info "JS 运行时: npm $(npm --version)"
    else
        error "未找到 bun 或 npm，请安装 Node.js 或 bun"
        missing=1
    fi

    if [ "$missing" -ne 0 ]; then
        error "缺少必要依赖，无法继续构建"
        exit 1
    fi
}

build_frontend() {
    info "===== 构建前端 ====="
    cd "$SCRIPT_DIR/web"

    if [ "$JS_RUNNER" = "bun" ]; then
        if [ ! -d "node_modules" ]; then
            info "安装前端依赖 (bun)..."
            bun install
        fi
        info "编译前端 (bun run build)..."
        bun run build
    else
        if [ ! -d "node_modules" ]; then
            info "安装前端依赖 (npm)..."
            npm install
        fi
        info "编译前端 (npm run build)..."
        npm run build
    fi

    cd "$SCRIPT_DIR"
    info "前端构建完成 -> web/build/"
}

build_backend() {
    info "===== 编译 Rust 后端 ====="
    cargo build --target "${TARGET}" --release
    info "Rust 编译完成"
}

verify_binary() {
    info "===== 验证编译产物 ====="
    if [ ! -f "$OUTPUT_PATH" ]; then
        error "未找到编译产物: ${OUTPUT_PATH}"
        exit 1
    fi

    local size
    size=$(du -h "$OUTPUT_PATH" | cut -f1)
    info "二进制文件: ${OUTPUT_PATH}"
    info "文件大小: ${size}"
    info "文件类型: $(file "$OUTPUT_PATH")"
    info "版本信息: $("$OUTPUT_PATH" --version 2>&1 | head -1)"
    info "构建完成！"
}

main() {
    info "===== bili-sync 一键构建 ====="
    check_dependencies
    build_frontend
    build_backend
    verify_binary
}

main "$@"
