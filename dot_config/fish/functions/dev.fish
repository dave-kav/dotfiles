function dev --description 'Attach or create a named zellij session'
    set -l name (test -n "$argv[1]"; and echo $argv[1]; or basename $PWD)
    zellij attach --create $name
end
