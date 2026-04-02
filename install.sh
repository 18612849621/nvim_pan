#!/usr/bin/env bash
set -e

NVIM_CONFIG="$HOME/.config/nvim"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---------- GitHub 镜像检测 ----------
# 测试能否在 3 秒内连上 github.com，否则用国内镜像
detect_github_mirror() {
  if curl -sf --connect-timeout 3 https://github.com >/dev/null 2>&1; then
    echo "https://github.com"
  else
    echo "https://ghproxy.cn/https://github.com"
  fi
}
GITHUB_MIRROR="$(detect_github_mirror)"
export GITHUB_MIRROR
echo "==> GitHub 镜像: $GITHUB_MIRROR"

# ---------- 包管理器检测 ----------
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
  case "$(detect_pkg_manager)" in
    apt)    sudo apt-get install -y "$1" ;;
    dnf)    sudo dnf install -y "$1" ;;
    yum)    sudo yum install -y "$1" ;;
    pacman) sudo pacman -S --noconfirm "$1" ;;
    brew)   brew install "$1" ;;
    *)      echo "无法自动安装 $1，请手动安装"; return 1 ;;
  esac
}

# ---------- 安装 neovim ----------
install_neovim() {
  echo "==> 安装 neovim..."
  local pm
  pm="$(detect_pkg_manager)"
  case "$pm" in
    apt)
      # Ubuntu 22.04+ 仓库版本已 >= 0.9，直接用 apt，避免从 GitHub 下载慢
      sudo apt-get install -y neovim
      ;;
    dnf|yum)
      if ! rpm -q epel-release &>/dev/null; then
        sudo "$pm" install -y epel-release
      fi
      sudo "$pm" install -y neovim
      ;;
    pacman) sudo pacman -S --noconfirm neovim ;;
    brew)   brew install neovim ;;
    *)
      echo "未知包管理器，请手动安装 neovim >= 0.9"
      exit 1
      ;;
  esac
}

# ---------- 设置 vi/vim 指向 nvim ----------
setup_aliases() {
  local nvim_path
  nvim_path="$(command -v nvim)"

  # update-alternatives（Debian/Ubuntu/CentOS）
  if command -v update-alternatives &>/dev/null; then
    sudo update-alternatives --install /usr/bin/vi  vi  "$nvim_path" 60
    sudo update-alternatives --install /usr/bin/vim vim "$nvim_path" 60
    sudo update-alternatives --set vi  "$nvim_path"
    sudo update-alternatives --set vim "$nvim_path"
  else
    # 其他系统：直接建软链
    for name in vi vim; do
      local target="/usr/local/bin/$name"
      sudo ln -sf "$nvim_path" "$target"
    done
  fi
  echo "    vi/vim -> $nvim_path"
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

# ---------- 安装 neovim ----------
if ! command -v nvim &>/dev/null; then
  install_neovim
else
  NVIM_VER=$(nvim --version | head -1 | grep -oP '\d+\.\d+' | head -1)
  MAJOR=$(echo "$NVIM_VER" | cut -d. -f1)
  MINOR=$(echo "$NVIM_VER" | cut -d. -f2)
  if [ "$MAJOR" -lt 1 ] && [ "$MINOR" -lt 9 ]; then
    echo "neovim 版本过低 ($NVIM_VER)，重新安装..."
    install_neovim
  else
    echo "    neovim $NVIM_VER 已满足要求"
  fi
fi

setup_aliases

# ---------- 部署配置 ----------
if [ -d "$NVIM_CONFIG" ]; then
  BACKUP="$HOME/.config/nvim.bak.$(date +%Y%m%d%H%M%S)"
  mv "$NVIM_CONFIG" "$BACKUP"
  echo "==> 旧配置已备份到 $BACKUP"
fi

echo "==> 安装配置..."
cp -r "$REPO_DIR" "$NVIM_CONFIG"
rm -rf "$NVIM_CONFIG/.git" "$NVIM_CONFIG/install.sh"

# 提前 clone lazy.nvim，避免首次启动 bootstrap 报错
LAZYPATH="$HOME/.local/share/nvim/lazy/lazy.nvim"
if [ ! -d "$LAZYPATH" ]; then
  echo "==> 下载 lazy.nvim..."
  git clone --filter=blob:none --branch=stable \
    "${GITHUB_MIRROR}/folke/lazy.nvim.git" "$LAZYPATH"
fi

echo "==> 安装插件（无头模式）..."
nvim --headless "+Lazy! sync" +qa 2>&1 | tail -5

echo ""
echo "安装完成！vi / vim / nvim 均可使用。"
