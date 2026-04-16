return {
  -- ============================================================
  -- Mason: LSP/formatter/linter installer
  -- ============================================================
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
      ensure_installed = {
        -- LSP servers
        "basedpyright",
        "ruff",
        "lua-language-server",
        "typescript-language-server", -- installs as ts_ls
        "rust-analyzer",
        "gopls",
        "terraform-ls",
        "bash-language-server",
        "yaml-language-server",
        "json-lsp",
        "html-lsp",
        "css-lsp",
        "dockerfile-language-server",
        "taplo", -- TOML
        -- Formatters
        "stylua",
        "prettier",
        "shfmt",
        -- Linters
        "selene",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
    end,
  },

  -- ============================================================
  -- Mason-lspconfig bridge
  -- ============================================================
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "basedpyright",
        "ruff",
        "lua_ls",
        "ts_ls",
        "rust_analyzer",
        "gopls",
        "terraformls",
        "bashls",
        "yamlls",
        "jsonls",
        "html",
        "cssls",
        "dockerls",
        "taplo",
      },
      automatic_installation = true,
    },
  },

  -- ============================================================
  -- nvim-lspconfig
  -- ============================================================
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lsp = require("lsp")

      -- Global defaults for all servers
      vim.lsp.config("*", {
        capabilities = lsp.capabilities,
        on_attach = lsp.on_attach,
      })

      -- --------------------------------------------------------
      -- Python: basedpyright
      -- --------------------------------------------------------
      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "openFilesOnly",
              useLibraryCodeForTypes = true,
              typeCheckingMode = "standard",
            },
          },
        },
      })

      -- --------------------------------------------------------
      -- Python: ruff (disable hover, basedpyright handles it)
      -- --------------------------------------------------------
      vim.lsp.config("ruff", {
        on_attach = function(client, bufnr)
          client.server_capabilities.hoverProvider = false
          lsp.on_attach(client, bufnr)
        end,
        init_options = {
          settings = { args = {} },
        },
      })

      -- --------------------------------------------------------
      -- Lua
      -- --------------------------------------------------------
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
            format = { enable = false },
          },
        },
      })

      -- --------------------------------------------------------
      -- TypeScript
      -- --------------------------------------------------------
      vim.lsp.config("ts_ls", {
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "literal",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = false,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      })

      -- --------------------------------------------------------
      -- Rust
      -- --------------------------------------------------------
      vim.lsp.config("rust_analyzer", {
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = { command = "clippy" },
            inlayHints = {
              parameterHints = { enable = false },
            },
          },
        },
      })

      -- --------------------------------------------------------
      -- Go
      -- --------------------------------------------------------
      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            analyses = { unusedparams = true },
            staticcheck = true,
            gofumpt = true,
          },
        },
      })

      -- --------------------------------------------------------
      -- YAML
      -- --------------------------------------------------------
      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            keyOrdering = false,
            format = { enable = true },
            validate = true,
            schemaStore = { enable = false, url = "" },
          },
        },
      })

      -- --------------------------------------------------------
      -- JSON
      -- --------------------------------------------------------
      vim.lsp.config("jsonls", {
        settings = {
          json = {
            format = { enable = true },
            validate = { enable = true },
          },
        },
      })

      -- Enable all servers (mason-lspconfig handles installation)
      vim.lsp.enable({
        "basedpyright", "ruff",
        "lua_ls", "ts_ls", "rust_analyzer", "gopls",
        "terraformls", "bashls", "yamlls", "jsonls",
        "html", "cssls", "dockerls", "taplo",
      })
    end,
  },

  -- ============================================================
  -- none-ls (formatters/linters via LSP interface)
  -- ============================================================
  {
    "nvimtools/none-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          -- Lua
          null_ls.builtins.formatting.stylua,
          -- Shell
          null_ls.builtins.formatting.shfmt,
          -- Python diagnostics supplement (ruff LSP handles most things)
          -- null_ls.builtins.diagnostics.ruff, -- avoid double-reporting with ruff LSP
        },
        on_attach = function(client, bufnr)
          -- Auto-format on save for supported buffers
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                -- Defer to conform if available
                if not pcall(require, "conform") then
                  vim.lsp.buf.format({ bufnr = bufnr, async = false })
                end
              end,
            })
          end
        end,
      })
    end,
  },

  -- ============================================================
  -- Tiny inline diagnostics (replaces virtual_text)
  -- ============================================================
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup({
        signs = {
          left = "",
          right = "",
          diag = "●",
          arrow = "    ",
          up_arrow = "    ",
          vertical = " │",
          vertical_end = " └",
        },
        hi = {
          error = "DiagnosticError",
          warn = "DiagnosticWarn",
          info = "DiagnosticInfo",
          hint = "DiagnosticHint",
          arrow = "NonText",
          background = "CursorLine",
          mixing_color = "None",
        },
        blend = {
          factor = 0.27,
        },
        options = {
          show_source = false,
          throttle = 20,
          softwrap = 15,
          multiple_diag_under_cursor = true,
          multilines = false,
          show_all_diags_on_cursorline = false,
          enable_on_insert = false,
          overflow = {
            mode = "wrap",
          },
          break_line = {
            enabled = false,
            after = 30,
          },
          virt_texts = {
            priority = 2048,
          },
        },
      })
    end,
  },

  -- ============================================================
  -- Trouble (diagnostics window)
  -- ============================================================
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      modes = {
        lsp = {
          win = { position = "right" },
        },
      },
    },
  },

  -- ============================================================
  -- Actions preview
  -- ============================================================
  {
    "aznhe21/actions-preview.nvim",
    lazy = true,
    opts = {
      telescope = {
        sorting_strategy = "ascending",
        layout_strategy = "vertical",
        layout_config = {
          width = 0.8,
          height = 0.9,
          prompt_position = "top",
          preview_cutoff = 20,
          preview_height = function(_, _, max_lines)
            return max_lines - 15
          end,
        },
      },
    },
  },

  -- ============================================================
  -- Inc-rename
  -- ============================================================
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    opts = {
      input_buffer_type = "dressing",
    },
  },
}
