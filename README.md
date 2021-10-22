# ~/.dotfiles

### How do I clone that?
Since I make use of git submodules, you would have to set the recurse-submodules flag while cloning:

```sh
git clone --recurse-submodules https://github.com/Nooo37/dots.git best-dots-Ive-ever-seen
cd best-dots-Ive-ever-seen
stow $(\ls -d */) # symlinks all relevant files and directories
```

### Why that weird folder structure?
I'm using [stow](https://www.gnu.org/software/stow/).

### What is `installed.txt`?
A list of programs that I have installed to get the dotfiles working + programs I use all the time anyway.

