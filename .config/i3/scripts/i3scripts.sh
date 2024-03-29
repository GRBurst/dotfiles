#!/usr/bin/env bash
declare -r FILE="/tmp/i3scripts.conf"
init()
{
    [[ -f "$FILE" ]] && source "$FILE"
    activeWorkspace="$(i3-msg -t get_workspaces | grep -P '"name"[^}]*?("focused"):true' -o | sed 's/"name":"\(.*\)","visible":true,"focused":true/\1/g')"
    ws_number=$(echo $activeWorkspace | cut -d ":" -f1)
}

export ()
{
    if grep -q -s "ws_split\[$ws_number\]" "$FILE"; then
        sed -E -i "s/ws_split\[$ws_number\]=(.*)/ws_split\[$ws_number\]=${ws_split[$ws_number]}/" "$FILE"
    else
        echo "ws_split[$ws_number]=${ws_split[$ws_number]}" >> "$FILE"
    fi
}

ws_set_split()
{
    local -r action="$1"
    if [[ "$action" == "h" ]]; then
        ws_split[$ws_number]=h
    elif [[ "$action" == "v" ]]; then
        ws_split[$ws_number]=v
    fi
}

ws_split()
{
    local -r action="$1"
    local folder="$(xcwd)"
    # local term="termite -d $(xcwd) -e zsh"
    local term="alacritty --working-directory \"${folder:-~/}\""

    if [[ "$action" == "manual" ]]; then
        if [[ -z "${ws_split[$ws_number]}" ]]; then
            i3-msg "exec $term;"
            ws_split[$ws_number]=h
        else
            i3-msg "split ${ws_split[$ws_number]}; exec $term;"
        fi
    elif [[ "$action" == "auto" ]]; then
        #echo "ws_split[$ws_number]=${ws_split[$ws_number]}"
        if [[ -z "${ws_split[$ws_number]}" ]]; then
            i3-msg "exec $term;"
            ws_split[$ws_number]=h
        elif [[ ${ws_split[$ws_number]} == "h" ]]; then
            i3-msg "split h; exec $term;"
            ws_split[$ws_number]=v
        elif [[ ${ws_split[$ws_number]} == "v" ]]; then
            i3-msg "split v; exec $term;"
            ws_split[$ws_number]=h
        else
            i3-msg "exec $term;"
        fi
    fi
}

# main function, won't live without it
main()
{
    init

    local -r function="$1"
    local -r action="$2"

    case "$function" in
    "ws_split")
        ws_split "$action"
    ;;
    "ws_set_split")
        ws_set_split "$action"
    esac

    export
}

main "$@"
