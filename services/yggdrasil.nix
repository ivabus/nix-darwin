{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.yggdrasil;
in
{
  options.services.yggdrasil = {
    enable = lib.mkEnableOption "Enable yggdrasil";
    config = lib.mkOption {
      type = lib.types.str;
      description = "Raw yggdrasil config";
    };
  };

  config = lib.mkIf (cfg.enable) {
    launchd.daemons = {
      "yggdrasil" = {
        command = "${pkgs.writeShellScriptBin "yggdrasil-launcher" ''
          #!${pkgs.runtimeShell}
          # preparing directory for socket
          mkdir -p /var/run/yggdrasil/ || true
          ${pkgs.yggdrasil}/bin/yggdrasil -useconffile ${pkgs.writeText "yggdrasil.conf" cfg.config}
        ''}/bin/yggdrasil-launcher";

        serviceConfig = {
          KeepAlive = true;
          RunAtLoad = true;
          StandardOutPath = "/tmp/yggdrasil.out.log";
          StandardErrorPath = "/tmp/yggdrasil.err.log";
        };
      };
    };
  };
}
