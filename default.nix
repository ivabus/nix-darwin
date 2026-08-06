rec {
  common = import ./common;
  roles = import ./roles;
  services = import ./services;
  secrets = import ./secrets.nix;
  helpers = import ./helpers;

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
