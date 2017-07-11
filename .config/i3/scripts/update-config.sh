#!/bin/bash
cat ~/.i3/common/config > ~/.i3/config;
cat ~/.i3/local/config >> ~/.i3/config;
if[[ -z $1 ]]; then
    i3-msg reload;
else
    i3-msg restart;
fi
