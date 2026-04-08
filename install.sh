#!/usr/bin/env bash
set -euo pipefail

NVIM_CONFIG="$HOME/.config/nvim"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCAL_BIN="$HOME/.local/bin"

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
  SUDO=""
elif command -v sudo &>/dev/null; then
  SUDO="sudo"
else
  SUDO=""
fi

# ---------- Homebrew PATH 补全（macOS ARM/Intel）----------
if [ "$(uname -s)" = "Darwin" ]; then
  if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"   # Apple Silicon
  elif [ -x "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"       # Intel Mac
  fi
fi

case ":$PATH:" in
  *":$LOCAL_BIN:"*) ;;
  *) export PATH="$LOCAL_BIN:$PATH" ;;
esac

# ---------- GitHub 镜像检测 ----------
probe_url() {
  curl -fsIL --connect-timeout 5 --max-time 12 "$1" >/dev/null 2>&1
}

detect_github_mirror() {
  if [ -n "${GITHUB_MIRROR:-}" ]; then
    echo "$GITHUB_MIRROR"
  elif probe_url "https://github.com"; then
    echo "https://github.com"
  elif probe_url "https://ghproxy.cn/https://github.com"; then
    echo "https://ghproxy.cn/https://github.com"
  else
    echo "https://github.com"
  fi
}
GITHUB_MIRROR="$(detect_github_mirror)"
export GITHUB_MIRROR
echo "==> GitHub 镜像: $GITHUB_MIRROR"

# ---------- 包管理器检测 ----------
APT_UPDATED=0

ensure_apt_index() {
  if [ "$APT_UPDATED" -eq 0 ]; then
    ${SUDO:+$SUDO }apt-get update
    APT_UPDATED=1
  fi
}

detect_pkg_manager() {
  if command -v apt-get &>/dev/null; then echo "apt"
  elif command -v dnf &>/dev/null;     then echo "dnf"
  elif command -v yum &>/dev/null;     then echo "yum"
  elif command -v pacman &>/dev/null;  then echo "pacman"
  elif command -v brew &>/dev/null;    then echo "brew"
  else echo "unknown"
  fi
}

pkg_install() {
  local pkg="$1"
  case "$(detect_pkg_manager)" in
    apt)
      if [ -z "$SUDO" ] && [ "${EUID:-$(id -u)}" -ne 0 ]; then
        echo "无法自动安装 $pkg：当前环境没有 sudo，将继续尝试用户目录安装/已有命令"
        return 1
      fi
      ensure_apt_index
      ${SUDO:+$SUDO }apt-get install -y "$pkg"
      ;;
    dnf)
      if [ -z "$SUDO" ] && [ "${EUID:-$(id -u)}" -ne 0 ]; then
        echo "无法自动安装 $pkg：当前环境没有 sudo，将继续尝试用户目录安装/已有命令"
        return 1
      fi
      ${SUDO:+$SUDO }dnf install -y "$pkg"
      ;;
    yum)
      if [ -z "$SUDO" ] && [ "${EUID:-$(id -u)}" -ne 0 ]; then
        echo "无法自动安装 $pkg：当前环境没有 sudo，将继续尝试用户目录安装/已有命令"
        return 1
      fi
      ${SUDO:+$SUDO }yum install -y "$pkg"
      ;;
    pacman)
      if [ -z "$SUDO" ] && [ "${EUID:-$(id -u)}" -ne 0 ]; then
        echo "无法自动安装 $pkg：当前环境没有 sudo，将继续尝试用户目录安装/已有命令"
        return 1
      fi
      ${SUDO:+$SUDO }pacman -S --noconfirm "$pkg"
      ;;
    brew)
      brew install "$pkg"
      ;;
    *)
      echo "无法自动安装 $pkg，请手动安装"
      return 1
      ;;
  esac
}

