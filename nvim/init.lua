-------------------------------------------------
-- Leader
-------------------------------------------------
vim.g.mapleader = " "

-------------------------------------------------
-- Basic settings
-------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true

-------------------------------------------------
-- Bootstrap lazy.nvim
-------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-------------------------------------------------
-- Plugins
-------------------------------------------------
require("lazy").setup({

  -- Mason
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "phpactor", "lua_ls" },
        automatic_installation = true,
      })
    end,
  },

  -- LSP (Neovim 0.11+)
  {
    "neovim/nvim-lspconfig",
    config = function()

      vim.lsp.start({
        name = "phpactor",
        cmd = { "phpactor" },
        root_dir = vim.loop.cwd,
      })

      vim.lsp.start({
        name = "lua_ls",
        cmd = { "lua-language-server" },
        root_dir = vim.loop.cwd,
      })

    end,
  },

  -- Autocomplete
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        sources = {
          { name = "nvim_lsp" },
        },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
      })
    end,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
    end,
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- Git worktree
  {
    "ThePrimeagen/git-worktree.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("git-worktree").setup()
      require("telescope").load_extension("git_worktree")
    end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

})

-------------------------------------------------
-- Folding (indent)
-------------------------------------------------
vim.opt.foldenable = true
vim.opt.foldlevelstart = 99

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "php", "blade" },
  callback = function()
    vim.opt_local.foldmethod = "indent"
    vim.opt_local.foldlevel = 99
  end,
})

-------------------------------------------------
-- Keymaps
-------------------------------------------------

-- File explorer
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { silent = true })

-- Telescope
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { silent = true })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { silent = true })

-- Git worktree
vim.keymap.set("n", "<leader>gw", "<cmd>Telescope git_worktree git_worktrees<CR>", { silent = true })
vim.keymap.set("n", "<leader>gn", "<cmd>Telescope git_worktree create_git_worktree<CR>", { silent = true })
vim.keymap.set("n", "<C-p>", "<cmd>Telescope find_files<CR>", { silent = true })

-- LSP navigation
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "K", vim.lsp.buf.hover)

-- Folding toggle
vim.keymap.set("n", "<leader>z", "za")
