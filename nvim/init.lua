-- ==========================================================================
-- Neovim 0.11+ Ultimate Stable Config (Homebrew/macOS Edition)
-- ==========================================================================

-- 1. 基础引导 (Bootstrap Lazy.nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 设置 Leader 键 (必须在加载插件前)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ==========================================================================
-- 2. 基础选项 (Options - 对应原 nix 配置)
-- ==========================================================================
local opt = vim.opt

opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.showmode = false      -- 状态栏已有模式显示
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = false
opt.autoindent = true
opt.fileformats = "unix,dos"
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.undofile = true
opt.timeoutlen = 300

-- ==========================================================================
-- 3. 插件配置 (Plugins)
-- ==========================================================================
require("lazy").setup({
  -- 图标支持
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- 主题: Catppuccin (Latte)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "latte",
        transparent_background = false,
        term_colors = true,
        integrations = {
          cmp = true,
          gitsigns = true,
          treesitter = true,
          telescope = { enabled = true },
          which_key = true,
          indent_blankline = { enabled = true },
          native_lsp = {
            enabled = true,
            underlines = {
              errors = { "undercurl" },
              hints = { "undercurl" },
              warnings = { "undercurl" },
              information = { "undercurl" },
            },
          },
        },
      })
      vim.cmd.colorscheme "catppuccin"
    end,
  },

  -- 状态栏: Lualine
  {
    "nvim-lualine/lualine.nvim",
    opts = { options = { theme = "catppuccin", globalstatus = true } },
  },

  -- 缩进线: Indent Blankline
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = { indent = { char = "│" } } },

  -- Git 状态: Gitsigns
  { "lewis6991/gitsigns.nvim", opts = { signs = { add = { text = "+" }, change = { text = "~" }, delete = { text = "-" } } } },

  -- 快捷键提示: Which-Key
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },

  -- 模糊搜索: Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
    },
  },

  -- 语法高亮: Treesitter (修复新版模块路径问题)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- 使用 pcall 兼容 Treesitter 可能出现的模块更名
      local ok, ts_configs = pcall(require, "nvim-treesitter.configs")
      if ok then
        ts_configs.setup({
          ensure_installed = { "lua", "vim", "vimdoc", "bash", "markdown" },
          highlight = { enable = true },
          indent = { enable = true },
        })
      end
    end,
  },

  -- LSP & 自动补全 (0.11+ Native 模式)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/nvim-cmp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      require("mason").setup()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      require("mason-lspconfig").setup({
        ensure_installed = { "bashls", "lua_ls" },
        handlers = {
          function(server_name)
            local opts = { capabilities = capabilities }
            if server_name == "lua_ls" then
              opts.settings = {
                Lua = {
                  diagnostics = { globals = { "vim" } },
                  workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
                },
              }
            end
            -- Neovim 0.11+ 原生启用方式 (取代 .setup())
            vim.lsp.config[server_name] = opts
            vim.lsp.enable(server_name)
          end,
        }
      })

      -- 补全引擎配置
      local cmp = require("cmp")
      cmp.setup({
        snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({ { name = "nvim_lsp" }, { name = "path" }, { name = "buffer" } }),
      })
    end,
  },
})

-- ==========================================================================
-- 4. 键位映射 (Keymaps - 与原 Nix 配置保持 1:1)
-- ==========================================================================
local map = vim.keymap.set

-- 剪贴板交互
map({"n", "v"}, "<leader>y", '"+y', { desc = "Copy to System" })
map("n", "<leader>p", '"+p', { desc = "Paste from System" })
map("n", "<leader>ya", ':%y+<CR>', { desc = "Copy whole file", silent = true })

-- 辅助：ESC 清除搜索高亮
map("n", "<Esc>", ":nohlsearch<CR><Esc>", { silent = true })

-- Caps Lock 开启时的 Normal 模式修复 (A-Z 映射为 a-z)
local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
for i = 1, #letters do
  local c = letters:sub(i, i)
  -- 排除常用的大写键
  if not (c == "G" or c == "V" or c == "C" or c == "R") then
    map("n", c, c:lower(), { noremap = true, silent = true })
  end
end

-- ==========================================================================
-- 5. 自动命令 (AutoCmd)
-- ==========================================================================
-- 恢复上次退出时的光标位置
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
