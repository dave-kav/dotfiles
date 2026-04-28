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
			if ok and gui_win then gui_win:set_inner_size(750, 400) end
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

-- new_worktree_session(): two-step fzf — pick project, then pick existing branch
-- or type a new name. Creates git worktree at project/.worktrees/<name> and opens
-- a Zellij dev tab named "project/branch". Used by Cmd+T and the session picker.
M.new_worktree_session = function()
	return wezterm.action_callback(function(window, pane)
		local proc = pane:get_foreground_process_name() or ""
		local in_zellij = proc:find("zellij", 1, true) ~= nil
		local session = window:active_workspace()
		local home = wezterm.home_dir
		local code_dir = home .. "/code"
		local dev_layout = home .. "/.config/zellij/layouts/dev.kdl"

		local cwd_uri = pane:get_current_working_dir()
		local cwd = (cwd_uri and cwd_uri.file_path) or home
		local current_project = ""
		if cwd:sub(1, #code_dir + 1) == code_dir .. "/" then
			local rel = cwd:sub(#code_dir + 2)
			current_project = rel:match("^([^/]+/[^/]+)") or rel:match("^([^/]+)") or ""
		end

		local ts = tostring(os.time())
		local result_file = "/tmp/wezterm-worktree-result-" .. ts
		local script_file = "/tmp/wezterm-worktree-" .. ts .. ".zsh"

		local script_lines = {
			"#!/bin/zsh",
			'export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"',
			'code_dir="' .. code_dir .. '"',
			'result_file="' .. result_file .. '"',
			"",
			"# Step 1: pick project",
			'projects=$(find "$code_dir" -maxdepth 3 -name ".git" -type d 2>/dev/null \\',
			'    | sed "s|/.git$||" | sed "s|^$code_dir/||" | sort)',
			'[ -z "$projects" ] && exit 1',
			'project=$(echo "$projects" | fzf \\',
			'    --border rounded --layout reverse --pointer "›" \\',
			'    --border-label "  New Worktree — Project  " --prompt "  project › " \\',
			'    --no-info --padding 1,2 \\',
			'    --color "border:#5e81ac,label:#88c0d0,prompt:#88c0d0,pointer:#88c0d0"'
				.. (current_project ~= "" and (' \\\n    --query "' .. current_project .. '"') or "")
				.. ")",
			'[ -z "$project" ] && exit 0',
			'export project_dir="$code_dir/$project"',
			"",
			"# Step 2: pick existing branch or type a new name",
			'branches=$(git -C "$project_dir" branch --format="%(refname:short)" 2>/dev/null | grep -v "^$" | sort)',
			'fzf_out=$(echo "$branches" | fzf \\',
			'    --border rounded --layout reverse --pointer "›" \\',
			'    --border-label "  New Worktree — Branch  " --prompt "  branch › " \\',
			'    --header "  [local]  ctrl-r: remote branches" \\',
			'    --no-info --padding 1,2 \\',
			'    --color "border:#5e81ac,label:#88c0d0,prompt:#88c0d0,pointer:#88c0d0" \\',
			"    --bind 'ctrl-r:reload(git -C \"$project_dir\" branch -r --format=\"%(refname:short)\" 2>/dev/null | sed \"s|^origin/||\" | grep -v \"^HEAD\" | sort)+change-header(  [remote]  ctrl-l: local branches)' \\",
			"    --bind 'ctrl-l:reload(git -C \"$project_dir\" branch --format=\"%(refname:short)\" 2>/dev/null | grep -v \"^$\" | sort)+change-header(  [local]  ctrl-r: remote branches)' \\",
			'    --print-query)',
			'query=$(echo "$fzf_out" | head -1)',
			'selection=$(echo "$fzf_out" | sed -n "2p")',
			'branch="${selection:-$query}"',
			'[ -z "$branch" ] && exit 0',
			"",
			"# Create worktree (reuse existing if already checked out elsewhere)",
			'worktree_dir="$project_dir/.worktrees/$branch"',
			'if [ ! -d "$worktree_dir" ]; then',
			'    mkdir -p "$project_dir/.worktrees"',
			'    if ! git -C "$project_dir" worktree add "$worktree_dir" "$branch" 2>/dev/null; then',
			"        existing=$(git -C \"$project_dir\" worktree list --porcelain 2>/dev/null \\",
			"            | awk -v b=\"refs/heads/$branch\" '",
			"                /^worktree / { wt = $2 }",
			'                $0 == "branch " b { print wt; exit }',
			"            ')",
			'        if [ -n "$existing" ]; then',
			'            worktree_dir="$existing"',
			'        else',
			'            git -C "$project_dir" worktree add -b "$branch" "$worktree_dir" || exit 1',
			'        fi',
			'    fi',
			'fi',
			"",
			'printf "%s|%s|%s\\n" "$project" "$branch" "$worktree_dir" > "$result_file"',
		}

		local sf = io.open(script_file, "w")
		if sf then sf:write(table.concat(script_lines, "\n") .. "\n"); sf:close() end

		local _, _, new_win = wezterm.mux.spawn_window({
			args = { "/bin/zsh", "-l", script_file },
		})
		if new_win then
			local ok, gui_win = pcall(function() return new_win:gui_window() end)
			if ok and gui_win then gui_win:set_inner_size(750, 400) end
		end

		local poll_count = 0
		local function check_result()
			poll_count = poll_count + 1
			if poll_count > 300 then os.remove(script_file); return end

			local rf = io.open(result_file, "r")
			if not rf then wezterm.time.call_after(0.2, check_result); return end

			local line = rf:read("*line")
			rf:close()
			os.remove(result_file)
			os.remove(script_file)
			if not line or line == "" then return end

			local proj, branch, worktree_dir = line:match("^([^|]+)|([^|]+)|(.+)$")
			if not proj then return end

			local tab_name = proj .. "/" .. branch

			if in_zellij then
				wezterm.run_child_process { "/bin/zsh", "-l", "-c",
					'ZELLIJ_SESSION_NAME="' .. session .. '"'
					.. " zellij action new-tab"
					.. ' --layout "' .. dev_layout .. '"'
					.. ' --name "' .. tab_name .. '"'
					.. ' --cwd "' .. worktree_dir .. '"'
				}
			else
				local zellij_session = proj:gsub("[^%w%-_]", "_")
				window:perform_action(
					wezterm.action.SpawnCommandInNewTab {
						cwd = worktree_dir,
						args = { "/bin/zsh", "-l", "-c",
							'zellij attach --create "' .. zellij_session .. '"'
						},
					},
					pane
				)
			end
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
			.. ' --expect "ctrl-d,ctrl-n"'
			.. ' --header "  ctrl-n: new worktree  ctrl-d: delete session"'
			.. " < " .. tmpfile
		-- --expect outputs the key on line 1, selection on line 2
		local cmd = "result=$(" .. fzf_cmd .. ")"
			.. " && printf '%s\\n' \"$result\" > " .. result_file
			.. "; exit 0"

		local _, _, new_win = wezterm.mux.spawn_window({
			args = { "/bin/zsh", "-l", "-c", cmd },
		})
		if new_win then
			local ok, gui_win = pcall(function() return new_win:gui_window() end)
			if ok and gui_win then gui_win:set_inner_size(750, 300) end
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

			local content = rf:read("*all")
			rf:close()
			os.remove(result_file)
			if not content or content == "" then return end

			-- --expect: line 1 = key pressed ("ctrl-d" or ""), line 2 = selection
			local pressed_key = content:match("^([^\n]*)\n") or ""
			local line = content:match("^[^\n]*\n([^\n]+)") or ""

			if not line or line == "" then return end

			local id = line:match("^(%S+)")
			if not id then return end

			-- ctrl-n: launch new worktree session picker
			if pressed_key == "ctrl-n" then
				window:perform_action(M.new_worktree_session(), pane)
				return
			end

			-- ctrl-d: delete the session
			if pressed_key == "ctrl-d" then
				local kind, name = id:match("^(%a+):(.+)$")
				if kind == "zellij" then
					wezterm.run_child_process { "/bin/zsh", "-l", "-c",
						'zellij delete-session "' .. name .. '" 2>/dev/null'
					}
				end
				-- WezTerm workspaces close naturally when their windows close
				return
			end
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
