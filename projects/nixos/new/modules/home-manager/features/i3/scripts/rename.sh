#!/usr/bin/env bash
# Find focused workspace
activeWorkspace="$(i3-msg -t get_workspaces | grep -P '"name"[^}]*?("focused"):true' -o | sed 's/"name":"\(.*\)","visible":true,"focused":true/\1/g')"
    number=$(echo $activeWorkspace | cut -d ":" -f1)

if [[ -z $1 ]]; then

    i3-input -F "rename workspace to \"$number: %s\"" -P 'New name: '

elif [[ $1 == "0" ]]; then
# Allpy name to current focused workspace

    # Find current focused window
    winId=$(xdotool getwindowfocus)

    # First: Try to get role as name
    winRole=$(xprop -id $winId WM_WINDOW_ROLE)

    # If the window does not specify a role
    if [[ $winRole == *not*found* ]] || [[ -z $winRole ]]; then
        # If prog has no role: get class name
        winClass=$(xprop -id $winId WM_CLASS)

        # If not found, get name of client's leader window
        if [[ $winClass == *not*found* ]] || [[ -z $winClass ]]; then
            # Find root winndow of current focused winow
            winParentId=$(xprop -id $winId WM_CLIENT_LEADER | awk '{print $NF}')

            # Get client leader's name
            progName=$(xprop -id $winParentId WM_NAME |awk '{print $3}' | tr -d '"' | head -n 1)
        else
            winClass=$(echo $winClass | awk '{print $4}' | tr -d '"' )
            tmpName=$(xprop -id $winId WM_NAME | grep '".*"' -o | tr -d '"' | sed "s/^$winClass *//" | cut -d ' ' -f1)
            progName="$winClass ${tmpName:0:15}"
            #progName="$tmpName"
            #progName="$winClass"
        fi
    else
        progName=$(echo $winRole | awk '{print $3}' | tr -d '"')
    fi

    # Further check if we are running a program in terminal
    if [[ ${progName,,} == *termite* ]] || [[ ${progName,,} == *urxvt* ]]; then
        winName=$(xprop -id $winId WM_NAME)
        tmpName=$( echo $winName | awk '{print $3}' | tr -d '" ')

        if [[ $tmpName == *jelias@* ]]; then

            tmpName=$( echo $winName | awk '{print $4}' | tr -d '"')
            if [[ $tmpName == "~" ]]; then
                progName="Terminal: ~/"
            elif [[ $tmpName == "/" ]]; then
                progName="Terminal: /"
            elif [[ $winName == */* ]]; then
                tmpName=$( echo $winName | awk '{print $NF}' | tr -d '"' )

                if [[ ${#tmpName} -gt 15 ]]; then

                    firstChar=$( echo $tmpName | awk -F "/" '{print $1}' )
                    tmpName2=$( echo $tmpName | awk -F "/" '{print $NF}' )
                    progName="${firstChar}/../${tmpName2:0:14}"

                else
                    progName=$tmpName
                fi
                #| awk -F "/" '{print $NF}'
            else
                progName=$( echo $winName | awk '{print $NF}' )
            fi
        elif [[ ${winName,,} == *vim* ]]; then
            progName="vim $tmpName"
        else
            progName=$tmpName
        fi
    elif [[ $progName == *3pane* ]]; then
        progName="mail"
    fi

    newName="$number: $progName"
    i3-msg "rename workspace \"$activeWorkspace\" to \"$newName\""

else

    newName="$number: $1"
    i3-msg "rename workspace \"$activeWorkspace\" to \"$newName\""

fi
# Old stuff
#winId=$(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}')
#progName=$(xprop -id $winId | awk '/WM_CLASS/{$1=$2="";print}' | cut -d'"' -f4)
#activeWorkspace=$(i3-msg -t get_workspaces | jq -c '.[] | if contains({focused:true}) then .name else "" end' | sort -r | head -n 1 | sed 's/\"//g' )
