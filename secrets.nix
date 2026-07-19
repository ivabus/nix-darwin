{ ... }:
let
  canaryHash = builtins.hashFile "sha256" ./secrets/canary;
  expectedHash = "ee66df1685f1a1fc980ca47aca2e7262de892c2e7aabdbaa62da952c4bbc48bf";
in
if (canaryHash != expectedHash) then
  abort "Secrets are enabled and not readable. Have you run `git-crypt unlock`?"
else
  {
    erai-raws-token = builtins.readFile ./secrets/erai-raws-token;
    hosts = import ./secrets/hosts.nix;
    yggdrasil = import ./secrets/yggdrasil.nix;
  }
