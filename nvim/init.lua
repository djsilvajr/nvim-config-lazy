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
vim.opt.clipboard      = "unnamedplus"
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
-- Lazy bootstrap
-------------------------------------------------
local uv = vim.uv or vim.loop -- compat 0.10/0.11+
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not uv.fs_stat(lazypath) then
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
  -- Treesitter (highlight de Go, PHP, Blade, etc.)
  -- IMPORTANTE:
  --   1. branch = "master"  -> fixa a API clássica. O branch "main"
  --      é a reescrita experimental e NÃO expõe nvim-treesitter.configs.
  --   2. O setup correto fica em nvim-treesitter.configs (não em
  --      nvim-treesitter), por isso usamos main = "nvim-treesitter.configs"
  --      pra o lazy chamar require("nvim-treesitter.configs").setup(opts).
  -------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    lazy = false,
    priority = 100,
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "lua", "vim", "vimdoc",
        "go", "gomod", "gosum", "gowork",
        "php", "phpdoc",
        "html",
        "css",
        "javascript",
        "json",
        "bash",
        "markdown", "markdown_inline",
      },
      auto_install = true,
      sync_install = false,
      highlight = {
        enable = true,
        -- Em arquivos .blade.php deixamos o vim-blade cuidar do realce
        -- principal pra evitar conflito com o parser de PHP do TS.
        additional_vim_regex_highlighting = { "blade" },
      },
      indent = { enable = true },
    },
  },
  -------------------------------------------------
  -- LSP
  -- Requer Neovim 0.11+ por causa de vim.lsp.config / vim.lsp.enable
  -------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Go
      vim.lsp.config("gopls", {})
      vim.lsp.enable("gopls")
      if is_windows then
        -- Windows: intelephense (instalado via npm)
        vim.lsp.config("intelephense", {
          settings = {
            intelephense = {
              files = { maxSize = 5000000 },
            }
          }
        })
        vim.lsp.enable("intelephense")
      else
        -- Linux/WSL: phpactor (instalado via Mason)
        vim.lsp.config("phpactor", {
          init_options = {
            ["language_server_phpstan.enabled"] = false,
            ["language_server_psalm.enabled"]   = false,
          }
        })
        vim.lsp.enable("phpactor")
      end
      -- Laravel LSP (funciona nos dois SOs)
      vim.lsp.config("laravel_ls", {})
      vim.lsp.enable("laravel_ls")
    end
  },
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        -- Windows usa intelephense via npm; Linux/WSL usa phpactor via Mason
        ensure_installed = is_windows
          and { "gopls", "laravel_ls" }
          or  { "gopls", "phpactor", "laravel_ls" },
      })
    end
  },
  -------------------------------------------------
  -- Blade (syntax + ftplugin pra .blade.php)
  -------------------------------------------------
  {
    "jwalton512/vim-blade",
    ft = { "blade" }
  },
  -------------------------------------------------
  -- Formatador (Pint)
  -------------------------------------------------
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = { php = { "pint" } },
        format_on_save   = { timeout_ms = 2000 },
      })
    end
  },
  -------------------------------------------------
  -- Autocomplete (cmp + luasnip + friendly-snippets juntos)
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
      -- Carrega os snippets do friendly-snippets aqui, onde luasnip
      -- garantidamente já existe.
      require("luasnip.loaders.from_vscode").lazy_load()
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
      -- Integração autopairs <-> cmp (fecha parênteses ao confirmar função)
      local ok, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
      if ok then
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
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
-- Diagnostic helpers (compat 0.10/0.11+)
-------------------------------------------------
local function diag_prev()
  if vim.diagnostic.jump then
    vim.diagnostic.jump({ count = -1, float = true })
  else
    vim.diagnostic.goto_prev()
  end
end
local function diag_next()
  if vim.diagnostic.jump then
    vim.diagnostic.jump({ count = 1, float = true })
  else
    vim.diagnostic.goto_next()
  end
end
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
vim.keymap.set("n", "<leader>d",  vim.diagnostic.open_float,                             { silent = true })
vim.keymap.set("n", "[d",         diag_prev,                                             { silent = true })
vim.keymap.set("n", "]d",         diag_next,                                             { silent = true })
vim.keymap.set("n", "<leader>z",  "za",                                                  { silent = true })
