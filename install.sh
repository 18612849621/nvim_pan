#!/usr/bin/env bash
set -e

NVIM_CONFIG="$HOME/.config/nvim"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---------- Homebrew PATH 补全（macOS ARM/Intel）----------
if [ "$(uname -s)" = "Darwin" ]; then
  if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"   # Apple Silicon
  elif [ -x "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"       # Intel Mac
  fi
fi

# ---------- GitHub 镜像检测 ----------
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
    apt)    sudo apt-get install -y neovim ;;
    dnf|yum)
      if ! rpm -q epel-release &>/dev/null; then
        sudo "$pm" install -y epel-release
      fi
      sudo "$pm" install -y neovim ;;
    pacman) sudo pacman -S --noconfirm neovim ;;
    brew)   brew install neovim ;;
    *)      echo "未知包管理器，请手动安装 neovim >= 0.9"; exit 1 ;;
  esac
}

# ---------- 设置 vi/vim 指向 nvim ----------
setup_aliases() {
  local nvim_path="$1"

  if [ "$(uname -s)" = "Darwin" ]; then
    # macOS: 建软链到 ~/bin，避免需要 sudo
    mkdir -p "$HOME/bin"
    for name in vi vim; do
      ln -sf "$nvim_path" "$HOME/bin/$name"
    done
    echo "    vi/vim -> $nvim_path (via $HOME/bin/)"
    case ":$PATH:" in
      *":$HOME/bin:"*) ;;
      *) export PATH="$HOME/bin:$PATH" ;;
    esac
  elif command -v update-alternatives &>/dev/null; then
    sudo update-alternatives --install /usr/bin/vi  vi  "$nvim_path" 60
    sudo update-alternatives --install /usr/bin/vim vim "$nvim_path" 60
    sudo update-alternatives --set vi  "$nvim_path"
    sudo update-alternatives --set vim "$nvim_path"
    echo "    vi/vim -> $nvim_path (via update-alternatives)"
  else
    for name in vi vim; do
      sudo ln -sf "$nvim_path" "/usr/local/bin/$name"
    done
    echo "    vi/vim -> $nvim_path"
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
  if [ -x "/opt/homebrew/bin/nvim" ]; then
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
  install_neovim
  NVIM_BIN="$(find_nvim)"
  if [ -z "$NVIM_BIN" ]; then
    echo "错误: neovim 安装失败"; exit 1
  fi
fi

# 版本检查
NVIM_VER=$("$NVIM_BIN" --version 2>/dev/null | head -1 | sed -E 's/.*NVIM v([0-9]+\.[0-9]+).*/\1/')
MAJOR=$(echo "$NVIM_VER" | cut -d. -f1)
MINOR=$(echo "$NVIM_VER" | cut -d. -f2)
if [ -z "$MAJOR" ] || [ "$MAJOR" -lt 0 ] || { [ "$MAJOR" -eq 0 ] && [ "$MINOR" -lt 9 ]; }; then
  echo "==> neovim 版本过低 ($NVIM_VER)，重新安装..."
  install_neovim
  NVIM_BIN="$(find_nvim)"
  NVIM_VER=$("$NVIM_BIN" --version 2>/dev/null | head -1 | sed -E 's/.*NVIM v([0-9]+\.[0-9]+).*/\1/')
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
  git clone --filter=blob:none --branch=stable \
    "${GITHUB_MIRROR}/folke/lazy.nvim.git" "$LAZYPATH"
fi

echo "==> 安装插件（无头模式）..."
"$NVIM_BIN" --headless "+Lazy! sync" +qa 2>&1 | tail -5

echo ""
echo "安装完成！vi / vim / nvim 均可使用。"
