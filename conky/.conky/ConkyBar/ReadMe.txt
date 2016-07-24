<strong>
Notice: there are some pull requests in the Conky repository which are relevant to the skin (bug fixes), i will update the skin when the pull requests are integrated in Conky
</strong>
For the older version (Conky 1.9]: http://n00by4ever.deviantart.com/art/ConkyBar-Conky-config-Conky-1-9-549312244

<strong>
ConkyBar - V3.1
===================
</strong>
The skin is test on linux arch 64bit, and Conky 1.10. It should work on other distros too, because it uses nothing specific for linux arch.

The parts of the skin are ran in different conky instances to enable easy editing and to swap "conkies" in and out. For example there are multiple versions for cpu, ram, files and banshee. This impose a small overhead and thus performance penalty. This skin uses proper transparency, this allows for wallpaper changes (eg. Variety) to change wallpapers while running conky without issues.

The skin had some delays build in when starting up using conky_start, these can be removed if desired. This delays should avoid the background appearing on top of the other skins, in case this happens just run conky_start again.

The set-up is made for 1920x1080 monitors, if you have  larger or smaller monitor you will have to edit the skin manually.

Conky 1.10 has a new click through feature,  since this skin is rather big i can recommend it. If you're compiling Conky you have to add the build flag: BUILD_XSHAPE, if you have installed Conky from a package manager please contact the maintainer and ask them to add the flag to the package or edit the package yourself.

<strong>
Requires
====================
</strong>
- wget            (for external IP)
- hddtemp      (for hdd temp, run the daemon)
- asla-utils      (for current volume)
- sysstat        (for iostat)

- banshee      (if you use the banshee part)
- python2      (if you use the banshee part)

Optional:
- Conky Manger    (general managing tool for conky skins)

For other players than banshee: http://crunchbang.org/forums/viewtopic.php?id=15356&p=1 or https://ubuntuforums.org/showthread.php?p=6097476

<strong>
Installation steps:
====================
</strong>
1) Unzip and put the folder in /home/[username]/.conky/ConkyBar/ and there all the files of the skin (e.g conky_start).
2) Make sure your conky version support both lua and nvidia (For arch users: conky1.9, conky-lua-nv)
3) Make sure you've got all the dependencies installed (hddtemp, sysstat, ...) and they are running (also on start-up when needed, eg. hddtemp)
4) Make conky_start (and all files in /lua and /scripts) executable, don't forget the python file!
5) Make sure you've installed the fonts in /fonts
6) Edit the system specific setting to your system setting:
    - in conky_network and net_graph.lua change the interface to your wifi/eth interface (replace: enp8s0 and wlp2s0)
    - in conky_files and files_ring.lua change the desired harddisk device (replace: /dev/sda)
Note: some hardware has specific sensors (eg laptops) which for example can not use the default temperature sensors, you will have to edit the conky files manually to your systems "special needs". Fortunately it is fairy easy to edit this in conky.
7) Add conky_start to your start-up programs or alternatively when using Conky Manger. If you want to use an alternative version just edit the conky config file name in the conky_start script which is self explanatory.
Note: the conky_start script is recommended since it has a guaranteed good start-up sequence.

Enjoy! You're good to go now.

<strong>
Window setting
====================
</strong>
These depend on your specific system, window manager ect... these are made for gnome and should give true transparency but it is possibly your system requires other settings. I assume you will already have Conky configs and can copy past those settings. If not i recommend to search forums of your distribution and ask what settings other people use.

<strong>
How to change the color
====================
</strong>
In every config change the value of color0 to the desired value. In the lua files search for the value "1793d0" and replace it with your desired color.
(unfortunately you have to edit it in every conky config file individually... maybe the include statement will work one day)

Colors codes for common distros
====================
Arch         1793d0        (blue)
Mint         77B753        (green)
Ubuntu        dd4814    (orange)
Debian         d70a53    (red)

<strong>
Known bugs
====================
</strong>
- The hdd graph (ring) does have a blank space in the beginning (this bug is from the original script)
- Volume of exact 100 gives the wrong icon (of volume < 50)

