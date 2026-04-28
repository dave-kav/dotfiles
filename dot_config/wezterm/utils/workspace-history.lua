local wezterm = require('wezterm')

local M = {}

-- Tracks the previous workspace name so we can toggle back to it
M.previous = nil
local _current = nil

M.setup = function()
    wezterm.on('update-status', function(window)
        local ok, focused = pcall(function() return window:is_focused() end)
        if not ok or not focused then return end
        local ok2, workspace = pcall(function() return window:active_workspace() end)
        if not ok2 then return end
        if workspace ~= _current then
            M.previous = _current
            _current = workspace
        end
    end)
end

return M
