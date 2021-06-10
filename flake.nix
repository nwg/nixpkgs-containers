{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
#    flake-utils.lib.eachDefaultSystem (system:
    let
      system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.x86_64-linux.hello = pkgs.hello;
        packages.x86_64-linux.nixos-systemd-nspawn = import ./nixos-systemd-nspawn.nix {
          inherit nixpkgs;
          inherit system;
        };
        
        defaultPackage = self.packages.${system}.hello;
      }
    ;
}
