-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "typescript",
      "rust",
      "json",
      "yaml",
      "html",
      "terraform",
      "dockerfile",
      "go",
      "bash",
    },
  },
}
