{
  homebrew-core,
  homebrew-cask,
  ...
}:
{
  # Installing homebrew
  nix-homebrew = {
    enable = true;

    autoMigrate = true;

    user = "ivabus";
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
    };
    mutableTaps = false;
  };
}
