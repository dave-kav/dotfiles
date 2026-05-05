if status is-interactive

    # ── Abbreviations ────────────────────────────────────────────────────────
    abbr --add tl   'taskw list'
    abbr --add lg   lazygit
    abbr --add nnvim neovide
    abbr --add tsr  'npx ts-node'
    abbr --add dy   'dig +short @dns.toys'
    abbr --add awscreds 'code ~/.aws/credentials'
    abbr --add ls   'eza --icons=always'
    abbr --add la   'eza --icons=always -lAh'
    abbr --add cl   clear
    abbr --add zj   'zellij attach (zellij list-sessions --no-formatting | fzf | awk \'{print $1}\')'

    # ── Zellij: rename tab to repo/dir on cd ─────────────────────────────────
    function __zellij_rename_tab --on-variable PWD
        set -q ZELLIJ; or return
        set -q ZELLIJ_CLAUDE_TAB; and return
        set -l name (git rev-parse --show-toplevel 2>/dev/null)
        if test -n "$name"
            set name (basename $name)
        else
            set name (basename $PWD)
        end
        zellij action rename-tab $name
    end
    __zellij_rename_tab  # run once on shell init

end

# ── Tool integrations ─────────────────────────────────────────────────────
starship init fish | source
direnv hook fish | source
zoxide init fish | source

# ── Environment ───────────────────────────────────────────────────────────
set -gx EDITOR nvim
set -gx DOCKER_HOST unix:///Users/dave/.docker/run/docker.sock
set -gx RAINFROG_CONFIG ~/.config/rainfrog
set -gx OKTA_USERNAME davidkavanagh

# ── PATH ──────────────────────────────────────────────────────────────────
fish_add_path $HOME/bin
fish_add_path $HOME/.local/bin
fish_add_path /opt/homebrew/bin

# ── Java / Android ────────────────────────────────────────────────────────
set -gx JAVA_HOME /Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
set -gx ANDROID_HOME $HOME/Library/Android/sdk
fish_add_path $ANDROID_HOME/emulator $ANDROID_HOME/platform-tools

# ── Bun ───────────────────────────────────────────────────────────────────
set -gx BUN_INSTALL $HOME/.bun
fish_add_path $BUN_INSTALL/bin

# ── pnpm ──────────────────────────────────────────────────────────────────
set -gx PNPM_HOME $HOME/Library/pnpm
fish_add_path $PNPM_HOME

# ── Claude CLI ────────────────────────────────────────────────────────────
test -f $HOME/.claude/local/claude; and fish_add_path $HOME/.claude/local
