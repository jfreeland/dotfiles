{ config, pkgs, ... }:

{
  # let Home Manager install and manage itself
  programs.home-manager.enable = true;

  home.username = "jfreeland";
  home.homeDirectory = "/Users/jfreeland";
  home.stateVersion = "21.11";

  imports = [
    ./config/home-manager/direnv.nix
    ./config/home-manager/fzf.nix
    ./config/home-manager/gnupg.nix
    ./config/home-manager/homebrew.nix
    # ./config/home-manager/iterm2.nix
    ./config/home-manager/xdg.nix
    ./config/home-manager/vscode.nix
  ];
}
