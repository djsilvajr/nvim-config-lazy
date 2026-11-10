-------------------------------------------------
-- Leader
-------------------------------------------------
vim.g.mapleader = " "

-------------------------------------------------
-- Basic settings
-------------------------------------------------
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.tabstop        = 4
vim.opt.shiftwidth     = 4
vim.opt.expandtab      = true
vim.opt.termguicolors  = true
vim.opt.clipboard      = "unnamedplus" -- ✅ funciona nos dois SOs

-------------------------------------------------
-- WSL clipboard (só ativa no WSL)
-------------------------------------------------
if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name  = "win32yank",
    copy  = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = 0,
  }
end

-------------------------------------------------
-- Blade filetype detection
-------------------------------------------------
vim.filetype.add({
  pattern = {
    [".*%.blade%.php"] = "blade",
  }
})

-------------------------------------------------
-- JS/TS/React: indentação de 2 espaços
-------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  callback = function()
    vim.bo.tabstop    = 2
    vim.bo.shiftwidth = 2
  end,
})

-------------------------------------------------
-- Lazy bootstrap
-------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-------------------------------------------------
-- Detecta o SO uma vez só
-------------------------------------------------
local is_windows = vim.fn.has("win32") == 1
local is_wsl     = vim.fn.has("wsl")   == 1
local is_linux   = not is_windows and not is_wsl

-------------------------------------------------
-- Plugins
-------------------------------------------------
require("lazy").setup({

  -------------------------------------------------
  -- Colorscheme
  -------------------------------------------------
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme tokyonight-night")
    end
  },

  -------------------------------------------------
  -- Treesitter
  -------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    priority = 100,
    config = function()
      -- O branch main não usa ensure_installed/highlight: os parsers são
      -- instalados pelo Mason (abaixo) e o highlight é ligado por filetype.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "lua", "vim", "help",
          "go",
          "php",
          "html",
          "css",
          "json",
          "javascript", "javascriptreact",
          "typescript", "typescriptreact",
        },
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })

      -- Indentação do JSX/TSX vem do treesitter
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        callback = function()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end
  },

  -------------------------------------------------
  -- Fecha e renomeia tags JSX/TSX/HTML
  -------------------------------------------------
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascriptreact", "typescriptreact" },
    opts = {},
  },

  -------------------------------------------------
  -- LSP
  -------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Go
      vim.lsp.config("gopls", {})
      vim.lsp.enable("gopls")

      if is_windows then
        -- ✅ Windows: intelephense (instalado via npm)
        vim.lsp.config("intelephense", {
          settings = {
            intelephense = {
              files = { maxSize = 5000000 },
            }
          }
        })
        vim.lsp.enable("intelephense")
      else
        -- ✅ Linux/WSL: phpactor (instalado via Mason)
        vim.lsp.config("phpactor", {
          init_options = {
            ["language_server_phpstan.enabled"] = false,
            ["language_server_psalm.enabled"]   = false,
          }
        })
        vim.lsp.enable("phpactor")
      end

      -- ✅ Laravel LSP (funciona nos dois SOs)
      vim.lsp.config("laravel_ls", {})
      vim.lsp.enable("laravel_ls")

      -- ✅ JavaScript, TypeScript e React (funciona nos dois SOs)
      vim.lsp.config("ts_ls", {})
      vim.lsp.enable("ts_ls")

      vim.lsp.config("eslint", {})
      vim.lsp.enable("eslint")
    end
  },

  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()

      local parsers = {
        "lua", "vim", "vimdoc",
        "go",
        "php",
        "html",
        "css",
        "json",
        "javascript", "jsdoc",
        "typescript", "tsx",
      }

      local function install_parsers()
        require("nvim-treesitter").install(parsers)
      end

      -- Ferramentas que não são LSP (o mason-lspconfig não instala estas)
      local registry = require("mason-registry")
      registry.refresh(function()
        local prettier = registry.get_package("prettier")
        if not prettier:is_installed() then
          prettier:install()
        end

        -- O treesitter precisa do tree-sitter-cli para compilar os parsers
        local cli = registry.get_package("tree-sitter-cli")
        if cli:is_installed() then
          vim.schedule(install_parsers)
        else
          cli:install({}, function(success)
            if success then
              vim.schedule(install_parsers)
            end
          end)
        end
      end)
    end
  },

  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        -- ✅ Windows só instala gopls, phpactor só no Linux/WSL
        ensure_installed = is_windows
          and { "gopls", "ts_ls", "eslint" }
          or  { "gopls", "phpactor", "ts_ls", "eslint" },
      })
    end
  },

  -------------------------------------------------
  -- Blade
  -------------------------------------------------
  {
    "jwalton512/vim-blade",
    ft = { "blade" }
  },

  -------------------------------------------------
  -- Snippets
  -------------------------------------------------
  {
    "rafamadriz/friendly-snippets",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end
  },

  -------------------------------------------------
  -- Formatadores (Pint e Prettier)
  -------------------------------------------------
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          php             = { "pint" },
          javascript      = { "prettier" },
          javascriptreact = { "prettier" },
          typescript      = { "prettier" },
          typescriptreact = { "prettier" },
        },
        formatters = {
          -- Só formata projetos que têm configuração do Prettier
          prettier = { require_cwd = true },
        },
        -- Evita aviso a cada save em projetos sem Prettier
        notify_no_formatters = false,
        format_on_save   = { timeout_ms = 2000 },
      })
    end
  },

  -------------------------------------------------
  -- Autocomplete
  -------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip"  },
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
        })
      })
    end
  },

  -------------------------------------------------
  -- File tree
  -------------------------------------------------
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
    end
  },

  -------------------------------------------------
  -- Telescope
  -------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" }
  },

  -------------------------------------------------
  -- Git worktree
  -------------------------------------------------
  {
    "ThePrimeagen/git-worktree.nvim",
    config = function()
      require("git-worktree").setup()
      require("telescope").load_extension("git_worktree")
    end
  },

  -------------------------------------------------
  -- Git signs
  -------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end
  },

  -------------------------------------------------
  -- Autopairs
  -------------------------------------------------
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end
  }

})

