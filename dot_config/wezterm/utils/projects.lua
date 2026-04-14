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

	-- Get top-level directories
	local handle = io.popen("ls -d " .. project_dir .. "/* 2>/dev/null")
	if handle then
		for dir in handle:lines() do
			table.insert(projects, dir)

			-- Get one level deeper for each directory
			local sub_handle = io.popen("ls -d " .. dir .. "/* 2>/dev/null")
			if sub_handle then
				for sub_dir in sub_handle:lines() do
					table.insert(projects, sub_dir)
				end
				sub_handle:close()
			end
		end
		handle:close()
	end

	return projects
end

local NEW_SESSION = "  New session…"

M.choose_project = function()
	local choices = { { label = NEW_SESSION, id = "__new__" } }
	for _, value in ipairs(project_dirs()) do
		table.insert(choices, { label = value })
	end

	return wezterm.action.InputSelector({
		title = "Projects",
		choices = choices,
		fuzzy = true,
		action = wezterm.action_callback(function(child_window, child_pane, id, label)
			if not label then
				return
			end

			-- "New session…" — prompt for a name then create it
			if id == "__new__" then
				child_window:perform_action(
					wezterm.action.PromptInputLine({
						description = "Session name:",
						action = wezterm.action_callback(function(w, p, name)
							if not name or name == "" then
								return
							end
							local cmd = "zellij attach " .. name .. " 2>/dev/null || zellij -s " .. name .. " -n dev"
							w:perform_action(
								wezterm.action.SwitchToWorkspace({
									name = name,
									spawn = {
										args = { "/bin/zsh", "-l", "-c", cmd },
										set_environment_variables = { WEZTERM_SKIP_ZELLIJ = "1" },
									},
								}),
								p
							)
							set_workspace_backdrop(w, name)
						end),
					}),
					child_pane
				)
				return
			end

			-- Get the project name from the path
			local project_name = label:match("([^/]+)$")

			-- Attach to existing zellij session (no layout change) or create new one with dev layout
			-- NOTE: `zellij --session name --layout layout` adds to existing session only.
			--       To create a NEW named session with a layout, use: zellij -s name -n layout
			local cmd = "zellij attach " .. project_name .. " 2>/dev/null || zellij -s " .. project_name .. " -n dev"
			local spawn = {
				cwd = label,
				args = { "/bin/zsh", "-l", "-c", cmd },
				set_environment_variables = { WEZTERM_SKIP_ZELLIJ = "1" },
			}

			-- SwitchToWorkspace.spawn only fires for brand-new workspaces.
			-- If the workspace already exists (possibly with the wrong session), we must
			-- switch and then explicitly spawn a tab so the project command always runs.
			local workspace_exists = false
			for _, name in ipairs(wezterm.mux.get_workspace_names()) do
				if name == project_name then
					workspace_exists = true
					break
				end
			end

			if workspace_exists then
				child_window:perform_action(
					wezterm.action.Multiple({
						wezterm.action.SwitchToWorkspace({ name = project_name }),
						wezterm.action.SpawnCommandInNewTab(spawn),
					}),
					child_pane
				)
			else
				child_window:perform_action(
					wezterm.action.SwitchToWorkspace({
						name = project_name,
						spawn = spawn,
					}),
					child_pane
				)
			end

			set_workspace_backdrop(child_window, project_name)
		end),
	})
end

-- Get active zellij session names
local function zellij_sessions()
	local sessions = {}
	local handle = io.popen('/bin/zsh -l -c "zellij list-sessions --no-formatting 2>/dev/null"')
	if handle then
		for line in handle:lines() do
			local name = line:match("^(%S+)")
			if name then
				table.insert(sessions, name)
			end
		end
		handle:close()
	end
	return sessions
end

M.choose_session = function()
	local choices = {}
	local seen = {}

	-- Active WezTerm workspaces first
	for _, name in ipairs(wezterm.mux.get_workspace_names()) do
		seen[name] = true
		table.insert(choices, { label = "  " .. name, id = "wezterm:" .. name })
	end

	-- Zellij-only sessions (no WezTerm workspace yet)
	for _, name in ipairs(zellij_sessions()) do
		if not seen[name] then
			seen[name] = true
			table.insert(choices, { label = "  " .. name, id = "zellij:" .. name })
		end
	end

	return wezterm.action.InputSelector({
		title = "Sessions",
		choices = choices,
		fuzzy = true,
		action = wezterm.action_callback(function(window, pane, id, label)
			if not id then
				return
			end

			local kind, name = id:match("^(%a+):(.+)$")

			if kind == "wezterm" then
				-- Workspace exists, just switch
				window:perform_action(wezterm.action.SwitchToWorkspace({ name = name }), pane)
			else
				-- Zellij session exists but no WezTerm workspace — create one and attach
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
		end),
	})
end

return M
