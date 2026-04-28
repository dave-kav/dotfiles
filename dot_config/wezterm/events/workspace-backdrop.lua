local wezterm = require('wezterm')
local projects = require('utils.projects')

local M = {}

-- Cache last workspace per window to avoid redundant backdrop changes
local last_workspace = {}

M.setup = function()
    wezterm.on('update-status', function(window)
        local ok, workspace = pcall(function() return window:active_workspace() end)
        if not ok then return end
        local ok2, win_id = pcall(function() return window:window_id() end)
        if not ok2 then return end

        if last_workspace[win_id] == workspace then
            return
        end
        last_workspace[win_id] = workspace

        pcall(projects.set_workspace_backdrop, window, workspace)
    end)
end

return M
