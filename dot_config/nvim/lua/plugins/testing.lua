return {
  -- ============================================================
  -- Neotest
  -- ============================================================
  {
    "nvim-neotest/neotest",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
      "nvim-neotest/nvim-nio",
    },
    keys = {
      {
        "<leader>Tt",
        function()
          require("neotest").run.run()
        end,
        desc = "Test: run nearest",
      },
      {
        "<leader>Tf",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Test: run file",
      },
      {
        "<leader>Ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Test: summary toggle",
      },
      {
        "<leader>To",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Test: output panel toggle",
      },
      {
        "<leader>TS",
        function()
          require("neotest").run.stop()
        end,
        desc = "Test: stop",
      },
      {
        "]t",
        function()
          require("neotest").jump.next({ status = "failed" })
        end,
        desc = "Next failed test",
      },
      {
        "[t",
        function()
          require("neotest").jump.prev({ status = "failed" })
        end,
        desc = "Prev failed test",
      },
    },
    config = function()
      -- Determine python command: use uv if pyproject.toml exists
      local function python_command()
        if vim.fn.filereadable(vim.fn.getcwd() .. "/pyproject.toml") == 1 then
          return { "uv", "run", "python" }
        end
        return { "python" }
      end

      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
            runner = "pytest",
            python = python_command,
            args = {
              "--tb=short",
              "-v",
              "--no-header",
            },
          }),
        },
        discovery = {
          enabled = true,
          concurrent = 1,
        },
        running = {
          concurrent = true,
        },
        summary = {
          animated = true,
          follow = true,
          expand_errors = true,
          mappings = {
            attach = "a",
            clear_marked = "M",
            clear_target = "T",
            debug = "d",
            debug_marked = "D",
            expand = { "<CR>", "<2-LeftMouse>" },
            expand_all = "e",
            help = "?",
            jump = "i",
            mark = "m",
            next_failed = "J",
            output = "o",
            prev_failed = "K",
            run = "r",
            run_marked = "R",
            short = "O",
            stop = "u",
            target = "t",
            watch = "w",
          },
        },
        output = {
          enabled = true,
          open_on_run = "short",
        },
        output_panel = {
          enabled = true,
          open = "botright split | resize 15",
        },
        quickfix = {
          enabled = true,
          open = false,
        },
        status = {
          enabled = true,
          virtual_text = false,
          signs = true,
        },
        icons = {
          child_indent = "│",
          child_prefix = "├",
          collapsed = "─",
          expanded = "╮",
          failed = "",
          final_child_indent = " ",
          final_child_prefix = "╰",
          non_collapsible = "─",
          passed = "",
          running = "󰑮",
          running_animated = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
          skipped = "",
          unknown = "",
          watching = "",
        },
      })
    end,
  },

  -- nio is required by neotest
  { "nvim-neotest/nvim-nio", lazy = true },
  { "antoinemadec/FixCursorHold.nvim", lazy = true },
}
