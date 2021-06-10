{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.nixos-systemd-nspawn = import ./nixos-systemd-nspawn.nix {
          inherit nixpkgs;
          inherit system;
          flake = self;
        };
        
        defaultPackage = self.packages.${system}.nixos-systemd-nspawn;
      }
    );
}
