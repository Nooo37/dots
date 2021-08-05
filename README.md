# ~/.dotfiles

## How does it look like?

[[https://media.discordapp.net/attachments/655947537538088962/788151542863233034/rice.png]]

## Other less relevant questions

### How do I clone that?
Since I make use of git submodules, you would have to set the recurse-submodules flag:

```sh
git clone --recurse-submodules https://github.com/Nooo37/dots.git best-dots-Ive-ever-seen
```

### Why that weird folder structure?
Don't feel like making my home directory a git repo. I also think it's clearer that way since I don't intend to backup everything.

### What is xprison supposed to be?
Xprison is a way to update all my colorschemes simultaniously. Currently only all awesomeWM widgets and my emacs colorscheme depend directly on the colors in the Xresource db but through a simple script I also update Alacritty, all GTK 3 Applications (nautilus, evince, xournalpp), Firefox, Discord and zathura with those colors. It works by setting new xrdb color values and copying the templates in `xprison/res` to where they belong. 


