{ nixpkgs, system }:
let
  myModule = ({ pkgs, ... }: {
    time.timeZone = "America/Chicago";
    system.stateVersion = "21.05";
    boot.enableContainers = true;
    systemd.services."container@" = {
      # the start script fails to touch these if they are broken symlinks
      preStart = ''
                if [ -d $root ]
                then
                  rm $root/etc/{os-release,machine-id}
                fi
              '';
    };
    networking.nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "enp2s0";
    };            
  });

  nixos = nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [ "${nixpkgs}/nixos/modules/virtualisation/docker-image.nix" myModule ];
  };
  
  showAttrs = name: value: "${name}";
  blah = builtins.trace (toString (nixpkgs.lib.mapAttrsToList showAttrs nixos.pkgs)) "hello";
in
with nixpkgs.legacyPackages.${system};
stdenv.mkDerivation {
  name = "nixos-systemd-nspawn";
  unpackPhase = ":";
  installPhase = ''
      mkdir -p $out/etc/systemd/system
      ln -s ${nixos.config.system.build.toplevel}/etc/systemd/system/{nat,container@}.service $out/etc/systemd/system/
  '';
}
