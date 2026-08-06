{ pkgs, secrets, ... }:
let
  my = import ../.;
in
{
  _module.args = {
    secrets = my.secrets { };
    helpers = my.helpers;
  };

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes pipe-operators
    '';
    settings = {
      auto-optimise-store = true;
      sandbox = "relaxed";

      extra-substituters = [
        "https://attic.ivabus.dev/rustversebot?priority=20"
        "https://attic.ivabus.dev/darwin?priority=10"
      ];

      extra-trusted-public-keys = [
        "rustversebot:4OwNX9gIkMqvdPUqf6p5s2XnJZAgwe0QXiuTspTE52I="
        "darwin:IlyzS2u4MPxVscdFeI6xiPcgzsWl8INjXs6LBawg44A="
      ];

      netrc-file = pkgs.writeText "attic-netrc" ''
        machine attic.ivabus.dev
        password ${secrets.attic.access-key}
      '';

      trusted-users = [
        "root"
        "ivabus"
      ];
      allowed-users = [
        "root"
        "ivabus"
      ];
    };
  };

  environment.variables = {
    NH_DARWIN_FLAKE = "path:/private/etc/nix-darwin";
  };
  environment.systemPackages = with pkgs; [
    nh
    wget
    curl
    git
    git-crypt
    neovim
    python314
    python314Packages.certifi
    coreutils
  ];
}
