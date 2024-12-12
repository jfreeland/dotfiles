# I need to revisit this.  Putting it some place safe for now.
#{ pkgs ? import <nixpkgs> {} }:
#
#pkgs.mkShell {
#  buildInputs = [
#    pkgs.neovim
#    pkgs.granted
#    pkgs.firefox
#    pkgs.dotnet-sdk_8
#    pkgs.ripgrep
#    pkgs.silver-searcher
#    pkgs.tilt
#    pkgs.ctlptl
#    pkgs.kind
#    pkgs.dapr-cli
#    pkgs.k9s
#    pkgs.kubectl
#    pkgs.nodejs
#    pkgs.python3
#  ];
#
#  shellHook = ''
#    alias vim="nvim"
#    export PATH=~/.bin:$PATH
#  '';
#}
