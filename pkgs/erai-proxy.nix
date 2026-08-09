{
  pkgs ? import <nixpkgs> { system = builtins.currentSystem; },
}:
pkgs.writeScriptBin "erai-proxy" ''
  #!${pkgs.deno}/bin/deno run --allow-net --allow-env=PORT,TARGET_URL,FS_URL
  ${builtins.readFile ./erai-proxy.ts}
''
