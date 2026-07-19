{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.caddy-darwin;
  caddyfile_from_parts =
    parts:
    pkgs.writeTextFile {
      name = "Caddyfile";
      text = parts |> builtins.filter (x: x != "") |> builtins.concatStringsSep "\n";
    };
in
{
  options.services.caddy-darwin = {
    enable = lib.mkEnableOption "Enable caddy webserver";
    raw_parts = lib.mkOption {
      default = { };
      type = lib.types.listOf lib.types.str;
      description = "Raw definitions of parts of caddy config. Will be concatinated with `\\n`";
    };
  };

  config = lib.mkIf (cfg.enable) {
    launchd.daemons = {
      "caddy-darwin" = {
        command = "${pkgs.caddy}/bin/caddy run --config ${caddyfile_from_parts cfg.raw_parts} --adapter caddyfile";
        serviceConfig = {
          KeepAlive = true;
          RunAtLoad = true;
          StandardOutPath = "/tmp/caddy-darwin.out.log";
          StandardErrorPath = "/tmp/caddy-darwin.err.log";
        };
      };
    };
  };
}
