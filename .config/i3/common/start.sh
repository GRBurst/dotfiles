#!/bin/sh
ETESYNC_URL=https://scal.metacosmos.space etesync-dav &
qsyncthingtray &
nm-applet &
protonvpn-cli connect --sc
protonvpn &
# feh --bg-scale '/home/jelias/.config/i3/background0.jpg' '/home/jelias/.config/i3/background1.jpg' &
# pasystray &
# unclutter &
# redshift-gtk &
