{ flake, nixpkgs, system }:
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
in
with nixpkgs.legacyPackages.${system};
with nixpkgs.legacyPackages.${system}.lib;
stdenv.mkDerivation {
  name = "nixos-systemd-nspawn-0.1";
  unpackPhase = ":";
  installPhase = ''
      mkdir -p $out/lib/systemd/system
      ln -s ${nixos.config.system.build.toplevel}/etc/systemd/system/{nat,container@}.service $out/lib/systemd/system/
  '';
}
