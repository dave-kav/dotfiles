function gad --description 'Git add all then show cached diff'
    git add --all && git diff --cached
end
