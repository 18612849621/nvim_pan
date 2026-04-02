# nvim_pan

小潘的 Neovim 配置，基于 lazy.nvim，GitHub Light 主题。

## 安装

```bash
bash install.sh
```

脚本自动安装 neovim、ripgrep，部署配置到 `~/.config/nvim`，国内机器自动切换 GitHub 镜像。
安装后 `vi` / `vim` / `nvim` 均指向 neovim，无需 Nerd Font。

---

## 快捷键

> `<leader>` 为空格键

### 窗口导航

| 快捷键 | 说明 |
|--------|------|
| `Ctrl+h/j/k/l` | 在窗口间移动（左/下/上/右）|

### 文件树

| 快捷键 | 说明 |
|--------|------|
| `<leader>e` | 打开/关闭文件树 |

### Buffer

| 快捷键 | 说明 |
|--------|------|
| `<leader>bn` | 下一个 buffer |
| `<leader>bp` | 上一个 buffer |
| `<leader>bd` | 关闭当前 buffer |
| `<leader>1~9` | 跳转到第 N 个 buffer |

### Telescope 搜索

| 快捷键 | 说明 |
|--------|------|
| `<leader>ff` | 搜索文件名 |
| `<leader>fg` | 全局内容搜索（live grep）|
| `<leader>fb` | 搜索已打开的 buffer |
| `<leader>fh` | 搜索帮助文档 |
| `<leader>fff` | 以光标下单词搜索文件名 |
| `<leader>ffg` | 以光标下单词全局搜索内容 |

### LSP（需打开 C/C++ 文件）

| 快捷键 | 说明 |
|--------|------|
| `gd` | 跳转到定义 |
| `gD` | 跳转到声明 |
| `K` | 查看悬浮文档 |
| `gr` | 查看所有引用 |
| `<leader>f` | 格式化代码 |
| `Space+rn` | 重命名符号 |
| `Space+D` | 跳转到类型定义 |

### 诊断

| 快捷键 | 说明 |
|--------|------|
| `Space+e` | 查看当前行诊断详情 |
| `[d` | 上一个诊断 |
| `]d` | 下一个诊断 |
| `Space+q` | 诊断列表 |

### 编辑

| 快捷键 | 说明 |
|--------|------|
| `<leader>c` | 替换（进入 `:%s/` 模式）|
| `<leader>jq` | 格式化 JSON（需安装 jq）|
| `>` / `<`（Visual）| 缩进/反缩进并保持选中 |
| `gcc` | 注释/取消注释当前行 |
| `gc`（Visual）| 注释/取消注释选中区域 |
