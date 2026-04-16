local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true

opt.splitbelow = true
opt.splitright = true

opt.termguicolors = true
opt.updatetime = 300
opt.timeoutlen = 500

opt.undofile = true
opt.clipboard = "unnamedplus"

opt.showmode = false -- lualine shows mode
opt.pumheight = 10
opt.conceallevel = 1 -- for obsidian

opt.fileencoding = "utf-8"
opt.mouse = "a"
opt.cmdheight = 1
opt.laststatus = 3 -- global statusline
opt.winbar = "%{%v:lua.require('dropbar.api').get_winbar()%}" -- dropbar
