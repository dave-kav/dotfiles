local wezterm = require('wezterm')
local projects = require('utils.projects')

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

        projects.set_workspace_backdrop(window, workspace)
    end)
end

return M
