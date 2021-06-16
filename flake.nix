{
  description = "A very basic flake";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
  inputs.simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-21.05";
  inputs.simple-nixos-mailserver.inputs.nixpkgs.follows = "nixpkgs";
  
  outputs = { self, nixpkgs, simple-nixos-mailserver } @ args:
    with nixpkgs.lib;
    let
      system = "x86_64-linux";
      callFlakeModule = m: import m (args // { inherit system; });
      
      commonModule = {
        system.configurationRevision = mkIf (self ? rev) self.rev;
      };

      baseConfig = {
        mailContainer.containers.nanmail = {
          enable = true;
          config = import ./smtp-nan-sh.nix;
        };
      };

      mailContainers = callFlakeModule ./mail.nix;

      containerSystem = import ./container-system.nix { inherit system; inherit nixpkgs; nixosModules = [ baseConfig mailContainers ]; };
    in
      {
        defaultPackage.${system} = containerSystem.scripts;

        packages.${system}.nanmail = containerSystem.nixos.config.mailContainer.containers.nanmail;
      };
}