# ---------- 安装 neovim ----------
install_neovim() {
  echo "==> 安装 neovim..."
  local pm
  pm="$(detect_pkg_manager)"
  case "$pm" in
    apt)
      if [ -z "$SUDO" ] && [ "${EUID:-$(id -u)}" -ne 0 ]; then
        echo "    跳过 apt 安装：当前环境没有 sudo"
        return 1
      fi
      ensure_apt_index
      ${SUDO:+$SUDO }apt-get install -y neovim
      ;;
    dnf|yum)
      if [ -z "$SUDO" ] && [ "${EUID:-$(id -u)}" -ne 0 ]; then
        echo "    跳过 $pm 安装：当前环境没有 sudo"
        return 1
      fi
      if ! rpm -q epel-release &>/dev/null; then
        ${SUDO:+$SUDO }"$pm" install -y epel-release
      fi
      ${SUDO:+$SUDO }"$pm" install -y neovim
      ;;
    pacman)
      if [ -z "$SUDO" ] && [ "${EUID:-$(id -u)}" -ne 0 ]; then
        echo "    跳过 pacman 安装：当前环境没有 sudo"
        return 1
      fi
      ${SUDO:+$SUDO }pacman -S --noconfirm neovim
      ;;
    brew)
      brew install neovim
      ;;
    *)
      echo "    未识别的包管理器，尝试使用官方二进制安装"
      return 1
      ;;
  esac
}

install_neovim_fallback() {
  echo "==> 使用官方二进制安装 neovim..."

  local os arch archive_name download_url tmp_archive install_root extracted_root
  os="$(uname -s)"
  arch="$(uname -m)"

  case "$os" in
    Linux)
      case "$arch" in
        x86_64|amd64) archive_name="nvim-linux-x86_64.tar.gz" ;;
        arm64|aarch64) archive_name="nvim-linux-arm64.tar.gz" ;;
        *) echo "错误: 当前架构 $arch 暂不支持自动安装 neovim，请手动安装 >= 0.9"; exit 1 ;;
      esac
      ;;
    Darwin)
      case "$arch" in
        x86_64) archive_name="nvim-macos-x86_64.tar.gz" ;;
        arm64) archive_name="nvim-macos-arm64.tar.gz" ;;
        *) echo "错误: 当前架构 $arch 暂不支持自动安装 neovim，请手动安装 >= 0.9"; exit 1 ;;
      esac
      ;;
    *)
      echo "错误: 当前系统 $os 暂不支持自动安装 neovim，请手动安装 >= 0.9"
      exit 1
      ;;
  esac

  mkdir -p "$HOME/.local/opt" "$LOCAL_BIN"
  tmp_archive="$(mktemp "/tmp/${archive_name}.XXXXXX")"
  download_url="${GITHUB_MIRROR}/neovim/neovim/releases/latest/download/${archive_name}"

  curl -fL --retry 3 --retry-delay 2 "$download_url" -o "$tmp_archive"

  install_root="$HOME/.local/opt"
  tar -C "$install_root" -xzf "$tmp_archive"
  rm -f "$tmp_archive"

  case "$archive_name" in
    nvim-linux-*.tar.gz) extracted_root="$install_root/${archive_name%.tar.gz}" ;;
    nvim-macos-*.tar.gz) extracted_root="$install_root/${archive_name%.tar.gz}" ;;
  esac

  ln -sf "$extracted_root/bin/nvim" "$LOCAL_BIN/nvim"
}

parse_nvim_version() {
  "$1" --version 2>/dev/null | head -1 | sed -E 's/.*NVIM v([0-9]+\.[0-9]+).*/\1/'
}

nvim_version_supported() {
  local version="$1"
  local major minor
  major="$(printf '%s' "$version" | cut -d. -f1)"
  minor="$(printf '%s' "$version" | cut -d. -f2)"
  [ -n "$major" ] && [ "$major" -ge 1 ] && return 0
  [ -n "$major" ] && [ -n "$minor" ] && [ "$major" -eq 0 ] && [ "$minor" -ge 9 ]
}

retry_cmd() {
  local attempts="$1"
  shift
  local i=1
  while [ "$i" -le "$attempts" ]; do
    if "$@"; then
      return 0
    fi
    if [ "$i" -lt "$attempts" ]; then
      echo "    第 $i 次失败，稍后重试..."
      sleep 2
    fi
    i=$((i + 1))
  done
  return 1
}


# ---------- 设置 vi/vim 指向 nvim ----------
setup_aliases() {
  local nvim_path="$1"
  local link_dir

  if [ "$(uname -s)" = "Darwin" ]; then
    link_dir="$HOME/bin"
  else
    link_dir="$LOCAL_BIN"
  fi

  mkdir -p "$link_dir"
  for name in vi vim; do
    ln -sf "$nvim_path" "$link_dir/$name"
  done
  echo "    vi/vim -> $nvim_path (via $link_dir/)"

  case ":$PATH:" in
    *":$link_dir:"*) ;;
    *) export PATH="$link_dir:$PATH" ;;
  esac

  if [ "$(uname -s)" != "Darwin" ] && command -v update-alternatives &>/dev/null && { [ -n "$SUDO" ] || [ "${EUID:-$(id -u)}" -eq 0 ]; }; then
    ${SUDO:+$SUDO }update-alternatives --install /usr/bin/vi vi "$nvim_path" 60
    ${SUDO:+$SUDO }update-alternatives --install /usr/bin/vim vim "$nvim_path" 60
    ${SUDO:+$SUDO }update-alternatives --set vi "$nvim_path"
    ${SUDO:+$SUDO }update-alternatives --set vim "$nvim_path"
    echo "    已同步 update-alternatives"
  fi
}

