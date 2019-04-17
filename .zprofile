[[ -e ~/.profile ]] && emulate sh -c 'source ~/.profile'

# if this is a login shell
# if [[ -o login ]]; then
    # if first tty: start x
    # [[ -z $DISPLAY && $XDG_VTNR -le 2 ]] && exec startx -deferglyphs 16
    # else fall back to bash
    # exec bash
# fi
