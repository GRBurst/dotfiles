#!/usr/bin/env bash

wid=`xdotool search --name urxvtp | head -n 1`
if [ -z "$wid" ]; then
   /usr/bin/urxvt -name urxvtp &
   while [ -z "$(xdotool search --name urxvtp | head -n 1)" ]
   do
   :
   done
   xdotool search --name urxvtp key "F11"
   #i3-msg move scratchpad
   #i3-msg scratchpad show > /dev/null
else
   #i3-msg scratchpad show > /dev/null
    if [ -z "$(xdotool search --onlyvisible --name urxvtp 2>/dev/null | head -n 1)" ]; then
        xdotool windowmap $wid
        xdotool windowfocus $wid
    else
        xdotool windowunmap $wid
    fi
fi
