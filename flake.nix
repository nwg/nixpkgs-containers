{
  description = "Container setup script for use of systemd-nspawn containers on non-nixos systems";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
  inputs.flake-utils.url = github:nwg/flake-utils;
  #inputs.flake-utils.url = git+file:///home/griswold/project/nwg-flake-utils;

  outputs = { self, nixpkgs, flake-utils } @ args:
   with nixpkgs.lib;
   with flake-utils.lib;
    let
      fu = flake-utils.lib;
      version = "0.1";
      overlay = (import ./container-scripts.nix { inherit nixpkgs version; }).overlay;
      makePkgs = system: import nixpkgs { inherit system; overlays = [ overlay ]; };
      forSystems = fu.forNixosSystems;
    in
      {
        inherit overlay;
        
        packages = forSystems (system:
          let
            pkgs = makePkgs system;
          in
            {
              nspawnContainerScripts = pkgs.nspawnContainerScripts;
            });

        defaultPackage = forSystems (system: self.packages.${system}.nspawnContainerScripts);
      };
}
