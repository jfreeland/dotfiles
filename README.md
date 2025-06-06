# current basic setup

## nix

This gets me a good part of the way to a setup Mac host. Lots of room for
improvement in many aspects.

```bash
mkdir configs
git clone https://github.com/jfreeland/dotfiles.git configs/dotfiles
ln -s configs/dotfiles/.bash_profile .
ln -s configs/dotfiles/.bashrc .
ln -s configs/dotfiles/.config .
ln -s configs/dotfiles/.git-template .
ln -s configs/dotfiles/.ssh .
ln -s configs/dotfiles/.tmux .
ln -s configs/dotfiles/.tmux.conf .
# add ssh key to agent and then
git clone git@github.com:jfreeland/private.git configs/private
ln -s configs/private/.gitconfig .
ln -s configs/private/.gitconfig-personal .
ln -s configs/private/.private.bash .
ln -s configs/private/.wakatime.cfg .
ln -s ~/.config/nixpkgs/config/iterm2/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist
sh <(curl -L https://nixos.org/nix/install) --darwin-use-unencrypted-nix-store-volume --daemon
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
home-manager switch
bash
~/.config/nixpkgs/install
# install astronvim from https://astronvim.github.io/
git clone https://github.com/AstroNvim/template ~/.config/nvim
ln -s ~/configs/dotfiles/.config/astronvim4/lua/plugins/astrocore.lua ~/.config/nvim/lua/plugins/
ln -s ~/configs/dotfiles/.config/astronvim4/lua/plugins/community.lua ~/.config/nvim/lua/plugins/
ln -s ~/configs/dotfiles/.config/astronvim4/lua/plugins/for-me.lua ~/.config/nvim/lua/plugins/
ln -s ~/configs/dotfiles/.config/direnv ~/.config/direnv
# setup nvim wakatime
# setup devbox
sudo chsh -s (path to newer bash) "$USER"
```

Have to explicitly install the `vagrant-vmware-desktop` plugin:

```bash
vagrant plugin install vagrant-vmware-desktop
```

When I get around to setting up darwin-mac, there are a couple other niceties
here https://github.com/jacobbednarz/j/blob/main/darwin.nix.

One of the options I have stashed around for my notes is:

```bash
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool true # Mac press and hold for accents
```

Some other things:

```bash
go get github.com/cosmtrek/air
```

Check out these things some day:

- https://getfleek.dev/
- https://github.com/DeterminateSystems/nix-installer

# Ubuntu

Need to spend some more time here.

```bash
ln -s .config/nixpkgs/config/homebrew/Brewfile-ubnt .Brewfile
# install tailscale, https://tailscale.com/download/linux/ubuntu-2204
# exit node, https://tailscale.com/kb/1103/exit-nodes/?tab=linux
sudo apt install xorg openbox xdg-utils gnupg2 pass
```

# Other

```bash
kubectl krew install oidc-login
```
