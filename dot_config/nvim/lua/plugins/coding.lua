return {
  -- ============================================================
  -- Refactoring
  -- ============================================================
  {
    "ThePrimeagen/refactoring.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      {
        "<leader>rr",
        function()
          require("telescope").extensions.refactoring.refactors()
        end,
        mode = { "n", "v" },
        desc = "Refactor picker",
      },
      {
        "<leader>re",
        function()
          require("refactoring").refactor("Extract Function")
        end,
        mode = "v",
        desc = "Extract function",
      },
      {
        "<leader>rv",
        function()
          require("refactoring").refactor("Extract Variable")
        end,
        mode = "v",
        desc = "Extract variable",
      },
      {
        "<leader>ri",
        function()
          require("refactoring").refactor("Inline Variable")
        end,
        mode = { "n", "v" },
        desc = "Inline variable",
      },
    },
    config = function()
      require("refactoring").setup({
        prompt_func_return_type = {
          go = false,
          java = false,
          cpp = false,
          c = false,
          h = false,
          hpp = false,
          cxx = false,
        },
        prompt_func_param_type = {
          go = false,
          java = false,
          cpp = false,
          c = false,
          h = false,
          hpp = false,
          cxx = false,
        },
        printf_statements = {},
        print_var_statements = {},
        show_success_message = true,
      })
    end,
  },

  -- ============================================================
  -- Conform (formatting)
  -- ============================================================
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format", "ruff_organize_imports" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        markdown = { "prettier" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        terraform = { "terraform_fmt" },
        go = { "gofmt" },
        rust = { "rustfmt" },
      },
      format_on_save = {
        timeout_ms = 3000,
        lsp_fallback = true,
      },
      formatters = {
        shfmt = {
          prepend_args = { "-i", "2" },
        },
        ruff_format = {
          prepend_args = { "--line-length", "100" },
        },
      },
    },
  },

  -- ============================================================
  -- Direnv integration
  -- ============================================================
  {
    "NotAShelf/direnv.nvim",
    event = "VeryLazy",
    opts = {
      autoload_direnv = true,
      enable_options = true,
    },
  },

  -- ============================================================
  -- Toggleterm
  -- ============================================================
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<C-\\>", "<cmd>ToggleTerm<CR>", desc = "ToggleTerm" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Terminal horizontal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", desc = "Terminal vertical" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", desc = "Terminal float" },
    },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return math.floor(vim.o.columns * 0.5)
        end
      end,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      persist_mode = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      auto_scroll = true,
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
      winbar = {
        enabled = false,
      },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      -- Terminal keymaps (Esc to exit terminal mode)
      function _G.set_terminal_keymaps()
        local map_opts = { buffer = 0 }
        vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], map_opts)
        vim.keymap.set("t", "jk", [[<C-\><C-n>]], map_opts)
        vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], map_opts)
        vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], map_opts)
        vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], map_opts)
        vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], map_opts)
      end

      vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
    end,
  },

  -- ============================================================
  -- Cellular automaton (fun)
  -- ============================================================
  {
    "eandrju/cellular-automaton.nvim",
    cmd = "CellularAutomaton",
    -- keymap is in keymaps.lua
  },

}
