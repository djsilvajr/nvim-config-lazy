# nvim-config-lazy

Configuração do Neovim usando [lazy.nvim](https://github.com/folke/lazy.nvim) como gerenciador de plugins.

Funciona em **Linux, WSL e Windows** com suporte a **Go, PHP/Laravel/Blade** e formatação automática via Laravel Pint.

---

## 📦 Plugins

### Core

| Plugin | Descrição |
|--------|-----------|
| [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim) | Colorscheme |
| [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlight |
| [nvim-tree/nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | Árvore de arquivos |
| [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Busca fuzzy |
| [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Fechamento automático de pares |

### LSP

| Plugin | Descrição |
|--------|-----------|
| [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | Configurações de LSP |
| [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim) | Gerenciador de LSPs/ferramentas |
| [williamboman/mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim) | Integração Mason + lspconfig |
| [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim) | Formatação (Laravel Pint) |

### Autocomplete & Snippets

| Plugin | Descrição |
|--------|-----------|
| [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Engine de autocomplete |
| [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) | Source LSP para cmp |
| [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Engine de snippets |
| [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip) | Source LuaSnip para cmp |
| [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets) | Coleção de snippets |

### Git

| Plugin | Descrição |
|--------|-----------|
| [ThePrimeagen/git-worktree.nvim](https://github.com/ThePrimeagen/git-worktree.nvim) | Git worktrees |
| [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Sinais git no gutter |

### Linguagens

| Plugin | Descrição |
|--------|-----------|
| [jwalton512/vim-blade](https://github.com/jwalton512/vim-blade) | Suporte a Blade (Laravel) |

---

## ⌨️ Keymaps

> `<leader>` = `Space`

### Arquivos & Busca

| Atalho | Ação |
|--------|------|
| `<leader>e` | Abrir/fechar árvore de arquivos |
| `<leader>ff` | Buscar arquivos (Telescope) |
| `<leader>fg` | Buscar texto no projeto (live grep) |
| `<C-p>` | Buscar arquivos (Telescope) |

### LSP

| Atalho | Ação |
|--------|------|
| `gd` | Ir para definição |
| `gr` | Ver referências |
| `K` | Documentação (hover) |
| `<leader>d` | Mostrar diagnóstico (float) |
| `[d` | Diagnóstico anterior |
| `]d` | Próximo diagnóstico |

### Git

| Atalho | Ação |
|--------|------|
| `<leader>gw` | Listar git worktrees |
| `<leader>gn` | Criar git worktree |

### Editor

| Atalho | Ação |
|--------|------|
| `<leader>z` | Toggle fold |

---

## 🚀 Instalação

### 1. Pré-requisitos

Independente do SO, você precisa de:

- **Neovim 0.11+** (a configuração usa `vim.lsp.config` / `vim.lsp.enable`)
- **Git**
- **Compilador C** (para o `nvim-treesitter`)
- **ripgrep** (para `Telescope live_grep`)
- **Node.js + npm** (necessário para o `intelephense` no Windows e útil para alguns LSPs)
- **Go** (para `gopls`)
- **PHP + Composer** *(opcional, apenas se for usar Laravel Pint para formatação)*

#### 🐧 Linux

<details>
<summary><strong>Ubuntu / Debian</strong></summary>

```bash
# Neovim 0.11+ (use o PPA ou AppImage se a versão do apt for antiga)
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install -y neovim

# Demais ferramentas
sudo apt install -y git gcc ripgrep golang nodejs npm
```

</details>

<details>
<summary><strong>Arch / Manjaro</strong></summary>

```bash
sudo pacman -S --needed neovim git gcc ripgrep go nodejs npm
```

</details>

<details>
<summary><strong>Fedora</strong></summary>

```bash
sudo dnf install -y neovim git gcc ripgrep golang nodejs npm
```

</details>

#### 🐧 WSL (Ubuntu)

Use os mesmos comandos do Ubuntu acima e, **adicionalmente**, instale o `win32yank` para que o clipboard do Neovim funcione com o Windows:

```bash
curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip
unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
chmod +x /tmp/win32yank.exe
sudo mv /tmp/win32yank.exe /usr/local/bin/
```

A configuração já detecta o WSL automaticamente e usa o `win32yank` quando ele está disponível.

#### 🪟 Windows (PowerShell como administrador)

```powershell
winget install Neovim.Neovim
winget install Git.Git
winget install BurntSushi.ripgrep.MSVC
winget install GoLang.Go
winget install OpenJS.NodeJS

# Compilador C — escolha UM:
winget install LLVM.LLVM         # recomendado
# winget install MinGW.MinGW     # alternativa
```

> ⚠️ Após instalar o compilador C, **feche e reabra o terminal** para que o `PATH` seja atualizado. Verifique com `gcc --version` ou `clang --version`.

### 2. Instalar a configuração

Coloque o `init.lua` na pasta de configuração do Neovim:

| SO | Caminho |
|---|---|
| Linux / WSL / macOS | `~/.config/nvim/init.lua` |
| Windows | `%LOCALAPPDATA%\nvim\init.lua` |

#### 🐧 Linux / WSL / macOS

```bash
mkdir -p ~/.config/nvim
git clone https://github.com/djsilvajr/nvim-config-lazy.git ~/.config/nvim
```

Ou, se preferir copiar só o arquivo:

```bash
mkdir -p ~/.config/nvim
cp init.lua ~/.config/nvim/init.lua
```

#### 🪟 Windows (PowerShell)

```powershell
New-Item -ItemType Directory -Force "$env:LOCALAPPDATA\nvim" | Out-Null
git clone https://github.com/djsilvajr/nvim-config-lazy.git "$env:LOCALAPPDATA\nvim"
```

### 3. Primeira execução

1. Abra o Neovim:

   ```bash
   nvim
   ```

2. O `lazy.nvim` será baixado automaticamente e instalará todos os plugins. **Aguarde** a conclusão (você verá uma janela com o progresso).

3. Feche o Neovim (`:q`), reabra e rode:

   ```vim
   :Lazy sync
   ```

4. Os parsers do Treesitter são instalados sob demanda (`auto_install = true`). Para instalar tudo de uma vez:

   ```vim
   :TSInstall lua vim vimdoc go php html css javascript json
   ```

### 4. Instalar os LSPs

Os LSPs do Mason são instalados automaticamente pelo `mason-lspconfig` ao abrir o Neovim. Se quiser forçar/conferir:

#### 🐧 Linux / WSL

```vim
:MasonInstall gopls phpactor laravel-ls
```

#### 🪟 Windows

No Windows, o `intelephense` é instalado via `npm` (e não pelo Mason):

```powershell
npm install -g intelephense
```

E dentro do Neovim:

```vim
:MasonInstall gopls laravel-ls
```

### 5. (Opcional) Laravel Pint para formatação PHP

Se você usa Laravel, instale o Pint no projeto:

```bash
composer require laravel/pint --dev
```

Em projetos não-Laravel, instale globalmente:

```bash
composer global require laravel/pint
```

A formatação acontece automaticamente ao salvar arquivos `.php`.

### 6. Verificar a instalação

Dentro do Neovim:

```vim
:checkhealth
```

Confira especialmente as seções `lazy`, `lspconfig`, `mason`, `nvim-treesitter` e `provider`. Tudo verde ou amarelo (warnings) é esperado; vermelho indica algo faltando no PATH.

---

## 🩹 Troubleshooting

| Problema | Solução |
|---|---|
| `lazy.nvim` não baixa | Verifique `git --version` e se há acesso ao GitHub |
| Treesitter falha ao compilar parsers | Compilador C ausente — instale `gcc`/`clang`/`MinGW` e reinicie o terminal |
| `Telescope live_grep` não funciona | Falta o `ripgrep` no PATH |
| `gopls`/`phpactor` não inicia | Rode `:Mason` e confirme que está com status ✓ |
| Clipboard não funciona no WSL | Instale o `win32yank` (ver seção WSL) |
| `intelephense` não funciona no Windows | Confirme `npm root -g` no PATH e rode `npm install -g intelephense` |

---

## 📁 Estrutura

```
nvim/
└── init.lua    # Configuração principal (single-file)
```
