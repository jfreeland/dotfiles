# current basic setup

## NIX

This gets me a good part of the way to a setup Mac host.  Lots of room for
improvement in many aspects.

```bash
mkdir configs
git clone https://github.com/jfreeland/dotfiles.git configs/dotfiles
ln -s configs/dotfiles/.bash_profile .
ln -s configs/dotfiles/.bashrc .
ln -s configs/dotfiles/.config .
ln -s configs/dotfiles/.ssh .
ln -s configs/dotfiles/.tmux .
ln -s configs/dotfiles/.tmux.conf .
ln -s configs/dotfiles/.vimrc .
# add ssh key to agent and then
git clone https://github.com/jfreeland/private.git configs/private
ln -s configs/private/.gitconfig .
ln -s configs/private/.gitconfig-personal .
ln -s configs/private/.private.bash .
sh <(curl -L https://nixos.org/nix/install) --darwin-use-unencrypted-nix-store-volume --daemon
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
home-manager switch
~/.config/nixpkgs/install
# open vim for bootstrap
nvim :Copilot setup
nvim :TSUpdate
nvim :CocInstall coc-go
sudo chsh -s (path to newer bash) "$USER"
```

When I get around to setting up darwin-mac, there are a couple other niceties
here https://github.com/jacobbednarz/j/blob/main/darwin.nix.

One of the options I have stashed around for my notes is:
```bash
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool true # Mac press and hold for accents
```

# Linux

Need to spend some more time here.