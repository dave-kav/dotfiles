-- Tokyo Night Storm — consistent with nvim + zellij theme
-- stylua: ignore
local storm = {
    bg          = '#24283b',
    bg_dark     = '#1f2335',
    bg_darker   = '#1a1b26',
    bg_hl       = '#2e3c64',
    bg_visual   = '#283457',
    fg          = '#c0caf5',
    fg_dark     = '#a9b1d6',
    fg_gutter   = '#3b4261',
    comment     = '#565f89',
    dark3       = '#545c7e',
    dark5       = '#737aa2',
    blue        = '#7aa2f7',
    blue_dim    = '#394b70',
    cyan        = '#7dcfff',
    teal        = '#2ac3de',
    magenta     = '#bb9af7',
    orange      = '#ff9e64',
    yellow      = '#e0af68',
    green       = '#9ece6a',
    green1      = '#73daca',
    red         = '#f7768e',
    red1        = '#db4b4b',
}

-- stylua: ignore
local colorscheme = {
    foreground    = storm.fg,
    background    = storm.bg,
    cursor_bg     = storm.fg,
    cursor_border = storm.fg,
    cursor_fg     = storm.bg_darker,
    selection_bg  = storm.bg_visual,
    selection_fg  = storm.fg,

    -- ANSI colors aligned to Tokyo Night Storm
    ansi = {
        storm.bg_darker,  -- black
        storm.red,        -- red
        storm.green,      -- green
        storm.yellow,     -- yellow
        storm.blue,       -- blue
        storm.magenta,    -- magenta
        storm.cyan,       -- cyan
        storm.fg_dark,    -- white
    },
    brights = {
        storm.dark3,      -- bright black
        storm.red,        -- bright red
        storm.green,      -- bright green
        storm.yellow,     -- bright yellow
        storm.blue,       -- bright blue
        storm.magenta,    -- bright magenta
        storm.cyan,       -- bright cyan
        storm.fg,         -- bright white
    },

    tab_bar = {
        background        = 'rgba(26, 27, 38, 0.85)',
        active_tab = {
            bg_color      = storm.blue_dim,   -- deep blue bg
            fg_color      = storm.blue,       -- bright blue text — clearly active
        },
        inactive_tab = {
            bg_color      = storm.bg,
            fg_color      = storm.dark3,
        },
        inactive_tab_hover = {
            bg_color      = storm.bg_dark,
            fg_color      = storm.fg_dark,
        },
        new_tab = {
            bg_color      = storm.bg,
            fg_color      = storm.dark3,
        },
        new_tab_hover = {
            bg_color      = storm.bg_dark,
            fg_color      = storm.blue,
            italic        = true,
        },
    },

    visual_bell     = storm.red,
    indexed = {
        [16] = storm.orange,
        [17] = storm.red1,
    },
    scrollbar_thumb = storm.fg_gutter,
    split           = storm.dark3,
    compose_cursor  = storm.magenta,
}

return colorscheme
