function d --description 'Show directory history with indexes'
    echo "0  $PWD"
    set -l i 1
    for dir in $dirprev[-1..1]
        echo "$i  $dir"
        set i (math $i + 1)
    end
end
