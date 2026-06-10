-- ==========================================================================
--  Neovim 0.11+ Config (Homebrew/macOS)
-- ==========================================================================

-- ==========================================================================
--  1. Bootstrap Lazy.nvim
-- ==========================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ==========================================================================
--  2. Options
-- ==========================================================================

local opt = vim.opt

-- 显示
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.showmode = false
opt.signcolumn = "yes"            -- 固定 sign column，防止 gitsigns/诊断导致文本跳动
opt.laststatus = 3                -- 全局状态栏（配合 lualine globalstatus）
opt.splitright = true             -- 垂直分屏在右侧
opt.splitbelow = true             -- 水平分屏在下方
opt.scrolloff = 8                 -- 光标上下保留 8 行
opt.sidescrolloff = 8             -- 光标左右保留 8 列
opt.termguicolors = true

-- 缩进
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

-- 搜索
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- 性能 & 行为
opt.undofile = true
opt.timeoutlen = 300
opt.fileformats = "unix,dos"
opt.clipboard = "unnamedplus"     -- 系统剪贴板无缝集成
opt.wrap = false                  -- 代码文件默认不折行

-- ==========================================================================
--  3. Plugins
-- ==========================================================================

require("lazy").setup({
  -- 图标支持（多个插件依赖，直接加载）
  { "nvim-tree/nvim-web-devicons" },

  -- 主题: Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "latte",
        term_colors = true,
        integrations = {
          cmp = true,
          gitsigns = true,
          treesitter = true,
          telescope = { enabled = true },
          which_key = true,
          indent_blankline = { enabled = true },
          native_lsp = { enabled = true },
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- 状态栏
  {
    "nvim-lualine/lualine.nvim",
    opts = { options = { theme = "catppuccin", globalstatus = true } },
  },

  -- 缩进线
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope = { enabled = true },  -- 高亮当前作用域
    },
  },

  -- Git 状态
  { "lewis6991/gitsigns.nvim", opts = {} },

  -- 快捷键提示
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },

  -- 模糊搜索
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Find Buffers" },
    },
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
          },
        },
        file_ignore_patterns = { "node_modules", ".git/" },
      },
      pickers = {
        find_files = {
          find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden", "--exclude", ".git" },
        },
        live_grep = {
          additional_args = function()
            return { "--hidden", "--glob", "!.git" }
          end,
        },
      },
    },
  },

  -- 语法高亮
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local ok, ts = pcall(require, "nvim-treesitter.configs")
      if ok then
        ts.setup({
          ensure_installed = {
            "lua", "vim", "vimdoc", "bash", "markdown", "markdown_inline",
            "python", "json", "yaml", "toml", "html", "css", "javascript",
          },
          highlight = { enable = true },
          indent = { enable = true },
        })
      end
    end,
  },

  -- LSP & 补全
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
                  workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                  },
                },
              }
            end
            vim.lsp.config[server_name] = opts
            vim.lsp.enable(server_name)
          end,
        },
      })

      -- 补全引擎
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args) require("luasnip").lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources(
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" }
        ),
      })
    end,
  },
})

-- ==========================================================================
--  4. Keymaps
-- ==========================================================================

local map = vim.keymap.set

-- 剪贴板（unnamedplus 已启用，以下保留作为显式操作）
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map("n", "<leader>p", '"+p', { desc = "Paste from system clipboard" })
map("n", "<leader>ya", ":%y+<CR>", { desc = "Yank whole file", silent = true })

-- 清除搜索高亮
map("n", "<Esc>", ":nohlsearch<CR><Esc>", { silent = true })

-- ==========================================================================
--  5. AutoCmd
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
