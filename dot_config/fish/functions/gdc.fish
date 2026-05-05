function gdc --description 'Git commit with gum prompts'
    set -l summary (gum input --width 50 --placeholder "Summary of changes")
    test -z "$summary"; and return 1
    set -l body (gum write --width 80 --placeholder "Details of changes (CTRL+D to finish)")
    git commit -m $summary -m $body
end
