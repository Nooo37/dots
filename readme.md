# <p align="center"> my awesomewm config </p>

This repo is intended as a hodgepodge for all kinds of different titlebars, statusbars, popups, scripts and so on that I accumulated and use for awesomewm.

You can either copy the whole repository and have a fully functional and good looking awesomewm configuration and start customizing from there on or you can cherrypick the parts you need or take some inspiration from it.

### How are these configs structured?
I try my best to keep everything nice and neet so here is the meaning of the different directories:
- `icon/`: The only place in which you will find only icons (mostly pngs).
- `layout/`: All custom layouts go here. If you want to change the available layouts in your config, you will have to edit the `init.lua` file.
- `module/`: All sort of usefull background scripts (setting your wallpaper, autostarting applications, sloppy focus etc). Primarily to not junk your `rc.lua` with these things.
- `signal/`:  All signals to update system info (for example how high the volume is, what mpd song is playing, how much battery power is left etc)
- `ui/`: Everything you can actually see goes in that folder (titlebar, statusbar, popups, dashboards etc).
- `wallpaper.png`: That file will be used as your wallpaper. You can change it or just not use the set-wallpaper module and use something like nitrogen instead.
- `keys.lua`: Sets the keybindings. Hopefully the default ones as intuitive as possible but you are encouraged to do your own keybindings.
- `theme.lua`: Sets the theme. It is getting its colors from your .xresources by default.
- `rc.lua`: The file where everything comes together.

### Ok, but where have you stolen all that from?
I reused, got inspiration, and stole stuff from [Javacafe01](https://github.com/JavaCafe01/dotfiles/tree/master/.config/awesome), [elenapan](https://github.com/elenapan/dotfiles) and [Curt Spark](https://gitlab.com/bloxiebird/linux-awesomewm-modular-starter-kit/-/tree/master/.config/awesome).
