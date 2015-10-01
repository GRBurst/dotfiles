#!/bin/bash
declare -r FILE="/tmp/i3scripts.conf"
init()
{
    [[ -f "$FILE" ]] && source "$FILE"
    activeWorkspace="$(i3-msg -t get_workspaces | grep -P '"name"[^}]*?("focused"):true' -o | sed 's/"name":"\(.*\)","visible":true,"focused":true/\1/g')"
    ws_number=$(echo $activeWorkspace | cut -d ":" -f1)
    #ws_split[$ws_number]="${ws_split[$ws_number]:-h}"
}

export ()
{
    echo "ws_split[$ws_number]=${ws_split[$ws_number]}" > "$FILE"
    echo "ws_win_nr[$ws_number]=${ws_win_nr[$ws_number]}" >> "$FILE"
    #echo "ws_split[$ws_number]=${ws_split[$ws_number]}"
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

    if [[ "$action" == "manual" ]]; then
        if [[ -z "${ws_split[$ws_number]}" ]]; then
            i3-msg "exec termite;"
            ws_split[$ws_number]=h
        else
            i3-msg "split ${ws_split[$ws_number]}; exec termite;"
        fi
    elif [[ "$action" == "auto" ]]; then
        #echo "ws_split[$ws_number]=${ws_split[$ws_number]}"
        if [[ -z "${ws_split[$ws_number]}" ]]; then
            i3-msg "exec termite;"
            ws_split[$ws_number]=h
        elif [[ ${ws_split[$ws_number]} == "h" ]]; then
            i3-msg "split h; exec termite;"
            ws_split[$ws_number]=v
        elif [[ ${ws_split[$ws_number]} == "v" ]]; then
            i3-msg "split v; exec termite;"
            ws_split[$ws_number]=h
        else
            i3-msg "exec termite;"
        fi
    fi


    #echo "ws_split[$ws_number]=${ws_split[$ws_number]}"
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
