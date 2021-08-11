{ nixpkgs, overlayAttrName }:
let
  lib = nixpkgs.lib;
  makeBaseConfig = hostName: domain: {
    boot.isContainer = true;
    networking.useDHCP = false;
    networking.hostName = hostName;
    networking.domain = domain;
  };
  
  overlay = final: prev: {
    ${overlayAttrName} = (prev . ${overlayAttrName} or {}) // rec {
      makeSimpleContainerNixos = hostName: domain: extraModules:
        lib.nixosSystem {
          system = prev.system;
          modules = [ (makeBaseConfig hostName domain) ] ++ extraModules;
        };
      makeSimpleContainer = hostName: domain: extraModules:
        (makeSimpleContainerNixos hostName domain extraModules).config.system.build.toplevel;

      makeDummyContainer = hostName: domain: makeSimpleContainer hostName domain [];
    };
  };
in {
  inherit overlay;
}
