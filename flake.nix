{
  description = "Container setup script for use of systemd-nspawn containers on non-nixos systems";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
  outputs = { self, nixpkgs } @ args:
    with nixpkgs.lib;
    let
      system = "x86_64-linux";
      
      containerSystem = import ./container-system.nix { inherit system; inherit nixpkgs; nixosModules = [ baseConfig mailContainers ]; };
    in
      {
        overlay = final: prev: {
          containerSystem.mkContainer = modules: import ./container-system.nix {
              pkgs = final;
          };
        };
      };
}
