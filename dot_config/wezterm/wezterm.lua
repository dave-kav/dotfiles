local wezterm = require('wezterm')
local Config = require('config')
local projects = require('utils.projects')

require('utils.backdrops')
    :set_images()
    :random()

-- Fire the project picker in the initial window on startup
wezterm.on('gui-startup', function(cmd)
    local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():perform_action(projects.choose_project(), pane)
end)

require('events.workspace-backdrop').setup()
require('events.left-status').setup()
require('events.right-status').setup({ date_format = '%a %H:%M:%S' })
require('events.tab-title').setup({ hide_active_tab_unseen = false, unseen_icon = 'circle' })
require('events.new-tab-button').setup()

return Config:init()
    :append(require('config.appearance'))
    :append(require('config.bindings'))
    :append(require('config.domains'))
    :append(require('config.fonts'))
    :append(require('config.general'))
    :append(require('config.launch')).options
