{
  pkgs ? import <nixpkgs> { system = builtins.currentSystem; },
}:
pkgs.writeShellScriptBin "yt-dlp" ''
  #! ${pkgs.runtimeShell}
  ${pkgs.uv}/bin/uvx -p ${pkgs.python312}/bin/python3 --refresh --prerelease allow yt-dlp --remote-components ejs:github --js-runtimes deno:${pkgs.deno}/bin/deno "$@"
''
