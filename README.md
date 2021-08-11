Containers using the nixos infrastructure, but for non-nixos systems, or for
those who just want to isolate the container setup. 

Adapted to a flake from https://github.com/corngood/portable-nixos-container

# Instructions

Note you must be using the newer nix, which can currently be installed (if you
are on the old version) using nix-env -iA 'nixpkgs.nixUnstable'. You should
do this system-wide (into root's nix profile, as this is the system
environment) and restart any builders using `systemctl restart nix-daemon`

```
# (as root)
nix profile install github:nwg/nixpkgs-containers
ln -s /nix/var/nix/profiles/default/lib/systemd/system/{nat,container@}.service /etc/systemd/system
systemctl daemon-reload
systemctl start nat
mkdir -p /etc/systemd/system/network.target.wants
ln -s /etc/systemd/system/nat.service /etc/systemd/system/network.target.wants/

# init your container, probably as a normal user
git init my-system
cd my-system
nix flake init -t templates#simpleContainer
git add -A
git commit -m 'Initial commit'

# start up container as root
nixos-container create my-system --flake /path/to/my-system
nixos-container start my-system

curl http://my-system
# output is <html><body><h1>It works!</h1></body></html>
```

for more info on flake container init, see https://www.tweag.io/blog/2020-07-31-nixos-flakes/

# Other setup

* Once the container is created, you can make further manual edits to /etc/containers/my-system.conf
  * If you are using a firewall, open ports using the (comma-separated) `HOST_PORT` setting
  * If you want extra options to systemd-nspawn (see man systemd-nspawn), use `EXTRA_NSPAWN_FLAGS`
* Start container at boot
  * `ln -s /etc/systemd/system/container@.service /etc/systemd/system/multi-user.target.wants/container@my-system.service`
