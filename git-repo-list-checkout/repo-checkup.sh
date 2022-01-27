# repo-checkup scans every folder in the working directory and alerts in case the folder
# is a not-up-to-date git folder
#
#    Copyright (C) 2022  EnlightenedDoge

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

#!/bin/bash
for i in $(ls -d */); do
    cd "$i"
    if [ ! -d .git ]; then
        cd ../
        continue
    fi
    echo "$i"
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