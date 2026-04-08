# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common commands

- Install/deploy this config to `~/.config/nvim` (also installs dependencies and syncs plugins):
  ```bash
  bash install.sh
  ```
- Sync plugins in headless Neovim (same sync command used by `install.sh`):
  ```bash
  nvim --headless "+Lazy! sync" +qa
  ```
- Launch Neovim with the deployed config:
  ```bash
  nvim
  ```

## Linting and tests

- There is no dedicated lint or automated test suite defined in this repository.
- Use headless startup/plugin sync as the primary smoke check after changes:
  ```bash
  nvim --headless "+Lazy! sync" +qa
  ```
- Single-test command: not available in this repo; validate the changed behavior directly inside Neovim.

## High-level architecture

- Entry point: `init.lua`
  - Disables `netrw`/`netrwPlugin` before plugin load (required by `nvim-tree`).
  - Loads `lua/config/options.lua`, then `lua/config/lazy.lua`.

- Plugin bootstrap and loading: `lua/config/lazy.lua`
  - Bootstraps `lazy.nvim` into `stdpath("data")/lazy/lazy.nvim` if missing.
  - Uses `GITHUB_MIRROR` (fallback `https://github.com`) for cloning `lazy.nvim` and for all plugin URLs via `lazy` `git.url_format`.
  - Sets `mapleader`/`maplocalleader` to space.
  - Loads plugin specs from `lua/plugins/*.lua`, then shared mappings from `lua/config/keymaps.lua`.

- Plugin specs are split by responsibility under `lua/plugins/`:
  - `colorscheme.lua`: GitHub Light theme and cursor/cursorline highlight overrides.
  - `ui.lua`: lualine, bufferline, noice.
  - `editor.lua`: nvim-tree, telescope, Comment.nvim, plus telescope keybindings.
  - `lsp.lua`: mason + nvim-lspconfig; currently configures `clangd` and LSP keymaps in `on_attach`.
  - `treesitter.lua`: pinned treesitter config, language list, and disables highlighting for files larger than 100KB.

- Core behavior modules:
  - `lua/config/options.lua`: editor defaults (4-space indentation, relative line numbers, search/split behavior, etc.).
  - `lua/config/keymaps.lua`: global/non-LSP mappings (window navigation, tree toggle, bufferline actions, diagnostics, JSON formatting via `jq`, substitution shortcut).

- Deployment model (`install.sh`):
  - Installs prerequisites (`neovim`, `ripgrep`, etc.) via detected package manager and enforces Neovim >= 0.9.
  - Detects reachable GitHub endpoint and exports `GITHUB_MIRROR`.
  - Copies repository into `~/.config/nvim` (backs up existing config), then removes `.git` and `install.sh` from deployed copy.
  - Runs headless `Lazy! sync` to install/update plugins.
  - Because deployment is copy-based (not symlink-based), edits in this repo require re-running `bash install.sh` to update `~/.config/nvim`.
