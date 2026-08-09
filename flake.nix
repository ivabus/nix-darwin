{
  description = "maro's nix-darwin configuration";

  inputs = {
    # pinning everything here instead of flake.lock.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    #nixpkgs.url = "github:NixOS/nixpkgs/f205b5574fd0cb7da5b702a2da51507b7f4fdd1b";
    # nixpkgs.url = "github:NixOS/nixpkgs/20535e48e12c86043b577b8518234ff5dbb26957";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    #nix-darwin.url = "github:nix-darwin/nix-darwin/d5bd9cd77aea4c0a8f49e7fd85545671a208ed15";
    # nix-darwin.url = "github:nix-darwin/nix-darwin/b4cccbd4bc299c1f71ae185b79c3cf99aa82805c";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    # nix-homebrew.url = "github:zhaofengli/nix-homebrew/842eeb863ecca0eeb463f7a814cdc51e1d925776";

    #rust-overlay.url = "github:oxalica/rust-overlay";
    # rust-overlay.url = "github:oxalica/rust-overlay/e598b37857b895b81020a65a802ef55f5bbed72f";
    # rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    rustversebot.url = "github:ivabus/rustversebot";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
      rustversebot,
      # rust-overlay,
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
              system.primaryUser = "ivabus";
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
