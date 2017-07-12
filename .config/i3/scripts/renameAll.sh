#!/usr/bin/env bash

winIds=$(xprop -root | awk '/_NET_CLIENT_LIST\(WINDOW\)/{$1=$2=$3=$4=""; print}')

progName=$(xprop -id $winId | awk '/WM_CLASS/{$1=$2="";print}' | cut -d'"' -f4)

activeWorkspace=$(i3-msg -t get_workspaces | jq -c '.[] | if contains({focused:true}) then .name else .name end' | sort -r | head -n 1 | sed 's/\"//g' )


newName=$(echo $activeWorkspace | cut  -d ":" -f1)
newName="$newName: $progName"
i3-msg "rename workspace \"$activeWorkspace\" to \"$newName\""
