return {
  -- ============================================================
  -- Dependencies shared across UI plugins
  -- ============================================================
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "nvim-lua/plenary.nvim", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },

  -- ============================================================
  -- Noice: floating cmdline, search, notifications
  -- ============================================================
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        progress = { enabled = false }, -- fidget handles this
      },
      presets = {
        bottom_search = false,
        command_palette = true,   -- cmdline + popupmenu together
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = true,
      },
      routes = {
        -- Suppress common noise
        { filter = { event = "msg_show", find = "written" }, opts = { skip = true } },
        { filter = { event = "msg_show", find = "^/" }, opts = { skip = true } },
      },
    },
  },

  -- ============================================================
  -- Dashboard: alpha-nvim
  -- ============================================================
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
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

      dashboard.section.buttons.val = {
        dashboard.button("n",   "  New File",           "<cmd>enew<CR>"),
        dashboard.button("SPC SPC", "  Smart Open",     "<cmd>lua require('telescope').extensions.smart_open.smart_open({ cwd_only = true })<CR>"),
        dashboard.button("SPC f f", "  Find File",      "<cmd>Telescope find_files<CR>"),
        dashboard.button("SPC f o", "  Recent Files",   "<cmd>Telescope oldfiles<CR>"),
        dashboard.button("SPC f w", "  Find Word",      "<cmd>Telescope live_grep<CR>"),
        dashboard.button("SPC f '", "  Bookmarks",      "<cmd>Telescope marks<CR>"),
        dashboard.button("q",   "  Quit",               "<cmd>qa<CR>"),
      }

      dashboard.section.header.opts.hl = "Normal"
      dashboard.section.footer.opts.hl = "Normal"
      dashboard.section.buttons.opts.hl = "Normal"

      alpha.setup(dashboard.opts)

      -- Don't show dashboard when opening a file directly
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = math.floor(stats.startuptime * 100) / 100
          dashboard.section.footer.val = "  " .. stats.count .. " plugins loaded in " .. ms .. "ms"
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },

  -- ============================================================
  -- Colorscheme: Tokyo Night Storm
  -- ============================================================
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "storm",
      transparent = true,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        sidebars = "transparent",
        floats = "dark",
      },
      on_highlights = function(hl, _)
        hl.WinBar = { fg = "#7aa2f7", bg = "NONE" }
        hl.WinBarNC = { fg = "#565f89", bg = "NONE" }
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-storm")
    end,
  },

  -- ============================================================
  -- Statusline: lualine
  -- ============================================================
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "tokyonight",
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "lazy", "alpha" } },
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          { "branch", icon = "" },
          {
            "diff",
            symbols = { added = " ", modified = " ", removed = " " },
          },
          {
            "diagnostics",
            symbols = { error = " ", warn = " ", info = " ", hint = "󰠠 " },
          },
        },
        lualine_c = {
          { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
        },
        lualine_x = {
          {
            function()
              local ok, conform = pcall(require, "conform")
              if not ok then return "" end
              local formatters = conform.list_formatters()
              if #formatters == 0 then return "" end
              local names = vim.tbl_map(function(f) return f.name end, formatters)
              return "󰉢 " .. table.concat(names, ", ")
            end,
            cond = function()
              return vim.bo.filetype ~= ""
            end,
          },
          {
            function()
              local clients = vim.lsp.get_active_clients({ bufnr = 0 })
              if #clients == 0 then return "" end
              local names = vim.tbl_map(function(c) return c.name end, clients)
              return " " .. table.concat(names, ", ")
            end,
            cond = function()
              return next(vim.lsp.get_active_clients({ bufnr = 0 })) ~= nil
            end,
          },
          "encoding",
          "fileformat",
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
    },
  },

  -- ============================================================
  -- Buffer tabs: bufferline
  -- NOTE: navigation.lua also references bufferline for keymap wiring
  -- ============================================================
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local ok, bufferline = pcall(require, "bufferline")
      if not ok then return end

      local colors = require("tokyonight.colors").setup({ style = "storm" })

      local opts = {
        options = {
          mode = "buffers",
          separator_style = "thin",
          always_show_bufferline = false,
          show_buffer_close_icons = true,
          show_close_icon = false,
          color_icons = true,
          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(_, _, diag)
            local icons = { error = " ", warning = " " }
            local ret = (diag.error and icons.error .. diag.error .. " " or "")
              .. (diag.warning and icons.warning .. diag.warning or "")
            return vim.trim(ret)
          end,
          offsets = {
            {
              filetype = "neo-tree",
              text = "  File Explorer",
              highlight = "Directory",
              text_align = "left",
              separator = false,
            },
          },
          indicator = {
            style = "underline",
          },
        },
        highlights = {
          fill = { bg = colors.bg_dark },
          background = { bg = colors.bg_dark, fg = colors.dark3 },
          tab = { bg = colors.bg_dark, fg = colors.dark3 },
          tab_selected = { bg = colors.bg, fg = colors.fg },
          tab_separator = { bg = colors.bg_dark },
          tab_separator_selected = { bg = colors.bg_dark },
          tab_close = { bg = colors.bg_dark },
          buffer_visible = { bg = colors.bg_dark, fg = colors.dark3 },
          buffer_selected = { bg = colors.bg, fg = colors.fg, bold = true, italic = false },
          separator = { bg = colors.bg_dark, fg = colors.bg_dark },
          separator_selected = { bg = colors.bg_dark, fg = colors.bg_dark },
          separator_visible = { bg = colors.bg_dark, fg = colors.bg_dark },
          indicator_selected = { fg = colors.blue, bg = colors.bg },
          modified = { bg = colors.bg_dark, fg = colors.yellow },
          modified_selected = { bg = colors.bg, fg = colors.yellow },
          modified_visible = { bg = colors.bg_dark, fg = colors.yellow },
          close_button = { bg = colors.bg_dark, fg = colors.dark3 },
          close_button_selected = { bg = colors.bg, fg = colors.fg },
          close_button_visible = { bg = colors.bg_dark, fg = colors.dark3 },
          numbers = { bg = colors.bg_dark, fg = colors.dark3 },
          numbers_selected = { bg = colors.bg, fg = colors.fg },
          error = { bg = colors.bg_dark, fg = colors.error },
          error_selected = { bg = colors.bg, fg = colors.error },
          warning = { bg = colors.bg_dark, fg = colors.warning },
          warning_selected = { bg = colors.bg, fg = colors.warning },
          info = { bg = colors.bg_dark, fg = colors.info },
          info_selected = { bg = colors.bg, fg = colors.info },
        },
      }

      bufferline.setup(opts)
    end,
  },

  -- ============================================================
  -- Breadcrumbs: dropbar
  -- ============================================================
  {
    "Bekaboo/dropbar.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    opts = {
      bar = {
        update_debounce = 100,
        enable = function(buf, win)
          local b = vim.bo[buf]
          return not vim.api.nvim_win_get_config(win).zindex
            and b.buftype == ""
            and vim.api.nvim_buf_get_name(buf) ~= ""
            and not b.filetype:find("^neo-tree")
        end,
      },
      icons = {
        ui = { bar = { separator = "  " } },
      },
    },
  },

  -- ============================================================
  -- LSP progress spinner: fidget
  -- ============================================================
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      notification = {
        window = {
          winblend = 0,
        },
      },
    },
  },

  -- ============================================================
  -- UI prompts: dressing
  -- ============================================================
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {
      input = {
        default_prompt = "➤ ",
        win_options = {
          winhighlight = "Normal:Normal,NormalNC:Normal",
        },
      },
      select = {
        backend = { "telescope", "builtin" },
        builtin = {
          win_options = {
            winhighlight = "Normal:Normal,NormalNC:Normal",
          },
        },
      },
    },
  },

  -- ============================================================
  -- Indent guides: indent-blankline
  -- ============================================================
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = {
        enabled = true,
        show_start = false,
        show_end = false,
      },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "lazy",
          "mason",
          "toggleterm",
          "lazyterm",
        },
      },
    },
  },

  -- ============================================================
  -- Floating filename labels: incline
  -- ============================================================
  {
    "b0o/incline.nvim",
    lazy = false,
    priority = 1200,
    config = function()
      local devicons = require("nvim-web-devicons")
      require("incline").setup({
        window = {
          padding = 0,
          margin = { vertical = 0, horizontal = 1 },
        },
        hide = {
          cursorline = false,
          focused_win = false,
          only_win = true,
        },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if filename == "" then
            filename = "[No Name]"
          end
          local ft_icon, ft_color = devicons.get_icon_color(filename)
          local modified = vim.bo[props.buf].modified
          return {
            ft_icon and { " ", ft_icon, " ", guifg = ft_color } or "",
            { filename, gui = modified and "bold,italic" or "bold" },
            modified and { "  ", guifg = "#e0af68" } or "",
            " ",
          }
        end,
      })
    end,
  },

  -- ============================================================
  -- Dim inactive windows: tint
  -- ============================================================
  {
    "levouh/tint.nvim",
    lazy = false,
    config = function()
      require("tint").setup({
        tint = -30,
        saturation = 0.8,
        transforms = require("tint").transforms.SATURATE_TINT,
        tint_background_colors = true,
        highlight_ignore_patterns = { "WinSeparator", "Status.*" },
        window_ignore_function = function(winid)
          local bufid = vim.api.nvim_win_get_buf(winid)
          local buftype = vim.api.nvim_buf_get_option(bufid, "buftype")
          local floating = vim.api.nvim_win_get_config(winid).relative ~= ""
          return buftype == "terminal" or floating
        end,
      })
    end,
  },
}
