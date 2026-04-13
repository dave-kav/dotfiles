return {
    "akinsho/toggleterm.nvim",
    opts = {
        options = {
            g = {
                toggleterm_size = function(term)
                    if term.direction == "horizontal" then
                        return 15
                    elseif term.direction == "vertical" then
                        return math.floor(vim.o.columns * 0.5) -- 25% of screen width
                    end
                end,
            },
        },
    },
}
