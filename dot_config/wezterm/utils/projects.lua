local wezterm = require("wezterm")
local backdrops = require("utils.backdrops")
local M = {}

-- Per-workspace backdrop index — stored in wezterm.GLOBAL so it survives config reloads
local function _wb()
	if not wezterm.GLOBAL.workspace_backdrops then
		wezterm.GLOBAL.workspace_backdrops = {}
	end
	return wezterm.GLOBAL.workspace_backdrops
end

M.save_backdrop = function(name, idx)
	_wb()[name] = idx
end

M.set_workspace_backdrop = function(window, name)
	if #backdrops.images == 0 then
		return
	end
	local idx = _wb()[name]
	if not idx then
		local hash = 0
		for i = 1, #name do
			hash = hash + string.byte(name, i) * i
		end
		idx = (hash % #backdrops.images) + 1
	end
	_wb()[name] = idx
	backdrops:set_img(window, idx)
end
local set_workspace_backdrop = M.set_workspace_backdrop

local project_dir = wezterm.home_dir .. "/code"

local function project_dirs()
	local projects = { wezterm.home_dir }

	-- find handles spaces in paths; maxdepth 2 gives top-level + one level deeper
	local handle = io.popen(
		"find " .. project_dir .. " -maxdepth 2 -mindepth 1 -type d 2>/dev/null"
	)
	if handle then
		for dir in handle:lines() do
			table.insert(projects, dir)
		end
		handle:close()
	end

	return projects
end

-- choose_project([opts])
-- opts.new_window = true  → spawn a brand-new WezTerm window for the chosen project
--                           (used by Cmd+N; current window is left untouched)
-- opts.new_window = false → switch the current window to the chosen workspace (default)
M.choose_project = function(opts)
	opts = opts or {}

	return wezterm.action_callback(function(window, pane)
		local dirs = project_dirs()
		local home = wezterm.home_dir
		local lines = { "__new__ New session\xe2\x80\xa6" }  -- "New session…"
		for _, dir in ipairs(dirs) do
			local label = dir == home and "~"
				or (dir:sub(1, #project_dir + 1) == project_dir .. "/" and dir:sub(#project_dir + 2))
				or ("~/" .. dir:sub(#home + 2))
			table.insert(lines, dir .. " " .. label)
		end

		local tmpfile = "/tmp/wezterm-project-picker"
		local result_file = "/tmp/wezterm-project-result-" .. tostring(os.time())

		local f = io.open(tmpfile, "w")
		if f then
			f:write(table.concat(lines, "\n") .. "\n")
			f:close()
		end

		local fzf_cmd = "fzf"
			.. " --with-nth 2.."
			.. " --border rounded"
			.. ' --border-label "  Projects  "'
			.. " --layout reverse"
			.. ' --prompt "  project › "'
			.. ' --pointer "›"'
			.. " --no-info"
			.. " --padding 1,2"
			.. ' --color "border:#5e81ac,label:#88c0d0,prompt:#88c0d0,pointer:#88c0d0"'
			.. " < " .. tmpfile
		local cmd = "selection=$(" .. fzf_cmd .. ")"
			.. " && echo \"$selection\" > " .. result_file
			.. "; exit 0"

		local _, _, new_win = wezterm.mux.spawn_window({
			args = { "/bin/zsh", "-l", "-c", cmd },
		})
		if new_win then
			local ok, gui_win = pcall(function() return new_win:gui_window() end)
			if ok and gui_win then
				gui_win:set_inner_size(750, 400)
			end
		end

		-- Poll for fzf result (window and pane captured as upvalues)
		local poll_count = 0
		local function check_result()
			poll_count = poll_count + 1
			if poll_count > 300 then return end  -- 60s timeout

			local rf = io.open(result_file, "r")
			if not rf then
				wezterm.time.call_after(0.2, check_result)
				return
			end

			local line = rf:read("*line")
			rf:close()
			os.remove(result_file)
			if not line or line == "" then return end

			local id = line:match("^(%S+)")
			if not id then return end

			-- "New session…" — prompt for a name, then create it
			if id == "__new__" then
				window:perform_action(
					wezterm.action.PromptInputLine({
						description = "Session name:",
						action = wezterm.action_callback(function(w, p, name)
							if not name or name == "" then return end
							local c = "zellij attach " .. name .. " 2>/dev/null || zellij -s " .. name .. " -n dev"
							if opts.new_window then
								wezterm.mux.spawn_window({
									workspace = name,
									args = { "/bin/zsh", "-l", "-c", c },
									set_environment_variables = { WEZTERM_SKIP_ZELLIJ = "1" },
								})
							else
								w:perform_action(
									wezterm.action.SwitchToWorkspace({
										name = name,
										spawn = {
											args = { "/bin/zsh", "-l", "-c", c },
											set_environment_variables = { WEZTERM_SKIP_ZELLIJ = "1" },
										},
									}),
									p
								)
							end
							set_workspace_backdrop(w, name)
						end),
					}),
					pane
				)
				return
			end

			-- Project directory selected — id is the full path
			local project_name = id:match("([^/]+)$")
			local c = "zellij list-sessions --no-formatting 2>/dev/null"
				.. " | awk '{print $1}' | grep -qx '" .. project_name .. "'"
				.. " && zellij attach '" .. project_name .. "'"
				.. " || zellij -s '" .. project_name .. "' -n dev"

			if opts.new_window then
				-- Spawn a fresh WezTerm window in the project workspace
				wezterm.mux.spawn_window({
					workspace = project_name,
					cwd = id,
					args = { "/bin/zsh", "-l", "-c", c },
					set_environment_variables = { WEZTERM_SKIP_ZELLIJ = "1" },
				})
				set_workspace_backdrop(window, project_name)
				return
			end

			-- Switch current window to the project workspace
			local workspace_exists = false
			for _, name in ipairs(wezterm.mux.get_workspace_names()) do
				if name == project_name then workspace_exists = true; break end
			end

			if workspace_exists then
				window:perform_action(
					wezterm.action.SwitchToWorkspace({ name = project_name }),
					pane
				)
			else
				window:perform_action(
					wezterm.action.SwitchToWorkspace({
						name = project_name,
						spawn = {
							cwd = id,
							args = { "/bin/zsh", "-l", "-c", c },
							set_environment_variables = { WEZTERM_SKIP_ZELLIJ = "1" },
						},
					}),
					pane
				)
			end
			set_workspace_backdrop(window, project_name)
		end
		wezterm.time.call_after(0.2, check_result)
	end)
end

-- Get active zellij session names
local function zellij_sessions()
	local sessions = {}
	local handle = io.popen('/bin/zsh -l -c "zellij list-sessions --no-formatting 2>/dev/null"')
	if handle then
		for line in handle:lines() do
			local name = line:match("^(%S+)")
			-- Skip dead sessions — they appear as "name [EXITED - ...]"
			local is_dead = line:match("%[EXITED")
			if name and not is_dead then
				table.insert(sessions, name)
			end
		end
		handle:close()
	end
	return sessions
end

M.choose_session = function()
	return wezterm.action_callback(function(window, pane)
		local lines = {}
		local seen = {}

		-- Active WezTerm workspaces first (skip claude-* — those belong to the Claude picker)
		for _, name in ipairs(wezterm.mux.get_workspace_names()) do
			seen[name] = true
			if not name:match("^claude%-") then
				table.insert(lines, "wezterm:" .. name .. " " .. name)
			end
		end

		-- Zellij-only sessions (no WezTerm workspace yet)
		-- Skip claude- sessions — managed via the Claude picker (Cmd+Ctrl+E)
		for _, name in ipairs(zellij_sessions()) do
			if not seen[name] and not name:match("^claude%-") then
				seen[name] = true
				table.insert(lines, "zellij:" .. name .. " " .. name)
			end
		end

		if #lines == 0 then return end

		local tmpfile = "/tmp/wezterm-session-picker"
		local result_file = "/tmp/wezterm-session-result-" .. tostring(os.time())

		local f = io.open(tmpfile, "w")
		if f then
			f:write(table.concat(lines, "\n") .. "\n")
			f:close()
		end

		local fzf_cmd = "fzf"
			.. " --with-nth 2.."
			.. " --border rounded"
			.. ' --border-label "  Sessions  "'
			.. " --layout reverse"
			.. ' --prompt "  workspace › "'
			.. ' --pointer "›"'
			.. " --no-info"
			.. " --padding 1,2"
			.. ' --color "border:#5e81ac,label:#88c0d0,prompt:#88c0d0,pointer:#88c0d0"'
			.. " < " .. tmpfile
		local cmd = "selection=$(" .. fzf_cmd .. ")"
			.. " && echo \"$selection\" > " .. result_file
			.. "; exit 0"

		local _, _, new_win = wezterm.mux.spawn_window({
			args = { "/bin/zsh", "-l", "-c", cmd },
		})
		if new_win then
			local ok, gui_win = pcall(function() return new_win:gui_window() end)
			if ok and gui_win then
				gui_win:set_inner_size(750, 300)
			end
		end

		-- Poll for fzf result (window and pane captured as upvalues)
		local poll_count = 0
		local function check_result()
			poll_count = poll_count + 1
			if poll_count > 300 then return end  -- 60s timeout

			local rf = io.open(result_file, "r")
			if not rf then
				wezterm.time.call_after(0.2, check_result)
				return
			end

			local line = rf:read("*line")
			rf:close()
			os.remove(result_file)

			if not line or line == "" then return end

			local id = line:match("^(%S+)")
			if not id then return end
			local kind, name = id:match("^(%a+):(.+)$")
			if not kind then return end

			if kind == "wezterm" then
				window:perform_action(wezterm.action.SwitchToWorkspace({ name = name }), pane)
			else
				window:perform_action(
					wezterm.action.SwitchToWorkspace({
						name = name,
						spawn = {
							args = { "/bin/zsh", "-l", "-c", "zellij attach " .. name },
							set_environment_variables = { WEZTERM_SKIP_ZELLIJ = "1" },
						},
					}),
					pane
				)
			end
			set_workspace_backdrop(window, name)
		end
		wezterm.time.call_after(0.2, check_result)
	end)
end

return M
