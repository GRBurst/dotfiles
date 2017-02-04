#!/bin/bash
BRANCH= # Enter a branch if needed, i.e. -340xx or -304xx
NVIDIA=nvidia${BRANCH} # If no branch entered above this would be "nvidia"
NOUVEAU=xf86-video-nouveau
place=$(pwd)
userhome=/home/jelias/dotfiles

# Replace -R with -Rs to if you want to remove the unneeded dependencies
#if [ $(yaourt -Qqs ^mesa-libgl$) ]; then
#    yaourt -S $NVIDIA --noconfirm
#    # yaourt -S $NVIDIA ${NVIDIA}-libgl lib32-${NVIDIA}-libgl # Add 
lib32-${NVIDIA}-libgl and ${NVIDIA}-lts if needed
#    # yaourt -R $NOUVEAU
#    cd $userhome
#    stow -D compton-mesa
#    stow compton-nvidia
#    cd $place
#elif [ $(yaourt -Qqs ^${NVIDIA}$) ]; then
    yaourt -S --needed $NOUVEAU mesa-libgl lib32-mesa-libgl --noconfirm
    yaourt -R $NVIDIA # Add ${NVIDIA}-lts if needed
    cd $userhome
    stow -D compton-nvidia
    stow compton-mesa
    cd $place
#fi
