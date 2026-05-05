function __cd_dir_hist --description 'Jump to Nth entry in directory history'
    set -l n $argv[1]
    set -l count (count $dirprev)
    if test $n -gt $count
        echo "No directory at index $n" >&2; return 1
    end
    cd $dirprev[(math $count - $n + 1)]
end
