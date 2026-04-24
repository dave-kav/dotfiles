return {
  -- ============================================================
  -- Telescope + extensions
  -- ============================================================
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fw", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
      { "<leader>fo", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<leader>fu", "<cmd>Telescope undo<CR>", desc = "Undo history" },
      { "<leader>fc", "<cmd>Telescope commands<CR>", desc = "Commands" },
      { "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "Keymaps" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
      { "<leader>f'", "<cmd>Telescope marks<CR>", desc = "Bookmarks/marks" },
      { "<leader>fn", "<cmd>Telescope notify<CR>", desc = "Notifications" },
      { "<leader>fs", "<cmd>Telescope git_status<CR>", desc = "Git status" },
      { "<leader>fr", "<cmd>Telescope resume<CR>", desc = "Resume last picker" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
      "debugloop/telescope-undo.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      telescope.setup({
        defaults = {
          prompt_prefix = "  ",
          selection_caret = " ",
          path_display = { "smart" },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          mappings = {
            i = {
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-x>"] = actions.delete_buffer,
              ["<esc>"] = actions.close,
            },
          },
          file_ignore_patterns = {
            "node_modules",
            ".git/",
            "__pycache__",
            "%.pyc",
            "%.egg-info",
            ".venv",
            "target/",
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          undo = {
            side_by_side = true,
            layout_strategy = "vertical",
            layout_config = {
              preview_height = 0.6,
            },
          },
          smart_open = {
            match_algorithm = "fzf",
          },
        },
      })

      -- Load extensions
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "undo")
      pcall(telescope.load_extension, "smart_open")
      pcall(telescope.load_extension, "refactoring")
    end,
  },

  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    lazy = true,
    cond = function()
      return vim.fn.executable("make") == 1
    end,
  },

  -- ============================================================
  -- Smart open (frecency + fzf)
  -- ============================================================
  {
    "danielfalk/smart-open.nvim",
    branch = "0.2.x",
    keys = {
      {
        "<leader><leader>",
        function()
          require("telescope").extensions.smart_open.smart_open({ cwd_only = true })
        end,
        desc = "Smart open",
      },
    },
    dependencies = {
      "kkharji/sqlite.lua",
      "nvim-telescope/telescope.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
    },
  },

  -- ============================================================
  -- Undo telescope extension
  -- ============================================================
  {
    "debugloop/telescope-undo.nvim",
    lazy = true,
    dependencies = { "nvim-telescope/telescope.nvim" },
  },

  -- ============================================================
  -- Motion: leap
  -- ============================================================
  {
    url = "https://codeberg.org/andyg/leap.nvim",
    event = "VeryLazy",
    config = function()
      require("leap").add_default_mappings()
    end,
  },

  -- ============================================================
  -- Portal: jumplist navigation
  -- ============================================================
  {
    "cbochs/portal.nvim",
    keys = {
      {
        "<C-o>",
        function()
          require("portal.builtin").jumplist.tunnel_backward()
        end,
        desc = "Portal backward",
      },
      {
        "<C-i>",
        function()
          require("portal.builtin").jumplist.tunnel_forward()
        end,
        desc = "Portal forward",
      },
    },
    opts = {
      window_options = {
        border = "rounded",
      },
    },
  },

  -- ============================================================
  -- Search & replace: grug-far
  -- ============================================================
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      { "<leader>sr", "<cmd>GrugFar<CR>", desc = "Search & replace (GrugFar)" },
    },
    opts = {
      headerMaxWidth = 80,
    },
  },

  -- ============================================================
  -- CSV viewer
  -- ============================================================
  {
    "hat0uma/csvview.nvim",
    ft = { "csv", "tsv" },
    keys = {
      { "<leader>tc", "<cmd>CsvViewToggle<CR>", ft = "csv", desc = "Toggle CSV view" },
    },
    opts = {
      parser = { async = true },
      view = { display_mode = "border" },
    },
  },

  -- ============================================================
  -- Autosave
  -- ============================================================
  {
    "okuuva/auto-save.nvim",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      enabled = true,
      trigger_events = {
        immediate_save = { "BufLeave", "FocusLost" },
        defer_save = { "InsertLeave", "TextChanged" },
        cancel_deferred_save = { "InsertEnter" },
      },
      debounce_delay = 2000,
      condition = function(buf)
        local fn = vim.fn
        local utils = require("auto-save.utils.data")
        -- Only save named, modifiable, normal buffers
        if fn.getbufvar(buf, "&modifiable") == 1
          and utils.not_in(fn.getbufvar(buf, "&filetype"), {
            "oil", "neo-tree", "TelescopePrompt", "lazy", "mason",
            "alpha", "dashboard", "harpoon", "help", "toggleterm",
          })
          and fn.bufname(buf) ~= ""
        then
          return true
        end
        return false
      end,
      write_all_buffers = false,
      noautocmd = false,
    },
  },

  -- ============================================================
  -- Undotree
  -- ============================================================
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    -- keymap is in keymaps.lua
  },

  -- ============================================================
  -- Twilight (focus mode)
  -- ============================================================
  {
    "folke/twilight.nvim",
    cmd = "Twilight",
    keys = {
      { "<leader>tw", "<cmd>Twilight<CR>", desc = "Twilight toggle" },
    },
    opts = {
      dimming = {
        alpha = 0.25,
        color = { "Normal", "#ffffff" },
        term_bg = "#000000",
      },
      context = 10,
    },
  },

  -- ============================================================
  -- Session management: persistence.nvim
  -- ============================================================
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      dir = vim.fn.stdpath("state") .. "/sessions/",
      options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" },
      pre_save = nil,
    },
    keys = {
      {
        "<leader>Sl",
        function() require("persistence").load({ last = true }) end,
        desc = "Restore last session",
      },
      {
        "<leader>Ss",
        function() require("persistence").load() end,
        desc = "Restore session for cwd",
      },
      {
        "<leader>Sd",
        function() require("persistence").stop() end,
        desc = "Don't save session on exit",
      },
    },
  },

  -- ============================================================
  -- Which-key
  -- ============================================================
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = {
        marks = true,
        registers = true,
        spelling = {
          enabled = true,
          suggestions = 20,
        },
        presets = {
          operators = false,
          motions = false,
          text_objects = false,
          windows = true,
          nav = true,
          z = true,
          g = true,
        },
      },
      win = {
        border = "rounded",
        padding = { 1, 2 },
      },
      layout = {
        align = "center",
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>b", group = "Buffers" },
        { "<leader>f", group = "Find/Files" },
        { "<leader>g", group = "Git" },
        { "<leader>l", group = "LSP" },
        { "<leader>N", group = "Notes (Obsidian)" },
        { "<leader>O", group = "Octo (GitHub)" },
        { "<leader>r", group = "Refactor/Rename" },
        { "<leader>s", group = "Search/Replace" },
        { "<leader>t", group = "Toggle" },
        { "<leader>T", group = "Tests" },
        { "<leader>x", group = "Diagnostics/Trouble" },
        { "<leader>d", group = "Diagnostics" },
        { "<leader>S", group = "Sessions" },
        { "<leader>w", group = "Windows/Save" },
      })
    end,
  },
}
