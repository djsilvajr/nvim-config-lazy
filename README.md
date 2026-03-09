# nvim-config-lazy

Minha configuração do Neovim usando [lazy.nvim](https://github.com/folke/lazy.nvim) como gerenciador de plugins.

---

## 📦 Plugins

| Plugin | Descrição |
|--------|-----------|
| [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim) | Colorscheme |
| [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlight |
| [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | Configuração de LSP |
| [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim) | Gerenciador de LSPs |
| [williamboman/mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim) | Integração Mason + LSP |
| [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Autocomplete |
| [nvim-tree/nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | Árvore de arquivos |
| [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Busca fuzzy |
| [ThePrimeagen/git-worktree.nvim](https://github.com/ThePrimeagen/git-worktree.nvim) | Git worktrees |
| [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Sinais git no gutter |
| [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Fechamento automático de pares |

---

## ⌨️ Keymaps

| Atalho | Modo | Ação |
|--------|------|------|
| `<leader>e` | Normal | Abrir/fechar árvore de arquivos |
| `<leader>ff` | Normal | Buscar arquivos (Telescope) |
| `<leader>fg` | Normal | Buscar texto no projeto (live grep) |
| `<C-p>` | Normal | Buscar arquivos (Telescope) |
| `<leader>gw` | Normal | Listar git worktrees |
| `<leader>gn` | Normal | Criar git worktree |
| `gd` | Normal | Ir para definição (LSP) |
| `gr` | Normal | Ver referências (LSP) |
| `K` | Normal | Ver documentação (LSP hover) |
| `<leader>z` | Normal | Toggle fold |

> `<leader>` = `Space`

---

## 🚀 Instalação

### Pré-requisitos

#### 🐧 Linux

```bash
# Neovim 0.11+
sudo apt install neovim          # Ubuntu/Debian
sudo pacman -S neovim            # Arch

# Git
sudo apt install git             # Ubuntu/Debian
sudo pacman -S git               # Arch

# Compilador C (para nvim-treesitter)
sudo apt install gcc             # Ubuntu/Debian
sudo pacman -S gcc               # Arch

# ripgrep (para Telescope live_grep)
sudo apt install ripgrep         # Ubuntu/Debian
sudo pacman -S ripgrep           # Arch

# Go (para gopls)
sudo apt install golang          # Ubuntu/Debian
sudo pacman -S go                # Arch

:MasonInstall gopls phpactor
```

#### 🪟 Windows (PowerShell como administrador)

```powershell
# Neovim 0.11+
winget install Neovim.Neovim

# Git
winget install Git.Git

# Compilador C (para nvim-treesitter) — escolha um dos dois
winget install LLVM.LLVM         # Opção 1: LLVM (recomendado)
winget install MinGW.MinGW       # Opção 2: MinGW

# ripgrep (para Telescope live_grep)
winget install BurntSushi.ripgrep.MSVC

# Go (para gopls)
winget install GoLang.Go

:MasonInstall gopls
npm install -g intelephense
```

> ⚠️ **Windows:** Após instalar o compilador C, adicione-o ao PATH e reinicie o terminal.

---

### Configuração

#### 🐧 Linux / Mac

Adicionar init.lua em :

- .config/nvim


#### 🪟 Windows (PowerShell)

Adicionar init.lua em :

- LOCALAPPDATA\nvim

---

### Primeira execução

1. Abra o Neovim:
```bash
nvim
```

2. O lazy.nvim irá instalar todos os plugins automaticamente. Aguarde a conclusão.

3. Feche e reabra o Neovim, depois execute:
```
:Lazy sync
```

4. Os parsers do Treesitter serão instalados automaticamente via `auto_install = true`. Para instalar manualmente:
```
:TSInstall lua vim vimdoc go
```

---

## 📁 Estrutura

```
nvim/
└── init.lua    # Configuração principal
```
