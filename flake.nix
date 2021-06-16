{
  description = "A very basic flake";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
  inputs.simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-21.05";
  inputs.simple-nixos-mailserver.inputs.nixpkgs.follows = "nixpkgs";
  
  outputs = { self, nixpkgs, simple-nixos-mailserver }:
    with nixpkgs.lib;
    let
      system = "x86_64-linux";
      containerSystem = import ./containerSystem.nix { inherit system; inherit nixpkgs; };

      commonModule = {
        system.configurationRevision = mkIf (self ? rev) self.rev;
      };
        
      mailModule = import ./mail.nix {
        inherit simple-nixos-mailserver;
      };
      mailContainer = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ commonModule mailModule ];
      };
    in
      {
        defaultPackage.${system} = containerSystem.scripts;

        packages.${system}.mailContainer = mailContainer.config.system.build.toplevel;
      };
}
