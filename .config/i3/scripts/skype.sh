#!/usr/bin/env bash
docker start dreamy_goodall
status=$?
if [[ $status != 0 ]]; then
    notify-send --icon=dialog-information "Docker - Skype Error $status" "Docker could not start skype container. Error: $status occured"
    exit $status
else
    sleep 1
    ssh docker-skype skype-pulseaudio
fi
