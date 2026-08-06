{ ... }:
let
  canaryHash = builtins.hashFile "sha256" ./secrets/canary;
  expectedHash = "ee66df1685f1a1fc980ca47aca2e7262de892c2e7aabdbaa62da952c4bbc48bf";
in
if (canaryHash != expectedHash) then
  builtins.warn
    "Secrets are not readable and will be populated with sample values. Have you run `git-crypt unlock`?"
    # Exist to be used in CI to populate my binary cache
    {
      erai-raws-token = "";
      hosts = { };
      yggdrasil = {
        "effundam-x" = "";
        "celerrime-x" = "";
      };
      attic = {
        access-key = "";
        conf = "";
      };
      teloxide-token = "";
    }
else
  {
    erai-raws-token = builtins.readFile ./secrets/erai-raws-token;
    hosts = import ./secrets/hosts.nix;
    yggdrasil = import ./secrets/yggdrasil.nix;
    teloxide-token = builtins.readFile ./secrets/teloxide-token;
    attic = import ./secrets/attic.nix;
  }
