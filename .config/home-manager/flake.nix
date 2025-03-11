{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      url = "git+ssh://git@github.com/ghostty-org/ghostty";
    };
  };

  outputs = { self, nixpkgs, home-manager, ghostty, ... }:
    let
      system = "aarch64-darwin";  # or "x86_64-darwin" if you are on an Intel-based Mac
    in {
      nixosConfigurations.mysystem = nixpkgs.lib.nixosSystem {
        system = system;
        modules = [
          {
            environment.systemPackages = [
              ghostty.packages.${system}.default
            ];
          }
        ];
      };

      homeConfigurations.jfreeland = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          {
            home.username = "jfreeland";
            home.homeDirectory = "/Users/jfreeland";
            programs.home-manager.enable = true;
            home.stateVersion = "21.11";

            home.packages = [
              # No aarch64-apple-darwin
              # ghostty.packages.${system}.default
            ];

            imports = [
              ./config/home-manager/direnv.nix
              #./config/home-manager/fzf.nix
              ./config/home-manager/gnupg.nix
              ./config/home-manager/homebrew.nix
              # ./config/home-manager/iterm2.nix
              ./config/home-manager/xdg.nix
              # ./config/home-manager/vscode.nix
              #./config/home-manager/ghostty.nix
            ];
          }
        ];
      };
    };
}
