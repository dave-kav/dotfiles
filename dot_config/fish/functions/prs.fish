function prs --description 'Fuzzy-pick and checkout a PR'
    gh pr list | cut -f1,2 | gum choose | cut -f1 | xargs gh pr checkout
end
