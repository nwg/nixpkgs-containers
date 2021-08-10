{
  description = "Container setup script for use of systemd-nspawn containers on non-nixos systems";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
  outputs = { self, nixpkgs } @ args:
    with nixpkgs.lib;
    let
      system = "x86_64-linux";
      overlay = (import ./container-system.nix { inherit nixpkgs; }).overlay;
      pkgs = import nixpkgs { system = "x86_64-linux"; overlays = [ overlay ]; };
    in
      {
        inherit overlay;
        defaultPackage.x86_64-linux = pkgs.supportContainers;
      };
}
