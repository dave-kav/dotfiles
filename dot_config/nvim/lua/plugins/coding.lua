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

  -- ============================================================
  -- Obsidian (notes)
  -- ============================================================
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "hrsh7th/nvim-cmp",
    },
    keys = {
      { "<leader>Nn", "<cmd>ObsidianNew<CR>", desc = "Obsidian: new note" },
      { "<leader>Nd", "<cmd>ObsidianToday<CR>", desc = "Obsidian: today" },
      { "<leader>Ny", "<cmd>ObsidianYesterday<CR>", desc = "Obsidian: yesterday" },
      { "<leader>Nf", "<cmd>ObsidianSearch<CR>", desc = "Obsidian: search" },
      { "<leader>No", "<cmd>ObsidianQuickSwitch<CR>", desc = "Obsidian: quick switch" },
      { "<leader>Nb", "<cmd>ObsidianBacklinks<CR>", desc = "Obsidian: backlinks" },
      { "<leader>Nt", "<cmd>ObsidianTags<CR>", desc = "Obsidian: tags" },
      { "<leader>Ng", "<cmd>ObsidianTemplate<CR>", desc = "Obsidian: template" },
    },
    opts = {
      workspaces = {
        {
          name = "notes",
          path = "~/notes",
        },
      },
      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m-%d",
        alias_format = "%B %-d, %Y",
        template = "daily.md",
      },
      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },
      mappings = {},
      new_notes_location = "current_dir",
      wiki_link_func = function(opts)
        return require("obsidian.util").wiki_link_id_prefix(opts)
      end,
      preferred_link_style = "wiki",
      disable_frontmatter = false,
      note_frontmatter_func = function(note)
        local out = { id = note.id, aliases = note.aliases, tags = note.tags }
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end
        return out
      end,
      templates = {
        subdir = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
        substitutions = {},
      },
      ui = {
        enable = true,
        update_debounce = 200,
        checkboxes = {
          [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
          ["x"] = { char = "", hl_group = "ObsidianDone" },
          [">"] = { char = "", hl_group = "ObsidianRightArrow" },
          ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
        },
        bullets = { char = "•", hl_group = "ObsidianBullet" },
        external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
        reference_text = { hl_group = "ObsidianRefText" },
        highlight_text = { hl_group = "ObsidianHighlightText" },
        tags = { hl_group = "ObsidianTag" },
        block_ids = { hl_group = "ObsidianBlockID" },
        hl_groups = {
          ObsidianTodo = { bold = true, fg = "#f7768e" },
          ObsidianDone = { bold = true, fg = "#9ece6a" },
          ObsidianRightArrow = { bold = true, fg = "#f7768e" },
          ObsidianTilde = { bold = true, fg = "#ff9e64" },
          ObsidianBullet = { bold = true, fg = "#89ddff" },
          ObsidianRefText = { underline = true, fg = "#c0caf5" },
          ObsidianExtLinkIcon = { fg = "#c0caf5" },
          ObsidianTag = { italic = true, fg = "#89ddff" },
          ObsidianBlockID = { italic = true, fg = "#89ddff" },
          ObsidianHighlightText = { bg = "#75662e" },
        },
      },
      attachments = {
        img_folder = "assets/imgs",
      },
      follow_url_func = function(url)
        vim.fn.jobstart({ "open", url })
      end,
    },
  },

  -- ============================================================
  -- Markdown preview
  -- ============================================================
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", ft = "markdown", desc = "Markdown preview toggle" },
    },
    config = function()
      vim.cmd([[do FileType]])
    end,
  },
}
