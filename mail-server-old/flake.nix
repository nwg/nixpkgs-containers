{
  description = "NixOS configuration";

  inputs.simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-21.05";
  inputs.nixpkgs.follows = "simple-nixos-mailserver/nixpkgs";
  inputs.runStateInput = { flake = false; url = "path:/var/lib/container-support/mail-server";  };
  
  outputs = { self, nix, nixpkgs, simple-nixos-mailserver, runStateInput }:
    let system = "x86_64-linux";
        in
  {

    overlay = final: prev: {
      # runState = with final; lib.cleanSource runStateInput;
      runState = with final; pkgs.runCommand "blah" {} ''
        ln -s "${runStateInput}" "$out"
      '';
    };

    runState = (import nixpkgs {
      inherit system;
      overlays = [ self.overlay nix.overlay ];
    }).runState;
    
    nixosConfigurations.container = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ({ pkgs, ... }: {
          boot.isContainer = true;

          # Let 'nixos-version --json' know about the Git revision
          # of this flake.
          system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

          # Network configuration.
          networking.useDHCP = false;
#          networking.firewall.allowedTCPPorts = [ 25 587 993 ];
          networking.hostName = "smtp";
          networking.domain = "nan.sh";
        })
        simple-nixos-mailserver.nixosModule
        {
          mailserver = {
            enable = true;
            fqdn = "smtp.nan.sh";
            domains = [ "nan.sh" ];

            loginAccounts = {
              "nate@nan.sh" = {

                # sudo su -
                # nix shell 'nixpkgs#apacheHttpd'
                # htpasswd -nB "" | cut -d: -f2 > '/var/lib/container-support/mail-server/passwords/nate@nan.sh'
                # ^D^D
                hashedPasswordFile = "/nix/var/nix/profiles/run/passwords/nate@nan.sh";

                aliases = [
                  "root@nan.sh"
                  "postmaster@nan.sh"
                  "abuse@nan.sh"
                  "forensic@nan.sh"
                  "tls-reports@nan.sh"
                  "admin@nan.sh"
                ];
              };
            };
          };
        }
      ];
    };
  };
}
