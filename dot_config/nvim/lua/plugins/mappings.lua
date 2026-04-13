return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        -- first key is the mode
        n = {
          -- second key is the lefthand side of the map
          -- mappings seen under group name "Buffer"
          ["<Leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
          ["<Leader>bD"] = {
            function()
              require("astroui.status").heirline.buffer_picker(function(bufnr)
                require("astrocore.buffer").close(bufnr)
              end)
            end,
            desc = "Pick to close",
          },
          -- tables with the `name` key will be registered with which-key if it's installed
          -- this is useful for naming menus
          ["<Leader>b"] = { name = "Buffers" },
          ["<Leader>r"] = { name = "Refactor" },
          ["<Leader>T"] = { name = "Test" },
          ["<Leader>Tt"] = { function() require("neotest").run.run() end,                        desc = "Run nearest test" },
          ["<Leader>Tf"] = { function() require("neotest").run.run(vim.fn.expand("%")) end,      desc = "Run test file" },
          ["<Leader>Ts"] = { function() require("neotest").summary.toggle() end,                 desc = "Test summary" },
          ["<Leader>To"] = { function() require("neotest").output_panel.toggle() end,            desc = "Test output" },
          ["<Leader>TS"] = { function() require("neotest").run.stop() end,                       desc = "Stop tests" },
          ["]t"]         = { function() require("neotest").jump.next({ status = "failed" }) end, desc = "Next failed test" },
          ["[t"]         = { function() require("neotest").jump.prev({ status = "failed" }) end, desc = "Prev failed test" },
          ["<Leader>O"] = { name = "Octo/GitHub" },
          -- quick save
          ["<leader>P"] = {
            function()
              require("projectmgr").open_window()
            end,
            desc = "Open Project Manager",
          },
          -- Find
          ["<leader>fml"] = { "<cmd>CellularAutomaton make_it_rain<cr>", desc = "Make it rain" },
          ["<leader>fu"] = {
            function() require("telescope").extensions.undo.undo() end,
            desc = "Undo history",
          },
          ["<leader>fK"] = {
            function() require("legendary").find() end,
            desc = "Search keymaps/commands (Legendary)",
          },
          -- Git
          ["<leader>gy"] = { "<cmd>GitLink<cr>",  desc = "Copy git link" },
          ["<leader>gY"] = { "<cmd>GitLink!<cr>", desc = "Open git link" },
          ["<leader>gv"] = { "<cmd>DiffviewOpen<cr>",          desc = "Diff view" },
          ["<leader>gH"] = { "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
          -- Terminal
          ["<leader>tw"] = { "<cmd>Twilight<cr>", desc = "Toggle twilight" },
          -- Quickfix/Lists
          ["<leader>xx"] = { "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics" },
          ["<leader>xd"] = { "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
          ["<leader>xL"] = { "<cmd>Trouble lsp toggle<cr>",                      desc = "LSP definitions/references" },
          ["<leader>xs"] = { "<cmd>Trouble symbols toggle<cr>",                  desc = "Symbols" },
          ["<leader><leader>"] = {
            function()
              require("telescope").extensions.smart_open.smart_open({ cwd_only = true })
            end,
            desc = "Smart Open",
          },
          -- Refactor
          ["<leader>rr"] = {
            function() require("telescope").extensions.refactoring.refactors() end,
            desc = "Refactor picker",
          },
          ["<leader>ri"] = {
            function() require("refactoring").refactor("Inline Variable") end,
            desc = "Inline variable",
          },
          -- Notes (obsidian.nvim)
          ["<leader>N"]  = { name = "Notes" },
          ["<leader>Nn"] = { "<cmd>ObsidianNew<cr>",          desc = "New note" },
          ["<leader>Nd"] = { "<cmd>ObsidianToday<cr>",        desc = "Today's daily note" },
          ["<leader>Ny"] = { "<cmd>ObsidianYesterday<cr>",    desc = "Yesterday's note" },
          ["<leader>Nf"] = { "<cmd>ObsidianSearch<cr>",       desc = "Search notes" },
          ["<leader>No"] = { "<cmd>ObsidianQuickSwitch<cr>",  desc = "Open note" },
          ["<leader>Nb"] = { "<cmd>ObsidianBacklinks<cr>",    desc = "Backlinks" },
          ["<leader>Nt"] = { "<cmd>ObsidianTags<cr>",         desc = "Tags" },
          ["<leader>Ng"] = { "<cmd>ObsidianTemplate<cr>",     desc = "Insert template" },
          -- Octo/GitHub
          ["<leader>Op"] = { "<cmd>Octo pr list<cr>",      desc = "List PRs" },
          ["<leader>Oi"] = { "<cmd>Octo issue list<cr>",   desc = "List issues" },
          ["<leader>Or"] = { "<cmd>Octo review start<cr>", desc = "Start review" },
          ["<leader>Oa"] = { "<cmd>Octo assignee add<cr>", desc = "Add assignee" },
        },
        v = {
          ["<leader>gy"] = { "<cmd>GitLink<cr>",  desc = "Copy git link" },
          ["<leader>gY"] = { "<cmd>GitLink!<cr>", desc = "Open git link" },
          -- Refactor (visual)
          ["<leader>rr"] = {
            function() require("telescope").extensions.refactoring.refactors() end,
            desc = "Refactor picker",
          },
          ["<leader>re"] = {
            function() require("refactoring").refactor("Extract Function") end,
            desc = "Extract function",
          },
          ["<leader>rv"] = {
            function() require("refactoring").refactor("Extract Variable") end,
            desc = "Extract variable",
          },
          ["<leader>ri"] = {
            function() require("refactoring").refactor("Inline Variable") end,
            desc = "Inline variable",
          },
        },
        t = {},
      },
    },
  },
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      mappings = {
        n = {
          K = {
            function() vim.lsp.buf.hover() end,
            desc = "Hover symbol details",
          },
          gD = {
            function() vim.lsp.buf.declaration() end,
            desc = "Declaration of current symbol",
            cond = "textDocument/declaration",
          },
        },
      },
    },
  },
}