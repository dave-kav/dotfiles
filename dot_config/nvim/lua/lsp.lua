local M = {}

-- ============================================================
-- Capabilities (extended with nvim-cmp)
-- ============================================================
M.capabilities = vim.lsp.protocol.make_client_capabilities()

local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  M.capabilities = cmp_lsp.default_capabilities(M.capabilities)
end

-- ============================================================
-- on_attach: keymaps + LSP features
-- ============================================================
M.on_attach = function(client, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end

  -- Hover / Signature
  map("n", "K", vim.lsp.buf.hover, "LSP Hover")
  map("n", "<C-k>", vim.lsp.buf.signature_help, "LSP Signature help")

  -- Navigation (aligned with Neovim 0.11 gr* conventions, all via Telescope)
  map("n", "gd", function()
    require("telescope.builtin").lsp_definitions({ reuse_win = true })
  end, "LSP Definition")
  map("n", "gD", vim.lsp.buf.declaration, "LSP Declaration")
  map("n", "grr", function()
    require("telescope.builtin").lsp_references({ include_declaration = false })
  end, "LSP References")
  map("n", "gri", function()
    require("telescope.builtin").lsp_implementations({ reuse_win = true })
  end, "LSP Implementation")
  map("n", "gy", function()
    require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
  end, "LSP Type definition")

  -- Rename (inc-rename) — grn (0.11 standard) + <leader>lr
  vim.keymap.set("n", "grn", function()
    return ":IncRename " .. vim.fn.expand("<cword>")
  end, { buffer = bufnr, expr = true, silent = true, desc = "Rename symbol" })
  vim.keymap.set("n", "<leader>lr", function()
    return ":IncRename " .. vim.fn.expand("<cword>")
  end, { buffer = bufnr, expr = true, silent = true, desc = "Rename symbol" })

  -- Code actions — gra (0.11 standard) + <leader>la
  map({ "n", "v" }, "gra", function()
    require("actions-preview").code_actions()
  end, "Code actions")
  map({ "n", "v" }, "<leader>la", function()
    require("actions-preview").code_actions()
  end, "Code actions")

  -- References / navigation under <leader>l
  map("n", "<leader>lR", function()
    require("telescope.builtin").lsp_references({ include_declaration = false })
  end, "References")
  map("n", "<leader>ld", function()
    require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
  end, "Type definition")
  map("n", "<leader>ls", function()
    require("telescope.builtin").lsp_document_symbols()
  end, "Document symbols")
  map("n", "<leader>lS", function()
    vim.ui.input({ prompt = "Symbol query (empty = word under cursor): " }, function(query)
      if query == nil then return end
      if query == "" then query = vim.fn.expand("<cword>") end
      require("telescope.builtin").lsp_workspace_symbols({
        query = query,
        prompt_title = ("Workspace symbols (%s)"):format(query),
      })
    end)
  end, "Workspace symbols")
  map("n", "<leader>lG", function()
    require("telescope.builtin").lsp_dynamic_workspace_symbols()
  end, "Dynamic workspace symbols")
  map("n", "<leader>li", "<cmd>LspInfo<CR>", "LSP info")

  -- Format
  map({ "n", "v" }, "<leader>lf", function()
    require("conform").format({ async = true, lsp_fallback = true })
  end, "Format buffer")

  -- Diagnostics
  map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
  map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
  map("n", "[e", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, "Prev error")
  map("n", "]e", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, "Next error")
  map("n", "[w", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN }) end, "Prev warning")
  map("n", "]w", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN }) end, "Next warning")
  map("n", "<leader>lD", "<cmd>Telescope diagnostics bufnr=0<CR>", "Buffer diagnostics")
  map("n", "<leader>lG", "<cmd>Telescope diagnostics<CR>", "Workspace diagnostics")

  -- Inlay hints
  if client.supports_method("textDocument/inlayHint") and vim.lsp.inlay_hint then
    map("n", "<leader>lh", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
    end, "Toggle inlay hints")
  end

  -- Trouble
  map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", "Trouble: diagnostics")
  map("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", "Trouble: buffer diagnostics")
  map("n", "<leader>xL", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>", "Trouble: LSP")
  map("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", "Trouble: symbols")
end

-- ============================================================
-- Route LSP pickers through Telescope globally
-- Handles cases where vim.lsp.buf.* is called directly (e.g. 0.11 defaults)
-- ============================================================
vim.lsp.handlers["textDocument/references"] = function(_, result, ctx)
  if not result or vim.tbl_isempty(result) then
    vim.notify("No references found", vim.log.levels.INFO)
    return
  end
  require("telescope.builtin").lsp_references()
end

vim.lsp.handlers["textDocument/definition"] = function(_, result, ctx)
  if not result or vim.tbl_isempty(result) then
    vim.notify("No definition found", vim.log.levels.INFO)
    return
  end
  require("telescope.builtin").lsp_definitions({ reuse_win = true })
end

vim.lsp.handlers["textDocument/implementation"] = function(_, result, ctx)
  if not result or vim.tbl_isempty(result) then
    vim.notify("No implementations found", vim.log.levels.INFO)
    return
  end
  require("telescope.builtin").lsp_implementations({ reuse_win = true })
end

-- ============================================================
-- Diagnostic configuration
-- ============================================================
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

-- Diagnostic signs
local signs = {
  Error = " ",
  Warn = " ",
  Hint = "󰠠 ",
  Info = " ",
}
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

return M