<strong>
Updates
====================
</strong>
-V3.1 07/2015: cleaned up code, ported to Conky 1.10
-V3.0 07/2015: fixed small issues, skin changes, code clean-up, compatible with Conky Manger, added Screenlet space and themes for this conky theme.
-V2.0 09/2013: general improvements, updated images, improved alignment, code clean-up, ...
-V1.0 09/2013: initial commit

<strong></strong><strong>
Credits
====================
</strong>
General look based on: Conky Launchpad - @freeazy - http://freeazy.deviantart.com/art/Conky-Launchpad-186251285
Clock: Gotham  Conky config - @psyjunta - https://psyjunta.deviantart.com/art/Gotham-Conky-config-205465419
Lua scripts - @wlourf  (bars/graphs/rings)
Banshee implementation - @kaivalagi  - http://ubuntuforums.org/showthread.php?t=1223883
Icons - forgot sorry (let me know if you do)

Thanks to the people on the crunchbang forums for their help and knowledge- http://crunchbang.org/forums/viewtopic.php?id=16909

Feel free to fork/improve, i'm also always very curious towards the results :)


<strong></strong><strong>
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
The Impulse Screenlet
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
</strong>

<strong></strong><strong>
- Abandoned by developer
- Not flawless
- NOT CONKY
</strong>

The github if you want to see the source: https://github.com/ianhalpern/Impulse

I want to stress this has nothing to do with Conky, it must be installed separately and is buggy/abandoned so you will have to play with it if it doesn't work (it did for me on the first time though). The original release can be found here: http://gnome-look.org/content/show.php/Impulse+-+PulseAudio+visualizer?content=99383.
If you have problems i recommend to read the last pages form the commends there, they contain useful information. Wlouf has tried to port this to Conky but his attempt was only a proof of concept since it was using massive resources, maybe some day it will be integrated with conky (for the more technical people reading this: Impulse uses a custom script in c to process the audio spectrum wich is than passed to python to work with the Screenlet software and drawn on screen using Cairo. Cairo is also used in conky, replacing the python script with lua script is fairly easy and drawing in lua with cairo is already done with conky. So porting should be fairly easy but resources seem a problem.

Common problems:
    - Low volume (see comments gnome-look)
    - Channels switch (see comment gnome-look, or just toggle the channels in the Screenlet application)

<strong></strong><strong>Impulse will only work with PusleAusio</strong><strong></strong>


<strong></strong><strong>
Dependencies
====================
</strong>
Impulse used python2 for everything.
Requires:
	python-gtk2
	python-cairo
	libfftw3-3
	libpulse0
Screenlet version requires:
	screenlets

I've only tested the Screenlet version (read: this is not a separate version but Impulse is managed by Screenlet instead of you starting it up by running the python script).
It has a separated version for 32 and 64bit OS, download the correct version from gnome-look

To install it:
- Install all depencies
- Open Screenet
- "Install" Impulse by pointing to the zip containing the 32/64bit version
- Copy all the folders in the "Theme" map in the archive you've downloaded from this site and add them to the theme folder from Screenlet (e.g /home/[Username]/.screenlets/Impulse/themes)
- In Screenlets launch an insance
- Rightclick on the spectrum meter on your desktop en go to option (note: rightclicking misses a lot so you might have to tried many time) and go to the last tab where you can set the source
-> you should see moving bars now if you're playing music :D

You can drop an drag, change the skins ect... you will have to manually position the Impulse Instance and change the theme to the corresponding theme for the chosen conky config (just try the themes for
impulse). I've also added some extra themes i found online so show the possible power of Impulse.



Here are the coordinates for the Impulse instance which have been used in the screenshot.

    ConkyBarbanshee3 2
        - X pos: 1649
        - Y pos: 826

    ConkyBarbanshee4
        - X pos: 1617
        - Y pos: 811

    ConkyBar 1
        - X pos: 6
        - Y pos: 926

    ConkyBar 2
        - X pos: 6
        - Y pos: 945

If you've not willing to tolerate the awkwardness of the Impulse Screenlet just ignore it and just use the conky skin which just works perfectly without the Screenlet (or any of its dependencies). You can ignore the Impulse folder completely :)
