{ pkgs, ... }:
let
  my = import ../.;
  secrets = my.secrets { };
in
{
  _module.args.secrets = secrets;

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
