{ nixpkgs, overlayAttrName }:
let
  lib = nixpkgs.lib;
  makeSupportScripts = pkgs:
    let
      nixos = let
        containersBaseConfig = {
          time.timeZone = "UTC";
          
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
        };
      in
        nixpkgs.lib.nixosSystem {
          system = pkgs.system;
          modules = [ "${nixpkgs}/nixos/modules/virtualisation/docker-image.nix" containersBaseConfig ];
        };

      osroot = nixos.config.system.build.toplevel;
      nixosContainerWrapper = pkgs.writeScriptBin "nixos-container-i18n-wrapper" ''
        export LOCALE_ARCHIVE="${nixos.config.i18n.glibcLocales}/lib/locale/locale-archive"    
        exec "${osroot}/sw/bin/nixos-container" "$@"
      '';

    in
      pkgs.stdenv.mkDerivation {
        name = "nixos-systemd-nspawn-0.1";
        unpackPhase = ":";
        installPhase = ''
          mkdir -p $out/lib/systemd/system $out/bin
          ln -s ${osroot}/etc/systemd/system/{nat,container@}.service $out/lib/systemd/system/
          ln -s ${nixosContainerWrapper}/bin/nixos-container-i18n-wrapper $out/bin/nixos-container
        '';
      } // {
        tempNixos = nixos;
      };
  
in
{
  inherit makeSupportScripts;

  overlay = final: prev: {
    ${overlayAttrName} = (prev . ${overlayAttrName} or {}) // {
      supportContainers = makeSupportScripts final;
    };
  };
}
