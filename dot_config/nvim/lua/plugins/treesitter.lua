return {
  -- ============================================================
  -- Treesitter
  -- ============================================================
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-context",
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "typescript",
          "javascript",
          "tsx",
          "rust",
          "json",
          "jsonc",
          "yaml",
          "html",
          "css",
          "terraform",
          "dockerfile",
          "go",
          "gomod",
          "gowork",
          "bash",
          "python",
          "toml",
          "markdown",
          "markdown_inline",
          "regex",
          "query",
        },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
      })
    end,
  },

  -- ============================================================
  -- Treesitter node navigation: [k / ]k (same as AstroNvim mini.bracketed default)
  -- Jumps between sibling nodes at the same level in the syntax tree
  -- ============================================================
  {
    "nvim-treesitter/nvim-treesitter",  -- already loaded, this just adds keymaps
    keys = {
      {
        "]k",
        function()
          local ts_utils = require("nvim-treesitter.ts_utils")
          local node = ts_utils.get_node_at_cursor()
          if not node then return end
          local next = node:next_named_sibling()
          if next then ts_utils.goto_node(next) end
        end,
        desc = "Next treesitter sibling node",
      },
      {
        "[k",
        function()
          local ts_utils = require("nvim-treesitter.ts_utils")
          local node = ts_utils.get_node_at_cursor()
          if not node then return end
          local prev = node:prev_named_sibling()
          if prev then ts_utils.goto_node(prev) end
        end,
        desc = "Prev treesitter sibling node",
      },
    },
  },

  -- ============================================================
  -- Treesitter textobjects
  -- ============================================================
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local move = require("nvim-treesitter-textobjects.move")
      local select = require("nvim-treesitter-textobjects.select")

      -- Move keymaps
      local move_mappings = {
        goto_next_start = {
          ["]f"] = "@function.outer",
          ["]c"] = "@class.outer",
          ["]a"] = "@parameter.inner",
          ["]I"] = "@conditional.outer",
          ["]l"] = "@loop.outer",
        },
        goto_next_end = {
          ["]F"] = "@function.outer",
          ["]C"] = "@class.outer",
        },
        goto_previous_start = {
          ["[f"] = "@function.outer",
          ["[c"] = "@class.outer",
          ["[a"] = "@parameter.inner",
          ["[I"] = "@conditional.outer",
          ["[l"] = "@loop.outer",
        },
        goto_previous_end = {
          ["[F"] = "@function.outer",
          ["[C"] = "@class.outer",
        },
      }

      for method, mappings in pairs(move_mappings) do
        for key, query in pairs(mappings) do
          vim.keymap.set({ "n", "x", "o" }, key, function()
            move[method](query)
          end, { desc = method .. " " .. query })
        end
      end

      -- Select keymaps (text objects)
      local select_mappings = {
        ["af"] = { "@function.outer", "o" },
        ["if"] = { "@function.inner", "i" },
        ["ac"] = { "@class.outer", "o" },
        ["ic"] = { "@class.inner", "i" },
        ["aa"] = { "@parameter.outer", "o" },
        ["ia"] = { "@parameter.inner", "i" },
        ["ai"] = { "@conditional.outer", "o" },
        ["ii"] = { "@conditional.inner", "i" },
      }

      for key, args in pairs(select_mappings) do
        vim.keymap.set({ "x", "o" }, key, function()
          select.select_textobject(args[1], "textobjects")
        end, { desc = "Select " .. args[1] })
      end
    end,
  },

  -- ============================================================
  -- Indent scope navigation: mini.indentscope
  -- [i = top of indent scope, ]i = bottom of indent scope
  -- ============================================================
  {
    "echasnovski/mini.indentscope",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      symbol = "│",
      options = { try_as_border = true },
      mappings = {
        goto_top = "[i",
        goto_bottom = "]i",
        object_scope = "ii",
        object_scope_with_border = "ai",
      },
    },
    init = function()
      -- Disable for certain filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason", "toggleterm" },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },

  -- ============================================================
  -- Treesitter context
  -- ============================================================
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      enable = true,
      max_lines = 3,
      min_window_height = 0,
      line_numbers = true,
      multiline_threshold = 20,
      trim_scope = "outer",
      mode = "cursor",
      separator = nil,
      zindex = 20,
      on_attach = nil,
    },
  },

  -- ============================================================
  -- Rainbow delimiters
  -- ============================================================
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "VeryLazy",
    config = function()
      local rainbow = require("rainbow-delimiters")
      require("rainbow-delimiters.setup").setup({
        strategy = {
          [""] = rainbow.strategy["global"],
          vim = rainbow.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        priority = {
          [""] = 110,
          lua = 210,
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      })
    end,
  },
}
