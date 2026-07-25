{
  ...
}:
{
  # Installing homebrew
  nix-homebrew = {
    enable = true;

    autoMigrate = true;

    user = "ivabus";
    mutableTaps = true;
  };
}
