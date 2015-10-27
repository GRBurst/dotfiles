#!/bin/bash
BRANCH=-grsec # Enter a branch if needed, i.e. -340xx or -304xx
NVIDIA=nvidia${BRANCH} # If no branch entered above this would be "nvidia"
NOUVEAU=xf86-video-nouveau
place=$(pwd)
userhome=/home/jelias/dotfiles

# Replace -R with -Rs to if you want to remove the unneeded dependencies
if [ $(pacman -Qqs ^mesa-libgl$) ]; then
    pacman -S $NVIDIA ${NVIDIA}-libgl lib32-${NVIDIA}-libgl # Add lib32-${NVIDIA}-libgl and ${NVIDIA}-lts if needed
    # pacman -R $NOUVEAU
    cd $userhome
    stow -D compton-mesa
    stow compton-nvidia
    cd $place
elif [ $(pacman -Qqs ^${NVIDIA}$) ]; then
    pacman -S --needed $NOUVEAU mesa-libgl lib32-mesa-libgl # Add lib32-mesa-libgl if needed
    pacman -R $NVIDIA # Add ${NVIDIA}-lts if needed
    cd $userhome
    stow -D compton-nvidia
    stow compton-mesa
    cd $place
fi
