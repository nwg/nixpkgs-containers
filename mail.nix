{ simple-nixos-mailserver }:
{
  require = [ simple-nixos-mailserver.nixosModule ];
  boot.isContainer = true;

  networking.useDHCP = false;
  networking.hostName = "smtp";
  networking.domain = "nan.sh";
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
