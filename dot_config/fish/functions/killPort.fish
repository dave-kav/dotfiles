function killPort --description 'Kill process listening on a port'
    lsof -i tcp:$argv[1] | awk 'NR!=1 {print $2}' | xargs kill
end
