local wezterm = require("wezterm")
local M = {}

-- Consistent Nord-inspired accent colors used across all pickers
M.colors = "border:#5e81ac,label:#88c0d0,prompt:#88c0d0,pointer:#88c0d0"

-- Build a consistent fzf command string.
-- opts:
--   label    (string) border label text — wrapped in "  …  " automatically
--   prompt   (string) prompt text — gets "  " prefix and " › " suffix
--   with_nth (string) e.g. "2.." to display only certain fields
--   header   (string) header line — gets "  " prefix
--   expect   (string) e.g. "ctrl-d,ctrl-n" for multi-key handling
--   extra    (string) any additional flags appended verbatim
M.cmd = function(opts)
	opts = opts or {}
	local parts = {
		"fzf",
		"--border rounded",
		"--layout reverse",
		'--pointer "›"',
		"--no-info",
		"--padding 1,2",
		'--color "' .. M.colors .. '"',
	}
	if opts.with_nth then table.insert(parts, "--with-nth " .. opts.with_nth) end
	if opts.label    then table.insert(parts, '--border-label "  ' .. opts.label .. '  "') end
	if opts.prompt   then table.insert(parts, '--prompt "  ' .. opts.prompt .. ' › "') end
	if opts.header   then table.insert(parts, '--header "  ' .. opts.header .. '"') end
	if opts.expect   then table.insert(parts, '--expect "' .. opts.expect .. '"') end
	if opts.extra    then table.insert(parts, opts.extra) end
	return table.concat(parts, " ")
end

-- Spawn an fzf popup window, sized proportionally to the active screen.
-- width/height are hints: height >= 380 = "tall" picker, < 380 = "short".
-- Capped at 1200×700 so it doesn't balloon on large monitors.
M.spawn = function(cmd_args, width, height)
	local w, h = width, height
	local ok, screens = pcall(function() return wezterm.gui.screens() end)
	if ok and screens and screens.active then
		local sw = screens.active.width
		local sh = screens.active.height
		w = math.min(math.floor(sw * 0.70), 1200)
		h = math.min(math.floor(sh * (height < 380 and 0.42 or 0.55)), 700)
	end
	local _, _, new_win = wezterm.mux.spawn_window({ args = cmd_args })
	if new_win then
		local ok2, gui_win = pcall(function() return new_win:gui_window() end)
		if ok2 and gui_win then gui_win:set_inner_size(w, h) end
	end
end

-- Poll result_file every 200ms (up to 60s).
-- Calls on_result(content) with the full file contents when it appears.
-- cleanup (optional): list of extra file paths to remove after reading.
M.poll = function(result_file, on_result, cleanup)
	local poll_count = 0
	local function check()
		poll_count = poll_count + 1
		if poll_count > 300 then
			if cleanup then for _, f in ipairs(cleanup) do os.remove(f) end end
			return
		end
		local rf = io.open(result_file, "r")
		if not rf then wezterm.time.call_after(0.2, check); return end
		local content = rf:read("*all")
		rf:close()
		os.remove(result_file)
		if cleanup then for _, f in ipairs(cleanup) do os.remove(f) end end
		if content and content ~= "" then on_result(content) end
	end
	wezterm.time.call_after(0.2, check)
end

return M
