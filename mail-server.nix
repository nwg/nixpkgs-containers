{ config, lib, pkgs, ... } @ args:

with lib;
let cfg = config.mailServerContainer;
in
{
  options.mailServerContainer = {
    enable = mkEnableOption "Mail Server Container";

    containerName = mkOption {
      type = types.str;
    };
    
  };

  config = mkIf cfg.enable {
    containers.abc = {
      config =
                  { config, pkgs, ... }:
                  { services.postgresql.enable = true;
                    services.postgresql.package = pkgs.postgresql_9_6;

                    system.stateVersion = "17.03";
                  };
    };
  };
}
#       config =
#         ({ pkgs, ... }: {
#           boot.isContainer = true;

#           # Let 'nixos-version --json' know about the Git revision
#           # of this flake.

#           # Network configuration.
#           networking.useDHCP = false;
# #          networking.firewall.allowedTCPPorts = [ 25 587 993 ];
#           networking.hostName = "smtp";
#           networking.domain = "nan.sh";
#         });
        # simple-nixos-mailserver.nixosModule
        # {
        #   mailserver = {
        #     enable = true;
        #     fqdn = "smtp.nan.sh";
        #     domains = [ "nan.sh" ];

        #     loginAccounts = {
        #       "nate@nan.sh" = {

        #         # sudo su -
        #         # nix shell 'nixpkgs#apacheHttpd'
        #         # htpasswd -nB "" | cut -d: -f2 > '/var/lib/container-support/mail-server/passwords/nate@nan.sh'
        #         # ^D^D
        #         hashedPasswordFile = "/nix/var/nix/profiles/run/passwords/nate@nan.sh";

        #         aliases = [
        #           "root@nan.sh"
        #           "postmaster@nan.sh"
        #           "abuse@nan.sh"
        #           "forensic@nan.sh"
        #           "tls-reports@nan.sh"
        #           "admin@nan.sh"
        #         ];
        #       };
        #     };
        #   };
        # }
      # ];
      
#     };
#   };
  
# }
