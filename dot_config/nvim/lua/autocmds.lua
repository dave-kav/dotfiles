local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ============================================================
-- Highlight on yank
-- ============================================================
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = "YankHighlight",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- ============================================================
-- Resize splits when window is resized
-- ============================================================
augroup("ResizeSplits", { clear = true })
autocmd("VimResized", {
  group = "ResizeSplits",
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- ============================================================
-- Strip trailing whitespace on save
-- ============================================================
augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
  group = "TrimWhitespace",
  pattern = "*",
  callback = function()
    local ft = vim.bo.filetype
    local ignore = { "markdown", "diff" }
    for _, v in ipairs(ignore) do
      if ft == v then
        return
      end
    end
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- ============================================================
-- CursorHold diagnostic float (with filetype guard)
-- ============================================================
augroup("DiagnosticFloat", { clear = true })
autocmd("CursorHold", {
  group = "DiagnosticFloat",
  callback = function()
    local ft = vim.bo.filetype
    local ignore_fts = { "neo-tree", "lazy", "mason", "toggleterm", "TelescopePrompt", "help", "qf" }
    for _, v in ipairs(ignore_fts) do
      if ft == v then
        return
      end
    end
    vim.diagnostic.open_float(nil, {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = "rounded",
      source = "always",
      prefix = " ",
      scope = "cursor",
    })
  end,
})

-- ============================================================
-- Auto-create parent dirs on save
-- ============================================================
augroup("AutoCreateDir", { clear = true })
autocmd("BufWritePre", {
  group = "AutoCreateDir",
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- ============================================================
-- Set filetype-specific options
-- ============================================================
augroup("FileTypeOptions", { clear = true })
autocmd("FileType", {
  group = "FileTypeOptions",
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})
autocmd("FileType", {
  group = "FileTypeOptions",
  pattern = { "python" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

-- ============================================================
-- Close certain filetypes with 'q'
-- ============================================================
augroup("CloseWithQ", { clear = true })
autocmd("FileType", {
  group = "CloseWithQ",
  pattern = {
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "startuptime",
    "checkhealth",
    "neotest-output",
    "neotest-output-panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
})
