local map = vim.keymap.set

-- ============================================================
-- General
-- ============================================================
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Quit all" })

-- ============================================================
-- Buffers
-- ============================================================
map("n", "<leader>bn", "<cmd>enew<CR>", { desc = "New buffer" })
map("n", "<leader>c", function()
  local buf = vim.api.nvim_get_current_buf()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  if #bufs > 1 then
    vim.cmd("bprevious")
  end
  vim.api.nvim_buf_delete(buf, { force = false })
end, { desc = "Close buffer" })

-- Navigate buffers
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
map("n", "]B", "<cmd>blast<CR>", { desc = "Last buffer" })
map("n", "[B", "<cmd>bfirst<CR>", { desc = "First buffer" })

-- Navigate tabs
map("n", "]t", "<cmd>tabnext<CR>", { desc = "Next tab" })
map("n", "[t", "<cmd>tabprevious<CR>", { desc = "Prev tab" })
map("n", "]T", "<cmd>tablast<CR>", { desc = "Last tab" })
map("n", "[T", "<cmd>tabfirst<CR>", { desc = "First tab" })

-- Navigate quickfix
map("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix" })
map("n", "[q", "<cmd>cprevious<CR>", { desc = "Prev quickfix" })
map("n", "]Q", "<cmd>clast<CR>", { desc = "Last quickfix" })
map("n", "[Q", "<cmd>cfirst<CR>", { desc = "First quickfix" })

-- ============================================================
-- Window management
-- ============================================================
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split horizontal" })
map("n", "<leader>se", "<C-w>=", { desc = "Equal window sizes" })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close window" })

-- Navigate Neovim splits (Ctrl+hjkl)
map("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower split" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper split" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

-- ============================================================
-- Move lines
-- ============================================================
map("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- ============================================================
-- Indenting in visual mode
-- ============================================================
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- ============================================================
-- Better up/down (handle wrapped lines)
-- ============================================================
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- ============================================================
-- Insert mode escape sequences
-- ============================================================
map("i", "jj", "<Esc>", { desc = "Exit insert mode" })
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- ============================================================
-- Misc
-- ============================================================
map("n", "<leader>U", "<cmd>UndotreeToggle<CR>", { desc = "Undotree toggle" })
map("n", "<leader>fml", "<cmd>CellularAutomaton make_it_rain<CR>", { desc = "Make it rain" })
