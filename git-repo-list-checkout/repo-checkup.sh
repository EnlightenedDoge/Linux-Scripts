#!/bin/bash
for i in $(ls -d */); do
    echo "$i"
    cd "$i"
    if [ ! -d .git ]; then
        cd ../
        continue
    fi
    git fetch origin
    reslog="$(git diff HEAD)"
    if [[ "${reslog}" != "" ]] ; then
        echo "${i:0:(-1)} is not fully synced"
    fi
    reslog="$(git log HEAD..origin/master --oneline)"
    if [[ "${reslog}" != "" ]] ; then
        echo "${i:0:(-1)} is not up to date with remote"
    fi
    cd ../
done