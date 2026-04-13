-- Runs last in the setup process.

-- -----------------------------------------
-- Python LSP — mirrors neovim-configs/whatnot
-- Install: uv tool install ruff && uv tool install zuban
-- -----------------------------------------

-- Ruff: diagnostics and formatting only (no completion or go-to-definition)
vim.lsp.config("ruff", {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
})
vim.lsp.enable("ruff")

-- Zuban: completion, go-to-definition, hover only
-- Formatting and diagnostics explicitly disabled (ruff owns those)
vim.lsp.config("zubanls", {
  cmd = { "zuban", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", ".git" },
  on_attach = function(client, _)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    client.server_capabilities.diagnosticProvider = nil
  end,
})
vim.lsp.enable("zubanls")

-- Override Neovim 0.11 built-in gr* defaults with Telescope popups
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local buf = args.buf
    local tb = require("telescope.builtin")
    vim.keymap.set("n", "grr", tb.lsp_references, { buffer = buf, desc = "References" })
    vim.keymap.set("n", "gri", function() tb.lsp_implementations({ reuse_win = true }) end, { buffer = buf, desc = "Implementation" })
    vim.keymap.set("n", "grt", function() tb.lsp_type_definitions({ reuse_win = true }) end, { buffer = buf, desc = "Type definition" })
  end,
})