# ---------- 安装依赖 ----------
echo "==> 检查并安装依赖..."
for cmd in git curl; do
  command -v "$cmd" &>/dev/null || pkg_install "$cmd"
done

if ! command -v rg &>/dev/null; then
  echo "==> 安装 ripgrep..."
  pkg_install ripgrep || echo "警告: ripgrep 安装失败，telescope live_grep 将不可用"
fi

# ---------- 查找 neovim ----------
find_nvim() {
  if [ -x "$LOCAL_BIN/nvim" ]; then
    echo "$LOCAL_BIN/nvim"
  elif [ -x "/opt/homebrew/bin/nvim" ]; then
    echo "/opt/homebrew/bin/nvim"
  elif [ -x "/usr/local/bin/nvim" ]; then
    echo "/usr/local/bin/nvim"
  elif command -v nvim &>/dev/null; then
    command -v nvim
  else
    echo ""
  fi
}

NVIM_BIN="$(find_nvim)"

if [ -z "$NVIM_BIN" ]; then
  echo "==> neovim 未安装，开始安装..."
  install_neovim || true
  NVIM_BIN="$(find_nvim)"
fi

if [ -z "$NVIM_BIN" ]; then
  install_neovim_fallback
  NVIM_BIN="$(find_nvim)"
fi

if [ -z "$NVIM_BIN" ]; then
  echo "错误: neovim 安装失败"
  exit 1
fi

NVIM_VER="$(parse_nvim_version "$NVIM_BIN")"
if ! nvim_version_supported "$NVIM_VER"; then
  echo "==> neovim 版本过低 ($NVIM_VER)，尝试升级/兜底安装..."
  install_neovim || true
  NVIM_BIN="$(find_nvim)"
  NVIM_VER="$(parse_nvim_version "$NVIM_BIN")"
fi

if ! nvim_version_supported "$NVIM_VER"; then
  install_neovim_fallback
  NVIM_BIN="$(find_nvim)"
  NVIM_VER="$(parse_nvim_version "$NVIM_BIN")"
fi

if ! nvim_version_supported "$NVIM_VER"; then
  echo "错误: neovim 版本仍然低于 0.9 ($NVIM_VER)"
  exit 1
fi

echo "    neovim $NVIM_VER 已就绪"

setup_aliases "$NVIM_BIN"

# ---------- 部署配置 ----------
if [ -d "$NVIM_CONFIG" ]; then
  BACKUP="$HOME/.config/nvim.bak.$(date +%Y%m%d%H%M%S)"
  mv "$NVIM_CONFIG" "$BACKUP"
  echo "==> 旧配置已备份到 $BACKUP"
fi

echo "==> 安装配置..."
cp -r "$REPO_DIR" "$NVIM_CONFIG"
rm -rf "$NVIM_CONFIG/.git" "$NVIM_CONFIG/install.sh"

# 提前 clone lazy.nvim
LAZYPATH="$HOME/.local/share/nvim/lazy/lazy.nvim"
if [ ! -d "$LAZYPATH" ]; then
  echo "==> 下载 lazy.nvim..."
  retry_cmd 3 git clone --filter=blob:none --branch=stable \
    "${GITHUB_MIRROR}/folke/lazy.nvim.git" "$LAZYPATH"
fi

echo "==> 安装插件（无头模式）..."
retry_cmd 3 "$NVIM_BIN" --headless "+Lazy! sync" +qa

if [ "$GITHUB_MIRROR" != "https://github.com" ]; then
  echo "==> 额外检查 GitHub 官方源..."
  if probe_url "https://github.com"; then
    echo "    官方源可用，切换为 GitHub 重试插件同步..."
    GITHUB_MIRROR="https://github.com"
    export GITHUB_MIRROR
    retry_cmd 2 "$NVIM_BIN" --headless "+Lazy! sync" +qa
  fi
fi

echo ""
echo "安装完成！vi / vim / nvim 均可使用。"