-------------------------------------------------
-- Keymaps
-------------------------------------------------
vim.keymap.set("n", "<leader>e",  "<cmd>NvimTreeToggle<CR>",                             { silent = true })
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>",                       { silent = true })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",                        { silent = true })
vim.keymap.set("n", "<C-p>",      "<cmd>Telescope find_files<CR>",                       { silent = true })
vim.keymap.set("n", "<leader>gw", "<cmd>Telescope git_worktree git_worktrees<CR>",       { silent = true })
vim.keymap.set("n", "<leader>gn", "<cmd>Telescope git_worktree create_git_worktree<CR>", { silent = true })
vim.keymap.set("n", "gd",         vim.lsp.buf.definition,                                { silent = true })
vim.keymap.set("n", "gr",         vim.lsp.buf.references,                                { silent = true })
vim.keymap.set("n", "K",          vim.lsp.buf.hover,                                     { silent = true })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,                               { silent = true })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,                                    { silent = true })
vim.keymap.set("n", "<leader>d",  vim.diagnostic.open_float,                             { silent = true })
vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev,                              { silent = true })
vim.keymap.set("n", "]d",         vim.diagnostic.goto_next,                              { silent = true })
vim.keymap.set("n", "<leader>z",  "za",                                                   { silent = true })

-- Copiar caminho / nome do arquivo para o clipboard
local function copy_to_clipboard(value, label)
  if value == "" then
    vim.notify("Buffer sem arquivo", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", value)
  vim.notify(label .. " copiado: " .. value)
end
vim.keymap.set("n", "<leader>yp", function() copy_to_clipboard(vim.fn.expand("%:p"), "Caminho") end,
  { silent = true, desc = "Copiar caminho completo do arquivo" })
vim.keymap.set("n", "<leader>yn", function() copy_to_clipboard(vim.fn.expand("%:t"), "Nome") end,
  { silent = true, desc = "Copiar nome do arquivo" })
