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
    mailServerContainer = {
      enable = true;
      containerName = "blah";
    };
    system.configurationRevision = pkgs.lib.mkIf (flake ? rev) flake.rev;
  });

  nixos =
    # let config = { pkgs, ... }:
    # {
    #   mailServerContainer = {
    #     enable = true;
    #     containerName = "blah";
    #   };
    #   system.configurationRevision = pkgs.lib.mkIf (flake ? rev) flake.rev;
    # };
    # in
    nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [ "${nixpkgs}/nixos/modules/virtualisation/docker-image.nix" myModule (import ./mail-server.nix) ];
    };
in
with nixpkgs.legacyPackages.${system};
with nixpkgs.legacyPackages.${system}.lib;

let
  nixosContainerWrapper = pkgs.writeScriptBin "nixos-container-i18n-wrapper" ''
    export LOCALE_ARCHIVE="${nixos.config.i18n.glibcLocales}/lib/locale/locale-archive"
    
    exec "${nixos.config.system.build.toplevel}/sw/bin/nixos-container" "$@"
  '';

in
stdenv.mkDerivation {
  name = "nixos-systemd-nspawn-0.1";
  unpackPhase = ":";
  installPhase = ''
      mkdir -p $out/lib/systemd/system $out/bin
      ln -s ${nixos.config.system.build.toplevel}/etc/systemd/system/{nat,container@}.service $out/lib/systemd/system/
      ln -s ${nixosContainerWrapper}/bin/nixos-container-i18n-wrapper $out/bin/nixos-container
  '';
}
