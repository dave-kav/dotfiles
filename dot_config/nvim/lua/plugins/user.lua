-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {

  -- Browse undo history in Telescope with diff preview
  {
    "debugloop/telescope-undo.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    event = "VeryLazy",
    config = function()
      require("telescope").load_extension("undo")
    end,
  },

  -- GitHub PRs and issues natively in nvim
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },

  -- ── IDE Feel ────────────────────────────────────────────────────────────

  -- Inline diagnostic messages as styled virtual text below code
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup()
      vim.diagnostic.config({ virtual_text = false })
    end,
  },

  -- CodeLens-style reference/implementation counts above functions
  {
    "Wansmer/symbol-usage.nvim",
    event = "LspAttach",
    opts = {},
  },

  -- ── Style & Polish ──────────────────────────────────────────────────────

  -- Replaces all vim.ui.select/input prompts with beautiful floating windows
  {
    "stevearc/dressing.nvim",
    lazy = false,
    opts = {},
  },

  -- Smooth animations for cursor and window resize (scroll disabled — causes flicker on search)
  {
    "echasnovski/mini.animate",
    version = false,
    lazy = false,
    opts = {
      scroll = { enable = false },
    },
  },

  -- VS Code-style breadcrumb in winbar: module > Class > method
  {
    "Bekaboo/dropbar.nvim",
    lazy = false,
    opts = {},
  },

  -- Subtle LSP progress spinner in bottom-right while servers load
  {
    "j-hui/fidget.nvim",
    lazy = false,
    opts = {},
  },

  -- Cursor smear trail effect on movement
  {
    "sphamba/smear-cursor.nvim",
    lazy = false,
    opts = {},
  },

  -- Floating filename labels above each split window
  {
    "b0o/incline.nvim",
    lazy = false,
    opts = {},
  },

  -- ── Navigation ──────────────────────────────────────────────────────────

  -- Seamless navigation between nvim splits and zellij panes with Alt+hjkl
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    config = function()
      require("smart-splits").setup({
        multiplexer_integration = "zellij",
      })
      vim.keymap.set("n", "<A-h>", require("smart-splits").move_cursor_left)
      vim.keymap.set("n", "<A-j>", require("smart-splits").move_cursor_down)
      vim.keymap.set("n", "<A-k>", require("smart-splits").move_cursor_up)
      vim.keymap.set("n", "<A-l>", require("smart-splits").move_cursor_right)
    end,
  },

  -- Show current class/function context at top of buffer while scrolling
  {
    "nvim-treesitter/nvim-treesitter-context",
    lazy = false,
    opts = {
      max_lines = 3,
    },
  },

  {
    "linrongbin16/gitlinker.nvim",
    cmd = "GitLink",
    opts = {},
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = { width = 45 },
    },
  },

  -- customize alpha options
  {
    "goolord/alpha-nvim",
    opts = function(_, opts)
      opts.section.header.val = {
        "██╗    ██╗██╗  ██╗██╗   ██╗███╗   ██╗ ██████╗ ████████╗",
        "██║    ██║██║  ██║╚██╗ ██╔╝████╗  ██║██╔═══██╗╚══██╔══╝",
        "██║ █╗ ██║███████║ ╚████╔╝ ██╔██╗ ██║██║   ██║   ██║   ",
        "██║███╗██║██╔══██║  ╚██╔╝  ██║╚██╗██║██║   ██║   ██║   ",
        "╚███╔███╔╝██║  ██║   ██║   ██║ ╚████║╚██████╔╝   ██║   ",
        " ╚══╝╚══╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═══╝ ╚═════╝    ╚═╝   ",
        " ",
        "              ██╗   ██╗██╗███╗   ███╗",
        "              ██║   ██║██║████╗ ████║",
        "              ██║   ██║██║██╔████╔██║",
        "              ╚██╗ ██╔╝██║██║╚██╔╝██║",
        "               ╚████╔╝ ██║██║ ╚═╝ ██║",
        "                ╚═══╝  ╚═╝╚═╝     ╚═╝",
      }
      opts.section.footer.opts.hl = "Normal"
      opts.section.header.opts.hl = "Normal"

      local get_icon = require("astroui").get_icon
      opts.section.buttons.val = {
        opts.button("LDR n  ", get_icon("FileNew", 2, true) .. "New File  "),
        opts.button("LDR f f", get_icon("Search", 2, true) .. "Find File  "),
        opts.button("LDR f o", get_icon("DefaultFile", 2, true) .. "Recents  "),
        opts.button("LDR f w", get_icon("WordFile", 2, true) .. "Find Word  "),
        opts.button("LDR f '", get_icon("Bookmarks", 2, true) .. "Bookmarks  "),
        opts.button("LDR S l", get_icon("Refresh", 2, true) .. "Last Session  "),
        opts.button("LDR P  ", get_icon("Package", 2, true) .. "Projects  "),
      }
      return opts
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    lazy = false,
  },

  {
    "danielfalk/smart-open.nvim",
    branch = "0.2.x",
    config = function() require("telescope").load_extension "smart_open" end,
    dependencies = {
      "kkharji/sqlite.lua",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      { "nvim-telescope/telescope-fzy-native.nvim" },
    },
  },

  {
    "ggandor/leap.nvim",
    lazy = false,
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "storm",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "dark",
      },
    },
  },

  {
    "AstroNvim/astroui",
    opts = {
      colorscheme = "tokyonight-storm",
      highlights = {
        init = {
          WinBar   = { fg = "#7aa2f7", bg = "NONE" },
          WinBarNC = { fg = "#565f89", bg = "NONE" },
        },
      },
    },
  },

  -- Dims inactive split windows to make active pane obvious
  {
    "levouh/tint.nvim",
    lazy = false,
    opts = {
      tint = -30,
      saturation = 0.8,
    },
  },

  -- Visual jump list popup: pick where to jump back/forward to
  {
    "cbochs/portal.nvim",
    keys = {
      { "<C-o>", "<cmd>Portal jumplist backward<cr>", desc = "Portal backward" },
      { "<C-i>", "<cmd>Portal jumplist forward<cr>",  desc = "Portal forward" },
    },
  },

  -- Dims inactive code outside current block for focus
  {
    "folke/twilight.nvim",
    cmd = { "Twilight", "TwilightEnable", "TwilightDisable" },
    opts = {},
  },

  -- Nudges toward better vim motions by blocking inefficient habits
  {
    "m4xshen/hardtime.nvim",
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- Cursor line number colour changes with vim mode (normal/insert/visual)
  {
    "mawkler/modicator.nvim",
    lazy = false,
    opts = {},
  },

  -- Animated indent scope indicator for current block
  {
    "echasnovski/mini.indentscope",
    version = false,
    lazy = false,
    opts = {
      symbol = "│",
      options = { try_as_border = true },
    },
  },

  -- Code refactoring operations (extract function/variable, inline variable)
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    event = "VeryLazy",
    config = function()
      require("refactoring").setup()
      require("telescope").load_extension("refactoring")
    end,
  },

  -- Lightbulb in sign column when code actions are available
  {
    "kosayoda/nvim-lightbulb",
    lazy = false,
    opts = {
      autocmd = { enabled = true },
    },
  },

  -- Preview code action diff before applying (replaces default gra)
  {
    "aznhe21/actions-preview.nvim",
    keys = {
      {
        "gra",
        function() require("actions-preview").code_actions() end,
        mode = { "n", "v" },
        desc = "Code action (preview)",
      },
    },
  },

  -- Better diagnostics/references list
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
  },

  -- Git diff viewer and file history
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  },

  -- Project-wide find & replace with live preview (<leader>sr)
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    opts = {},
    keys = {
      { "<leader>sr", "<cmd>GrugFar<cr>", desc = "Search and replace" },
    },
  },

  -- Highlight other occurrences of word under cursor
  {
    "RRethy/vim-illuminate",
    lazy = false,
    config = function()
      require("illuminate").configure({ delay = 200 })
    end,
  },

  -- Visualise full undo history as a tree (<leader>U)
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = {
      { "<leader>U", "<cmd>UndotreeToggle<cr>", desc = "Undo tree" },
    },
  },

  -- Full linked note system: daily notes, backlinks, tags, graph view
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    cmd = {
      "ObsidianNew", "ObsidianToday", "ObsidianYesterday",
      "ObsidianSearch", "ObsidianQuickSwitch", "ObsidianBacklinks",
      "ObsidianTags", "ObsidianTemplate",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      workspaces = {
        { name = "notes", path = "~/notes" },
      },
      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m-%d",
        template = "daily.md",
      },
      templates = {
        folder = "templates",
      },
      completion = { nvim_cmp = true },
      ui = {
        enable = true,
        checkboxes = {
          [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
          ["x"] = { char = "", hl_group = "ObsidianDone" },
          [">"] = { char = "", hl_group = "ObsidianRightArrow" },
          ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
        },
      },
      follow_url_func = function(url)
        vim.fn.jobstart({ "open", url })
      end,
    },
  },

  -- Live markdown preview in browser (<leader>mp)
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    build = ":call mkdp#util#install()",
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Markdown preview" },
    },
  },

  -- Inline rename preview (replaces default grn prompt)
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    config = function() require("inc_rename").setup() end,
    keys = {
      {
        "grn",
        function() return ":IncRename " .. vim.fn.expand("<cword>") end,
        expr = true,
        desc = "Rename",
      },
    },
  },

  -- Decorated scrollbar showing diagnostics, git hunks, search results
  {
    "lewis6991/satellite.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- Coloured matching brackets per nesting level
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "VeryLazy",
  },

  -- Make your code dissolve into a game of life animation
  {
    "eandrju/cellular-automaton.nvim",
    cmd = "CellularAutomaton",
  },

  -- Fuzzy-searchable command palette for discovering keymaps/commands
  {
    "mrjones2014/legendary.nvim",
    priority = 10000,
    lazy = false,
    dependencies = { "kkharji/sqlite.lua" },
    opts = {
      extensions = {
        which_key = { auto_register = true },
      },
    },
  },
}
