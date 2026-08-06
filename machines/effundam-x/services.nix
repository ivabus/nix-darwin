args@{
  pkgs,
  lib,
  config,
  secrets,
  helpers,
  ...
}:
let
  web_daemons = [
    {
      name = "sonarr";
      command = "${pkgs.sonarr}/bin/Sonarr";
      expose = true;
      port = 8989;
      unprivileged = true;
    }
    # {
    #   name = "lidarr";
    #   command = "${no_check pkgs.lidarr}/bin/Lidarr";
    #   expose = true;
    #   port = 8686;
    #   unprivileged = true;
    # }
    {
      name = "prowlarr";
      command = "${helpers.no_check pkgs.prowlarr}/bin/Prowlarr";
      expose = false;
      unprivileged = true;
    }
    {
      name = "flaresolverr";
      command = "${pkgs.flaresolverr.overrideAttrs { postPatch = ""; }}/bin/flaresolverr";
      unprivileged = true;
      expose = false;
      workingDirectory = "/Users/ivabus/Flaresolverr";
    }

    {
      name = "attic";
      command = "${pkgs.attic-server}/bin/atticd --config ${pkgs.writeText "atticd.toml" secrets.attic.conf}";
      expose = true;
      unprivileged = true;
      port = 7648;
      workingDirectory = "/Users/ivabus/";
    }

    {
      name = "rustversebot";
      command = "${
        args.rustversebot.packages.${pkgs.stdenv.hostPlatform.system}.rustversebot
      }/bin/rustversebot";
      # command = "/Users/ivabus/rustversebot";
      environment = {
        TELOXIDE_TOKEN = secrets.teloxide-token;
        BOT_ADMIN_ID = "421488552";
        BOT_CONFIG_PATH = "/Users/ivabus/config.toml";
        BOT_WEB_BIND = "0.0.0.0:11234";
        TURSO_DATABASE_URL = "file:rustversebot.db";
      };
      unprivileged = true;
      expose = false;
      workingDirectory = "/Users/ivabus/";
    }

    {
      name = "kavita";
      command = "/Users/ivabus/Kavita/Kavita";
      expose = true;
      unprivileged = true;
      workingDirectory = "/Users/ivabus/Kavita";
      port = 5001;
    }
  ];

  web_daemon_to_caddy =
    daemon:
    if daemon.expose then
      ''
        http://${daemon.name}.ivabus.dev {
        	reverse_proxy http://127.0.0.1:${toString daemon.port}
        }
      ''
    else
      "";

  base_caddy_config = [
    (builtins.readFile ./Caddyfile)
  ];

  daemon =
    {
      name,
      command,
      unprivileged ? false,
      workingDirectory ? null,
      environment ? { },
      packages ? [ ],
      ...
    }:
    {
      "${name}" = {
        inherit command environment;
        path = packages;
        serviceConfig = lib.mkMerge [
          {
            KeepAlive = true;
            RunAtLoad = true;
            StandardOutPath = "/tmp/${name}.out.log";
            StandardErrorPath = "/tmp/${name}.err.log";
            WorkingDirectory = workingDirectory;
          }
          (lib.mkIf unprivileged {
            UserName = "ivabus";
            GroupName = "staff";
          })
        ];
      };
    };
in
{
  launchd.daemons = lib.mkMerge (web_daemons |> map daemon);

  services.yggdrasil = {
    enable = true;
    config = secrets.yggdrasil."${config.networking.hostName}";
  };

  services.caddy-darwin = {
    enable = true;
    raw_parts = base_caddy_config ++ (web_daemons |> map web_daemon_to_caddy);
  };

  services.erai-proxy = {
    enable = true;
    erai = {
      token = secrets.erai-raws-token;
      resolution = "1080p";
      subtitles = [ "us" ];
    };
  };
}
