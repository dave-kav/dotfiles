local wezterm = require('wezterm')
local backdrops = require('utils.backdrops')

local M = {}

-- Cache last workspace per window to avoid redundant backdrop changes
local last_workspace = {}

M.setup = function()
    wezterm.on('update-status', function(window)
        local workspace = window:active_workspace()
        local win_id = window:window_id()

        if last_workspace[win_id] == workspace then
            return
        end
        last_workspace[win_id] = workspace

        if #backdrops.images == 0 then
            return
        end

        -- Deterministically pick a backdrop index from the workspace name
        local hash = 0
        for i = 1, #workspace do
            hash = hash + string.byte(workspace, i) * i
        end
        local idx = (hash % #backdrops.images) + 1
        backdrops:set_img(window, idx)
    end)
end

return M
