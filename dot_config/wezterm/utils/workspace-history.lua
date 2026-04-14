local wezterm = require('wezterm')

local M = {}

-- Tracks the previous workspace name so we can toggle back to it
M.previous = nil
local _current = nil

M.setup = function()
    wezterm.on('update-status', function(window)
        local workspace = window:active_workspace()
        if workspace ~= _current then
            M.previous = _current
            _current = workspace
        end
    end)
end

return M
