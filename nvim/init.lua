-------------------------------------------------
-- Leader
-------------------------------------------------
vim.g.mapleader = " "

-------------------------------------------------
-- Basic settings
-------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true

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
  -- Treesitter (syntax highlight)
  -------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    priority = 100,
    opts = {
      ensure_installed = {
        "lua", "vim", "vimdoc",
        "go",
        "php",        -- ✅ PHP
        "html",       -- ✅ Blade/Laravel
        "css",        -- ✅ CSS
        "javascript", -- ✅ JS (usado no Laravel frontend)
        "json",       -- ✅ JSON
      },
      auto_install = true,
      highlight = { enable = true }
    }
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

      -- PHP + Laravel (phpactor)
      vim.lsp.config("phpactor", {
        init_options = {
          ["language_server_phpstan.enabled"] = false,
          ["language_server_psalm.enabled"]   = false,
        }
      })
      vim.lsp.enable("phpactor")
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
        ensure_installed = {
          "gopls",
          "phpactor", -- ✅ PHP LSP
        }
      })
    end
  },

  -------------------------------------------------
  -- Blade (Laravel templates)
  -------------------------------------------------
  {
    "jwalton512/vim-blade",  -- ✅ syntax para arquivos .blade.php
    ft = { "blade" }
  },

  -------------------------------------------------
  -- Autocomplete
  -------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",        -- ✅ snippets no autocomplete
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
          ["<Tab>"]     = cmp.mapping(function(fallback)  -- ✅ Tab para navegar snippets
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

-- File explorer
vim.keymap.set("n", "<leader>e",  "<cmd>NvimTreeToggle<CR>",                                      { silent = true })

-- Telescope
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>",                                { silent = true })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",                                 { silent = true })
vim.keymap.set("n", "<C-p>",      "<cmd>Telescope find_files<CR>",                                { silent = true })

-- Git worktree
vim.keymap.set("n", "<leader>gw", "<cmd>Telescope git_worktree git_worktrees<CR>",                { silent = true })
vim.keymap.set("n", "<leader>gn", "<cmd>Telescope git_worktree create_git_worktree<CR>",          { silent = true })

-- LSP navigation
vim.keymap.set("n", "gd",         vim.lsp.buf.definition,                                         { silent = true })
vim.keymap.set("n", "gr",         vim.lsp.buf.references,                                         { silent = true })
vim.keymap.set("n", "K",          vim.lsp.buf.hover,                                              { silent = true })

-- Folding toggle
vim.keymap.set("n", "<leader>z",  "za",                                                            { silent = true })
