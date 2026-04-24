return {
  -- ============================================================
  -- Gitsigns
  -- ============================================================
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 500,
      },
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- Navigation
        local function next_hunk()
          if vim.wo.diff then vim.cmd.normal({ "]c", bang = true })
          else gs.next_hunk() end
        end
        local function prev_hunk()
          if vim.wo.diff then vim.cmd.normal({ "[c", bang = true })
          else gs.prev_hunk() end
        end
        map("n", "]h", next_hunk, "Next hunk")
        map("n", "[h", prev_hunk, "Prev hunk")
        map("n", "]g", next_hunk, "Next hunk")
        map("n", "[g", prev_hunk, "Prev hunk")

        -- Actions
        map({ "n", "v" }, "<leader>ghs", "<cmd>Gitsigns stage_hunk<CR>", "Stage hunk")
        map({ "n", "v" }, "<leader>ghr", "<cmd>Gitsigns reset_hunk<CR>", "Reset hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>ghb", function()
          gs.blame_line({ full = true })
        end, "Blame line")
        map("n", "<leader>ghd", gs.diffthis, "Diff this")
        map("n", "<leader>ghD", function()
          gs.diffthis("~")
        end, "Diff this ~")
        map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle blame")
        map("n", "<leader>td", gs.toggle_deleted, "Toggle deleted")

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
      end,
    },
  },

  -- ============================================================
  -- Blame (full gutter blame column)
  -- ============================================================
  {
    "FabijanZulj/blame.nvim",
    cmd = { "BlameToggle" },
    keys = {
      { "<leader>tB", "<cmd>BlameToggle<CR>", desc = "Toggle gutter blame" },
    },
    opts = {
      date_format = "%Y-%m-%d",
      merge_consecutive = true,
      commit_detail_view = "split",
    },
  },

  -- ============================================================
  -- Diffview
  -- ============================================================
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<CR>", desc = "Diffview open" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<CR>", desc = "Diffview file history" },
      { "<leader>gV", "<cmd>DiffviewClose<CR>", desc = "Diffview close" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",
        },
      },
      hooks = {},
    },
  },

  -- ============================================================
  -- Gitlinker (copy/open git URLs)
  -- ============================================================
  {
    "linrongbin16/gitlinker.nvim",
    cmd = "GitLink",
    keys = {
      { "<leader>gy", "<cmd>GitLink<CR>", mode = { "n", "v" }, desc = "GitLink copy" },
      { "<leader>gY", "<cmd>GitLink!<CR>", mode = { "n", "v" }, desc = "GitLink open" },
    },
    opts = {
      router = {
        browse = {},
      },
      message = true,
      console_log = false,
      highlight_duration = 500,
    },
  },

  -- ============================================================
  -- Octo (GitHub in Neovim)
  -- ============================================================
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    keys = {
      { "<leader>Op", "<cmd>Octo pr list<CR>", desc = "Octo: PR list" },
      { "<leader>Oi", "<cmd>Octo issue list<CR>", desc = "Octo: issue list" },
      { "<leader>Or", "<cmd>Octo review start<CR>", desc = "Octo: review start" },
      { "<leader>Oa", "<cmd>Octo assignee add<CR>", desc = "Octo: assignee add" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("octo").setup({
        use_local_fs = false,
        enable_builtin = true,
        default_remote = { "upstream", "origin" },
        ssh_aliases = {},
        picker = "telescope",
        picker_config = {
          use_emojis = true,
        },
        comment_icon = "▎",
        outdated_icon = "󰅒 ",
        resolved_icon = " ",
        reaction_viewer_hint_icon = " ",
        user_icon = " ",
        timeline_marker = " ",
        timeline_indent = "2",
        right_bubble_delimiter = "",
        left_bubble_delimiter = "",
        github_hostname = "",
        snippet_context_lines = 4,
        file_panel = {
          size = 10,
          use_icons = true,
        },
        mappings = {},
      })
    end,
  },
}
