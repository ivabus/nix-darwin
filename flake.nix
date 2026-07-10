{
  description = "maro's nix-darwin configuration";

  inputs = {
    # pinning everything here instead of flake.lock.
    #nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/f205b5574fd0cb7da5b702a2da51507b7f4fdd1b";

    #nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.url = "github:nix-darwin/nix-darwin/d5bd9cd77aea4c0a8f49e7fd85545671a208ed15";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    #nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew/de7953a08ed4bb9245be043e468561c17b89130d";

    #rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.url = "github:oxalica/rust-overlay/e598b37857b895b81020a65a802ef55f5bbed72f";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
      rust-overlay,
      homebrew-core,
      homebrew-cask,
      ...
    }:
    {
      darwinConfigurations."celerrime-x" = nix-darwin.lib.darwinSystem {
        specialArgs = inputs;
        modules = [
          ./machines/celerrime-x
          nix-homebrew.darwinModules.nix-homebrew
          (
            { ... }:
            {
              environment.etc."nix/nix.custom.conf".text = ''
                nix-path = nixpkgs=flake:nixpkgs
              '';

              nix.registry.nixpkgs.flake = nixpkgs;
            }
          )
        ];
      };
      darwinConfigurations."effundam-x" = nix-darwin.lib.darwinSystem {
        specialArgs = inputs;
        modules = [
          ./machines/effundam-x
          nix-homebrew.darwinModules.nix-homebrew
          (
            { ... }:
            {
              environment.etc."nix/nix.custom.conf".text = ''
                nix-path = nixpkgs=flake:nixpkgs
              '';

              nix.registry.nixpkgs.flake = nixpkgs;
            }
          )
        ];
      };
    };
}
