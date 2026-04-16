return {
  -- ============================================================
  -- Smart splits (with Zellij multiplexer integration)
  -- ============================================================
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    config = function()
      require("smart-splits").setup({
        -- Ignored filetypes (only while resizing)
        ignored_filetypes = { "nofile", "quickfix", "prompt" },
        -- Ignored buffer types (only while resizing)
        ignored_buftypes = { "nofile" },
        -- The default multiplexer integration
        multiplexer_integration = "zellij",
        -- Resize increment
        default_amount = 3,
        -- When the Zellij integration is used, Zellij will handle moving across pane boundaries
        at_edge = "stop",
        -- Log level
        log_level = "error",
        -- Whether to disable the key mappings
        disable_multiplexer_nav_when_zoomed = true,
        -- Multiplexer nav: use <A-h/j/k/l> for cursor movement across panes
        cursor_follows_swapped_bufs = false,
      })

      -- Move cursor between splits/panes (works with Zellij)
      vim.keymap.set("n", "<A-h>", require("smart-splits").move_cursor_left, { desc = "Move cursor left" })
      vim.keymap.set("n", "<A-j>", require("smart-splits").move_cursor_down, { desc = "Move cursor down" })
      vim.keymap.set("n", "<A-k>", require("smart-splits").move_cursor_up, { desc = "Move cursor up" })
      vim.keymap.set("n", "<A-l>", require("smart-splits").move_cursor_right, { desc = "Move cursor right" })

      -- Resize splits
      vim.keymap.set("n", "<C-A-h>", require("smart-splits").resize_left, { desc = "Resize left" })
      vim.keymap.set("n", "<C-A-j>", require("smart-splits").resize_down, { desc = "Resize down" })
      vim.keymap.set("n", "<C-A-k>", require("smart-splits").resize_up, { desc = "Resize up" })
      vim.keymap.set("n", "<C-A-l>", require("smart-splits").resize_right, { desc = "Resize right" })

      -- Swap buffers between splits
      vim.keymap.set("n", "<leader><A-h>", require("smart-splits").swap_buf_left, { desc = "Swap buf left" })
      vim.keymap.set("n", "<leader><A-j>", require("smart-splits").swap_buf_down, { desc = "Swap buf down" })
      vim.keymap.set("n", "<leader><A-k>", require("smart-splits").swap_buf_up, { desc = "Swap buf up" })
      vim.keymap.set("n", "<leader><A-l>", require("smart-splits").swap_buf_right, { desc = "Swap buf right" })
    end,
  },

  -- ============================================================
  -- Bufferline (tab bar) — navigation keymaps
  -- Full bufferline config is in ui.lua; keymaps added here
  -- ============================================================
  {
    "akinsho/bufferline.nvim",
    optional = true,
    keys = {
      { "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "Pin buffer" },
      { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<CR>", desc = "Close unpinned buffers" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", desc = "Close other buffers" },
      { "<leader>br", "<cmd>BufferLineCloseRight<CR>", desc = "Close buffers to the right" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<CR>", desc = "Close buffers to the left" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<CR>", desc = "Prev buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<CR>", desc = "Prev buffer" },
      { "]b", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
      { "[B", "<cmd>BufferLineMovePrev<CR>", desc = "Move buffer left" },
      { "]B", "<cmd>BufferLineMoveNext<CR>", desc = "Move buffer right" },
    },
  },
}
