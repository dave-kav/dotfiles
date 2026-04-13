-- Install LSP servers with: uv tool install ruff && uv tool install zuban
-- LSP (ruff + zubanls) configured in polish.lua
return {
  -- Test runner: inline pass/fail, jump to failures, run test/file/suite
  {
    "nvim-neotest/neotest",
    lazy = true,
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
    },
    opts = function()
      return {
        adapters = {
          require("neotest-python")({
            runner = "pytest",
            python = function()
              -- use uv-managed venv if present, else fall back to system python
              local venv = vim.fn.findfile("pyproject.toml", vim.fn.getcwd() .. ";")
              if venv ~= "" then
                return { "uv", "run", "python" }
              end
              return "python"
            end,
            args = { "--no-header", "-rN" },
          }),
        },
      }
    end,
  },
  {
    "NotAShelf/direnv.nvim",
    lazy = false,
    config = true,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(
          opts.ensure_installed,
          { "python", "toml" }
        )
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        python = { "ruff_format", "ruff_organize_imports" },
      },
    },
  },
}
