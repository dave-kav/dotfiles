return {
  -- ============================================================
  -- Neo-tree file explorer
  -- ============================================================
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      {
        "<leader>e",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
        end,
        desc = "Neo-tree toggle",
      },
      {
        "<leader>o",
        function()
          local manager = require("neo-tree.sources.manager")
          local renderer = require("neo-tree.ui.renderer")
          -- Check if neo-tree window is open and focused
          local state = manager.get_state("filesystem")
          local is_neotree_win = vim.bo.filetype == "neo-tree"
          if is_neotree_win then
            -- If in neo-tree, jump to previous window
            vim.cmd("wincmd p")
          else
            -- Try to find a neo-tree window
            local window_exists = renderer.window_exists(state)
            if window_exists then
              -- Focus neo-tree
              require("neo-tree.command").execute({ action = "focus", source = "filesystem" })
            else
              -- Open and focus neo-tree
              require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
            end
          end
        end,
        desc = "Neo-tree focus toggle",
      },
    },
    init = function()
      -- If opened with a directory argument, use neo-tree
      if vim.fn.argc(-1) == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("neo-tree")
        end
      end
    end,
    opts = {
      sources = { "filesystem", "buffers", "git_status" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true,
        },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = {
            ".git",
            ".DS_Store",
            "__pycache__",
          },
          never_show = {
            ".git",
            ".DS_Store",
          },
        },
      },
      window = {
        position = "left",
        width = 45,
        mappings = {
          ["<space>"] = "none",
          ["Y"] = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            vim.fn.setreg("+", path, "c")
            vim.notify("Copied path: " .. path)
          end,
        },
      },
      default_component_configs = {
        indent = {
          indent_size = 2,
          padding = 1,
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
          highlight = "NeoTreeIndentMarker",
          with_expanders = nil,
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "󰜌",
          provider = function(icon, node, _)
            if node.type == "file" or node.type == "terminal" then
              local success, web_devicons = pcall(require, "nvim-web-devicons")
              local name = node.type == "terminal" and "terminal" or node.name
              if success then
                local devicon, hl = web_devicons.get_icon(name)
                icon.text = devicon or icon.text
                icon.highlight = hl or icon.highlight
              end
            end
          end,
          default = "*",
          highlight = "NeoTreeFileIcon",
        },
        modified = {
          symbol = "[+]",
          highlight = "NeoTreeModified",
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
          highlight = "NeoTreeFileName",
        },
        git_status = {
          symbols = {
            added = "",
            modified = "",
            deleted = "✖",
            renamed = "󰁕",
            untracked = "",
            ignored = "",
            unstaged = "󰄱",
            staged = "",
            conflict = "",
          },
        },
      },
      event_handlers = {
        -- Auto-close neo-tree when opening a file
        {
          event = "file_opened",
          handler = function(_)
            require("neo-tree.command").execute({ action = "close" })
          end,
        },
      },
    },
  },
}
