# ~/.dotfiles

## How does it look like?

![](https://media.discordapp.net/attachments/655947537538088962/788151542863233034/rice.png)

## Other less relevant questions

### How do I clone that?
Since I make use of git submodules, you would have to set the recurse-submodules flag while cloning:

```sh
git clone --recurse-submodules https://github.com/Nooo37/dots.git best-dots-Ive-ever-seen
cd best-dots-Ive-ever-seen
stow . # symlinks all relevant files and directories
```


### Why that weird folder structure?
I'm using [stow](https://www.gnu.org/software/stow/).
