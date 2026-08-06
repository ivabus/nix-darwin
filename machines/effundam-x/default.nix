{
  pkgs,
  ...
}:
let
  my = import ../..;
in
{
  imports = [
    my.modules
    ./services.nix
  ];

  networking = {
    computerName = "Effundam on X";
    hostName = "effundam-x";
    localHostName = "effundam-x";
  };

  homebrew.brews = [ "chromium" ];
  my.roles.devel.enable = false;
  environment.systemPackages = with pkgs; [
    aria2
    fastfetch
    imagemagick

    bento4
    n-m3u8dl-re
    ffmpeg
    vgmstream

    uv
    (pkgs.callPackage ../../pkgs/yt-dlp-rolling.nix { })

    #gallery-dl
    #streamlink
    yggdrasil

  ];
  nixpkgs.config.allowUnsupportedSystem = true;

  system.configurationRevision = null;

  system.stateVersion = 6;

  nixpkgs.hostPlatform = "aarch64-darwin";
}
