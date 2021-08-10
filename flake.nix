{
  description = "Container setup script for use of systemd-nspawn containers on non-nixos systems";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
  inputs.flake-utils.url = github:nwg/flake-utils;

  outputs = { self, nixpkgs, flake-utils } @ args:
   with nixpkgs.lib;
   with flake-utils.lib;
    let
      #system = "x86_64-linux";
      overlay = (import ./container-system.nix { inherit nixpkgs; }).overlay;
      makePkgs = system: import nixpkgs { inherit system; overlays = [ overlay ]; };
      pkgs = import nixpkgs { system = "x86_64-linux"; overlays = [ overlay ]; };
    in
      {
        inherit overlay;
        
        packages = forAllSystems (system:
          let
            pkgs = makePkgs system;
          in
            {
              supportContainers = pkgs.supportContainers;
            });

        defaultPackage = forAllSystems (system: self.packages.${system}.supportContainers);
      };
}
