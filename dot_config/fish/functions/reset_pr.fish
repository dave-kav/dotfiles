function reset_pr --description 'Hard reset current branch to its remote'
    git reset --hard origin/(git branch --show-current)
end
