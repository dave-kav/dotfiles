function zjd --description 'Fuzzy delete a zellij session'
    set -l session (zellij list-sessions --no-formatting | fzf | awk '{print $1}')
    test -n "$session"; and zellij delete-session $session
end
