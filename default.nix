rec {
  common = import ./common;
  roles = import ./roles;
  services = import ./services;
  secrets = import ./secrets.nix;

  modules =
    { ... }:
    {
      imports = [
        common
        roles
        services
      ];
    };
}
