local wezterm = require('wezterm')
local platform = require('utils.platform')
local backdrops = require('utils.backdrops')
local projects = require('utils.projects')
local fzf = require('utils.fzf')
local workspace_history = require('utils.workspace-history')
local act = wezterm.action

local mod = {}

if platform.is_mac then
    mod.SUPER = 'SUPER'
    mod.SUPER_REV = 'SUPER|CTRL'
elseif platform.is_win or platform.is_linux then
    mod.SUPER = 'ALT' -- to not conflict with Windows key shortcuts
    mod.SUPER_REV = 'ALT|CTRL'
end

-- stylua: ignore
local keys = {
    -- misc/useful --
    { key = 'F1', mods = 'NONE', action = 'ActivateCopyMode' },
    { key = 'F2', mods = 'NONE', action = act.ActivateCommandPalette },
    { key = 'F3', mods = 'NONE', action = act.ShowLauncher },
    { key = 'F4', mods = 'NONE', action = act.ShowLauncherArgs({ flags = 'FUZZY|TABS' }) },
    {
        key = 'F5',
        mods = 'NONE',
        action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }),
    },
    { key = 'F11', mods = 'NONE',    action = act.ToggleFullScreen },
    { key = 'f',   mods = 'CTRL|SHIFT', action = act.ToggleFullScreen },
    { key = 'F12', mods = 'NONE',    action = act.ShowDebugOverlay },
    { key = 'f',   mods = mod.SUPER, action = act.Search({ CaseInSensitiveString = '' }) },
    {
        key = 'u',
        mods = mod.SUPER_REV,
        action = wezterm.action_callback(function(window, pane)
            local url = window:get_selection_text_for_pane(pane)
            wezterm.log_info('opening: ' .. url)
            wezterm.open_with(url)
        end),
    },

    { key = 'k', mods = 'CMD', action = act.SendKey { key = 'l', mods = 'CTRL' } },
    -- cursor movement --
    { key = 'LeftArrow',  mods = mod.SUPER,     action = act.SendString '\u{1b}OH' },
    { key = 'RightArrow', mods = mod.SUPER,     action = act.SendString '\u{1b}OF' },
    { key = 'LeftArrow',  mods = 'OPT',         action = act.SendString '\u{1b}b' }, -- Move back one word
    { key = 'RightArrow', mods = 'OPT',         action = act.SendString '\u{1b}f' }, -- Move forward one word

    -- Cmd+T: new worktree dev session (project → branch → dev layout tab).
    {
        key = 't',
        mods = mod.SUPER,
        action = wezterm.action_callback(function(window, pane)
            window:perform_action(projects.new_worktree_session(), pane)
        end),
    },
    -- Cmd+Ctrl+E: session picker — all Zellij tabs in the current session.
    -- Shows every tab (worktree sessions, claude tabs, etc.) and navigates to the selection.
    {
        key = 'e',
        mods = mod.SUPER_REV,
        action = wezterm.action_callback(function(window, pane)
            local proc = pane:get_foreground_process_name() or ''
            local in_zellij = proc:find('zellij', 1, true) ~= nil
            local session = window:active_workspace()
            local lines = {}

            if in_zellij then
                local handle = io.popen(
                    '/bin/zsh -l -c \'ZELLIJ_SESSION_NAME="' .. session
                    .. '" zellij action query-tab-names 2>/dev/null\''
                )
                if handle then
                    for name in handle:lines() do
                        if name ~= '' then
                            table.insert(lines, name)
                        end
                    end
                    handle:close()
                end
            else
                -- Fallback: WezTerm tabs
                for _, tab in ipairs(window:mux_window():tabs()) do
                    local ap = tab:active_pane()
                    table.insert(lines, ap:get_title() or tostring(tab:tab_id()))
                end
            end

            local tmpfile = '/tmp/wezterm-session-picker'
            local f = io.open(tmpfile, 'w')
            if f then
                f:write(#lines > 0 and table.concat(lines, '\n') .. '\n'
                    or '(no sessions — use Cmd+T to start one)\n')
                f:close()
            end

            local cmd
            if in_zellij then
                local zs = 'ZELLIJ_SESSION_NAME="' .. session .. '"'
                cmd = fzf.cmd({ label = 'Sessions', prompt = 'session', expect = 'ctrl-d', header = 'ctrl-d: close tab + remove worktree' })
                    .. ' < ' .. tmpfile
                    .. ' | { '
                    .. 'IFS= read -r key; IFS= read -r tab; '
                    .. '[ -z "$tab" ] && exit 0; '
                    .. 'if [ "$key" = "ctrl-d" ]; then '
                    ..   zs .. ' zellij action go-to-tab-name "$tab" && '
                    ..   zs .. ' zellij action close-tab; '
                    -- Worktree cleanup: tab name is "project/branch", worktree at ~/code/project/.worktrees/branch.
                    -- Project may be 1 or 2 path components (repo vs org/repo), so try both.
                    .. 'code_dir="$HOME/code"; '
                    .. 'proj=$(echo "$tab" | cut -d/ -f1-2); branch="${tab#${proj}/}"; '
                    .. 'wt="${code_dir}/${proj}/.worktrees/${branch}"; '
                    .. 'if [ ! -d "$wt" ]; then '
                    ..   'proj=$(echo "$tab" | cut -d/ -f1); branch="${tab#${proj}/}"; '
                    ..   'wt="${code_dir}/${proj}/.worktrees/${branch}"; '
                    .. 'fi; '
                    .. '[ -d "$wt" ] && git -C "${code_dir}/${proj}" worktree remove --force "$wt" 2>/dev/null; '
                    .. 'else '
                    ..   zs .. ' zellij action go-to-tab-name "$tab"; '
                    .. 'fi; }'
                    .. '; exit 0'
            else
                cmd = fzf.cmd({ label = 'Sessions', prompt = 'session' }) .. ' < ' .. tmpfile .. '; exit 0'
            end

            fzf.spawn({ '/bin/zsh', '-l', '-c', cmd }, 750, 300)
        end),
    },
    { key = 'w',          mods = mod.SUPER_REV, action = act.CloseCurrentTab({ confirm = false }) },

    -- tabs: navigation
    -- Inside Zellij: delegate to Zellij tab navigation (Alt+[/]) so claude-* tabs are accessible.
    -- Outside Zellij: WezTerm tab navigation.
    {
        key = '[',
        mods = mod.SUPER,
        action = wezterm.action_callback(function(window, pane)
            local proc = pane:get_foreground_process_name() or ''
            if proc:find('zellij', 1, true) then
                window:perform_action(act.SendKey { key = '[', mods = 'ALT' }, pane)
            else
                window:perform_action(act.ActivateTabRelative(-1), pane)
            end
        end),
    },
    {
        key = ']',
        mods = mod.SUPER,
        action = wezterm.action_callback(function(window, pane)
            local proc = pane:get_foreground_process_name() or ''
            if proc:find('zellij', 1, true) then
                window:perform_action(act.SendKey { key = ']', mods = 'ALT' }, pane)
            else
                window:perform_action(act.ActivateTabRelative(1), pane)
            end
        end),
    },
    { key = '[',          mods = mod.SUPER_REV, action = act.MoveTabRelative(-1) },
    { key = ']',          mods = mod.SUPER_REV, action = act.MoveTabRelative(1) },

    -- tab: title
    { key = '0',          mods = mod.SUPER,     action = act.EmitEvent('tabs.manual-update-tab-title') },
    { key = '0',          mods = mod.SUPER_REV, action = act.EmitEvent('tabs.reset-tab-title') },

    -- tab: hide tab-bar
    { key = '9',          mods = mod.SUPER,     action = act.EmitEvent('tabs.toggle-tab-bar'), },

    { key = 'v',          mods = mod.SUPER,     action = act.PasteFrom 'PrimarySelection' },

    -- window --
    -- window: spawn new window with fzf project picker
    {
        key = 'n',
        mods = mod.SUPER,
        action = wezterm.action_callback(function(window, pane)
            window:perform_action(projects.choose_project({ new_window = true }), pane)
        end),
    },

    -- window: zoom window
    {
        key = '-',
        mods = mod.SUPER,
        action = wezterm.action_callback(function(window, _pane)
            local dimensions = window:get_dimensions()
            if dimensions.is_full_screen then
                return
            end
            local new_width = dimensions.pixel_width - 50
            local new_height = dimensions.pixel_height - 50
            window:set_inner_size(new_width, new_height)
        end)
    },
    {
        key = '=',
        mods = mod.SUPER,
        action = wezterm.action_callback(function(window, _pane)
            local dimensions = window:get_dimensions()
            if dimensions.is_full_screen then
                return
            end
            local new_width = dimensions.pixel_width + 50
            local new_height = dimensions.pixel_height + 50
            window:set_inner_size(new_width, new_height)
        end)
    },

    -- background controls --
    {
        key = [[/]],
        mods = mod.SUPER,
        action = wezterm.action_callback(function(window, _pane)
            backdrops:random(window)
            projects.save_backdrop(window:active_workspace(), backdrops.current_idx)
        end),
    },
    {
        key = [[,]],
        mods = mod.SUPER,
        action = wezterm.action_callback(function(window, _pane)
            backdrops:cycle_back(window)
            projects.save_backdrop(window:active_workspace(), backdrops.current_idx)
        end),
    },
    {
        key = [[.]],
        mods = mod.SUPER,
        action = wezterm.action_callback(function(window, _pane)
            backdrops:cycle_forward(window)
            projects.save_backdrop(window:active_workspace(), backdrops.current_idx)
        end),
    },
    {
        key = [[/]],
        mods = mod.SUPER_REV,
        action = act.InputSelector({
            title = 'InputSelector: Select Background',
            choices = backdrops:choices(),
            fuzzy = true,
            fuzzy_description = 'Select Background: ',
            action = wezterm.action_callback(function(window, _pane, idx)
                if not idx then
                    return
                end
                local i = tonumber(idx)
                ---@diagnostic disable-next-line: param-type-mismatch
                backdrops:set_img(window, i)
                projects.save_backdrop(window:active_workspace(), i)
            end),
        }),
    },
    {
        key = 'b',
        mods = mod.SUPER,
        action = wezterm.action_callback(function(window, _pane)
            backdrops:toggle_focus(window)
        end)
    },

    -- panes --
    -- panes: split panes (zellij-aware)
    {
        key = [[\]],
        mods = mod.SUPER,
        action = wezterm.action_callback(function(window, pane)
            local proc = pane:get_foreground_process_name() or ''
            if proc:find('zellij') then
                local session = window:active_workspace()
                wezterm.run_child_process { '/bin/zsh', '-l', '-c',
                    'ZELLIJ_SESSION_NAME=' .. session .. ' zellij action new-pane --direction down' }
            else
                window:perform_action(act.SplitVertical { domain = 'CurrentPaneDomain' }, pane)
            end
        end),
    },
    {
        key = [[\]],
        mods = mod.SUPER_REV,
        action = wezterm.action_callback(function(window, pane)
            local proc = pane:get_foreground_process_name() or ''
            if proc:find('zellij') then
                local session = window:active_workspace()
                wezterm.run_child_process { '/bin/zsh', '-l', '-c',
                    'ZELLIJ_SESSION_NAME=' .. session .. ' zellij action new-pane --direction right' }
            else
                window:perform_action(act.SplitHorizontal { domain = 'CurrentPaneDomain' }, pane)
            end
        end),
    },

    -- panes: zoom+close pane
    -- Cmd+Enter: maximise pane in zellij (Alt+m) or WezTerm zoom if not in zellij
    {
        key = 'Enter',
        mods = mod.SUPER,
        action = wezterm.action_callback(function(window, pane)
            local proc = pane:get_foreground_process_name() or ''
            if proc:find('zellij') then
                window:perform_action(act.SendKey { key = 'm', mods = 'ALT' }, pane)
            else
                window:perform_action(act.TogglePaneZoomState, pane)
            end
        end),
    },
    {
        key = 'w',
        mods = mod.SUPER,
        action = wezterm.action_callback(function(window, pane)
            local proc = pane:get_foreground_process_name() or ''
            if proc:find('zellij') then
                local session = window:active_workspace()
                wezterm.run_child_process { '/bin/zsh', '-l', '-c',
                    'ZELLIJ_SESSION_NAME=' .. session .. ' zellij action close-pane' }
            else
                window:perform_action(act.CloseCurrentPane { confirm = false }, pane)
            end
        end),
    },

    -- panes: navigation
    { key = 'k',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Up') },
    { key = 'j',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Down') },
    { key = 'h',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Left') },
    { key = 'l',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Right') },
    {
        key = 'p',
        mods = mod.SUPER_REV,
        action = act.PaneSelect({ alphabet = '1234567890', mode = 'SwapWithActiveKeepFocus' }),
    },

    -- panes: scroll pane
    { key = 'u',        mods = mod.SUPER, action = act.ScrollByLine(-5) },
    { key = 'PageUp',   mods = 'NONE',    action = act.ScrollByPage(-0.75) },
    { key = 'PageDown', mods = 'NONE',    action = act.ScrollByPage(0.75) },

    -- semantic prompt navigation (requires OSC 133)
    { key = 'UpArrow',   mods = 'OPT|SHIFT', action = act.ScrollToPrompt(-1) },
    { key = 'DownArrow', mods = 'OPT|SHIFT', action = act.ScrollToPrompt(1) },

    -- key-tables --
    -- resizes fonts
    {
        key = 'f',
        mods = 'LEADER',
        action = act.ActivateKeyTable({
            name = 'resize_font',
            one_shot = false,
            timeout_milliseconds = 1000,
        }),
    },
    -- resize panes
    {
        key = 'p',
        mods = 'LEADER',
        action = act.ActivateKeyTable({
            name = 'resize_pane',
            one_shot = false,
            timeout_milliseconds = 1000,
        }),
    },


    -- workspace: toggle back to previous workspace
    {
        key = ';',
        mods = mod.SUPER_REV,
        action = wezterm.action_callback(function(window, pane)
            local prev = workspace_history.previous
            if not prev then return end
            for _, w in ipairs(wezterm.mux.all_windows()) do
                local ok, gui_win = pcall(function() return w:gui_window() end)
                if ok and gui_win and gui_win:active_workspace() == prev then
                    gui_win:focus()
                    projects.set_workspace_backdrop(gui_win, prev)
                    return
                end
            end
            projects.set_workspace_backdrop(window, prev)
            window:perform_action(act.SwitchToWorkspace { name = prev }, pane)
        end),
    },

    -- projects --
    {
        key = 'p',
        mods = mod.SUPER_REV,
        action = wezterm.action_callback(function(window, pane)
            window:perform_action(projects.choose_project(), pane)
        end),
    },
    {
        key = 'j',
        mods = mod.SUPER_REV,
        action = wezterm.action_callback(function(window, pane)
            window:perform_action(projects.choose_session(), pane)
        end),
    },

    -- workspace: rename current workspace
    {
        key = 'r',
        mods = mod.SUPER_REV,
        action = act.PromptInputLine({
            description = 'Rename workspace:',
            action = wezterm.action_callback(function(window, _pane, line)
                if line and line ~= '' then
                    local old = window:active_workspace()
                    wezterm.mux.rename_workspace(old, line)
                end
            end),
        }),
    },
}

-- stylua: ignore
local key_tables = {
    resize_font = {
        { key = 'k',      action = act.IncreaseFontSize },
        { key = 'j',      action = act.DecreaseFontSize },
        { key = 'r',      action = act.ResetFontSize },
        { key = 'Escape', action = 'PopKeyTable' },
        { key = 'q',      action = 'PopKeyTable' },
    },
    resize_pane = {
        { key = 'k',      action = act.AdjustPaneSize({ 'Up', 1 }) },
        { key = 'j',      action = act.AdjustPaneSize({ 'Down', 1 }) },
        { key = 'h',      action = act.AdjustPaneSize({ 'Left', 1 }) },
        { key = 'l',      action = act.AdjustPaneSize({ 'Right', 1 }) },
        { key = 'Escape', action = 'PopKeyTable' },
        { key = 'q',      action = 'PopKeyTable' },
    },
}

local mouse_bindings = {
    -- Ctrl-click will open the link under the mouse cursor
    {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'SHIFT',
        action = act.OpenLinkAtMouseCursor,
    },
}

return {
    disable_default_key_bindings = true,
    -- disable_default_mouse_bindings = true,
    leader = { key = 'a', mods = mod.SUPER_REV },
    keys = keys,
    key_tables = key_tables,
    mouse_bindings = mouse_bindings,
}
