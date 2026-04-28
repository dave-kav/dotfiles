local wezterm = require('wezterm')
local Cells = require('utils.cells')

local nf = wezterm.nerdfonts
local attr = Cells.attr

local M = {}

local GLYPH_SEMI_CIRCLE_LEFT = nf.ple_left_half_circle_thick --[[ '' ]]
local GLYPH_SEMI_CIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[ '' ]]
local GLYPH_KEY_TABLE = nf.md_table_key --[[ '󱏅' ]]
local GLYPH_KEY = nf.md_key --[[ '󰌆' ]]

---@type table<string, Cells.SegmentColors>
local colors = {
   default = { bg = '#fab387', fg = '#1c1b19' },
   scircle = { bg = 'rgba(0, 0, 0, 0.4)', fg = '#fab387' },
}

local cells = Cells:new()

cells
   :add_segment(1, GLYPH_SEMI_CIRCLE_LEFT, colors.scircle, attr(attr.intensity('Bold')))
   :add_segment(2, ' ', colors.default, attr(attr.intensity('Bold')))
   :add_segment(3, ' ', colors.default, attr(attr.intensity('Bold')))
   :add_segment(4, GLYPH_SEMI_CIRCLE_RIGHT, colors.scircle, attr(attr.intensity('Bold')))

M.setup = function()
   wezterm.on('update-right-status', function(window, _pane)
      local ok_kt, name = pcall(function() return window:active_key_table() end)
      local ok_li, leader = pcall(function() return window:leader_is_active() end)
      if not ok_kt and not ok_li then return end

      local res = {}

      if ok_kt and name then
         cells
            :update_segment_text(2, GLYPH_KEY_TABLE)
            :update_segment_text(3, ' ' .. string.upper(name))
         res = cells:render_all()
      end

      if ok_li and leader then
         cells:update_segment_text(2, GLYPH_KEY):update_segment_text(3, ' ')
         res = cells:render_all()
      end
      pcall(function() window:set_left_status(wezterm.format(res)) end)
   end)
end

return M
