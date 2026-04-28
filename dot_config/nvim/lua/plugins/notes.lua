return {
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
      {
        "<leader>Nc",
        function()
          vim.ui.input({ prompt = "Ticket ID: " }, function(ticket)
            if not ticket or ticket == "" then return end
            vim.cmd("ObsidianNew oncall/" .. ticket)
            vim.schedule(function()
              vim.cmd("ObsidianTemplate oncall")
            end)
          end)
        end,
        desc = "Obsidian: new on-call entry",
      },
      {
        "<leader>Nj",
        function()
          vim.ui.input({ prompt = "Jira XML path: ", completion = "file" }, function(path)
            if not path or path == "" then return end
            path = vim.fn.expand(path)
            local script = vim.fn.expand("~/notes/scripts/jira_to_oncall.py")
            local out = vim.fn.system({ "python3", script, path, "--overwrite" })
            local ok = vim.v.shell_error == 0
            vim.notify(ok and out:gsub("\n", "") or out, ok and vim.log.levels.INFO or vim.log.levels.ERROR)
            if ok then
              -- Extract ticket ID from output ("Written: .../TICKET.md")
              local ticket = out:match("([A-Z]+-[0-9]+)%.md")
              if ticket then
                vim.cmd("e " .. vim.fn.expand("~/notes/oncall/") .. ticket .. ".md")
              end
            end
          end)
        end,
        desc = "Obsidian: import Jira XML to on-call",
      },
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
