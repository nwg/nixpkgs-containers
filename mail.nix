{ nixpkgs, simple-nixos-mailserver, system, ... }:
{ config, lib, pkgs, ... } @ args:

with lib;
let cfg = config.mailContainer;
in
{
  options.mailContainer = {
    containers = mkOption {
      description = "Mail Container Config";
      type = types.attrsOf (types.submodule (
        { config, name, ... }:
        let cfg = config;
        in
          {
            options = {
              enable = mkEnableOption "Enable the ${name} mail container";
              config = mkOption {
                type = types.attrs;
                description = "The NixOS Module for this container";
              };
            };
          }));
      apply = c:
        let
          mkContainer = name: m: (nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [ simple-nixos-mailserver.nixosModule m.config ];
            # modules = [];
          }).config.system.build.toplevel;
        in
          mapAttrs mkContainer c;
    };
  };
}
