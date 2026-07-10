{
  config,
  pkgs,
  lib,
  ...
}:

let
  query_from_attr =
    attr:
    "?${
      builtins.concatStringsSep "&" (
        lib.mapAttrsToList (
          key: value:
          if builtins.typeOf value == "list" then
            builtins.concatStringsSep "&" (map (x: "${key}[]=${x}") value)
          else
            "${key}=${value}"
        ) (lib.filterAttrs (k: v: v != null) attr)
      )
    }";
  cfg = config.services.erai-proxy;
in
{
  options.services.erai-proxy = with lib.types; {
    enable = lib.mkEnableOption "Enable flaresolverr proxy for erai-raws.info";
    erai = lib.mkOption {
      description = "Settings for rss fetching";
      type = submodule {
        options = {
          base_url = lib.mkOption {
            description = "Base url for erai-raws (ends with /feed/)";
            default = "https://www.erai-raws.info/feed/";
            type = str;
          };
          resolution = lib.mkOption {
            description = "Resolution of torrents to request from erai-raws";
            default = null;
            type = nullOr (enum [
              "1080p"
              "720p"
              "SD"
            ]);
          };
          type = lib.mkOption {
            description = "Request torrents or magnets with rss";
            default = "magnet";
            type = enum [
              "torrent"
              "magnet"
            ];
          };
          subtitles = lib.mkOption {
            description = "List of languages to request subitiles of";
            default = [ ];
            type = listOf (enum [
              "us"
              "br"
              "mx"
              "es"
              "sa"
              "fr"
              "de"
              "it"
              "ru"
              "jp"
              "pt"
              "pl"
              "nl"
              "no"
              "fi"
              "tr"
              "se"
              "gr"
              "il"
              "ro"
              "id"
              "th"
              "kr"
              "dk"
              "cn"
              "bg"
              "vn"
              "in"
              "lk"
              "ua"
              "hu"
              "cz"
              "hr"
              "my"
              "sk"
              "ph"
            ]);
          };
          token = lib.mkOption {
            description = "Token from RSS url";
            type = str;
          };
        };
      };
    };
    port = lib.mkOption {
      description = "Port to serve proxy on";
      type = port;
      default = 9213;
    };
    flaresolverr_url = lib.mkOption {
      description = "Flaresolverr endpoint";
      type = str;
      default = "http://127.0.0.1:8191/v1";
    };
  };

  config = lib.mkIf (cfg.enable) {
    launchd.daemons = {
      "erai-proxy" = {
        command = "${pkgs.callPackage ../pkgs/erai-proxy.nix { }}/bin/erai-proxy";
        serviceConfig = {
          KeepAlive = true;
          RunAtLoad = true;
          StandardOutPath = "/tmp/erai-proxy.out.log";
          StandardErrorPath = "/tmp/erai-proxy.err.log";
        };
        environment = {
          FS_URL = "${cfg.flaresolverr_url}";
          TARGET_URL = "${cfg.erai.base_url}${
            query_from_attr {
              token = cfg.erai.token;
              type = cfg.erai.type;
              res = cfg.erai.resolution;
              subs = cfg.erai.subtitles;
            }
          }";
          PORT = toString cfg.port;
        };
      };
    };
  };
}
