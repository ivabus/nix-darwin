{
  pkgs,
  config,
  secrets,
  ...
}:
let
  my = import ../..;

in
{
  imports = [ my.modules ];

  my.roles.devel.enable = true;

  networking = {
    computerName = "Celerrime on X";
    hostName = "celerrime-x";
    localHostName = "celerrime-x";
  };

  security.pam.services.sudo_local = {
    touchIdAuth = true;
  };

  environment.systemPackages = with pkgs; [
    (mpv-unwrapped.override {
      libbluray = libbluray.override {
        withAACS = true;
        withBDplus = true;
      };
    })

    vlc-bin-universal

    pi-coding-agent

    xld

    nixfmt
    nil
    cmake
    nixd
    # cargo
    aria2
    fastfetch
    imagemagick
    nmap
    pandoc
    typst
    typstyle

    bento4
    n-m3u8dl-re
    ffmpeg
    vgmstream
    go-chromecast

    python3Packages.jupytext

    uv

    (pkgs.callPackage ../../pkgs/yt-dlp-rolling.nix { })

    yggdrasil
  ];

  services.yggdrasil = {
    enable = true;
    config = secrets.yggdrasil."${config.networking.hostName}";
  };

  services.dnsmasq = {
    enable = true;
    addresses = secrets.hosts;
    servers = [
      "1.1.1.1"
      "8.8.8.8"
      "1.0.0.1"
      "8.8.4.4"
    ];
  };
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes pipe-operators
    '';
    settings = {
      auto-optimise-store = true;
      sandbox = "relaxed";
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

  documentation.enable = false;

  system.configurationRevision = null;

  system.stateVersion = 6;

  nixpkgs.hostPlatform = "aarch64-darwin";
}
