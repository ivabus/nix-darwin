{
  config,
  pkgs,
  lib,
  # rust-overlay,
  ...
}:

let
  cfg = config.my.roles.devel;
  # arm_fix = arm: builtins.replaceStrings [ "arm64" ] [ "aarch64" ] arm;
in
{
  options.my.roles.devel.enable = lib.mkEnableOption "Enable developer tools";

  config = lib.mkIf (cfg.enable) {
    # nixpkgs.overlays = [
    # rust-overlay.overlays.default
    # ];
    environment.variables = {
      LIBRARY_PATH = "${pkgs.libiconv}/lib:\${LIBRARY_PATH}";
    };
    environment.systemPackages = with pkgs; [
      # (rust-bin.nightly.latest.default.override {
      #   extensions = [
      #     "rust-src"
      #   ];
      #   targets = [
      #     (arm_fix pkgs.stdenv.hostPlatform.config)
      #     "x86_64-unknown-linux-musl"
      #     "aarch64-unknown-linux-musl"
      #     "riscv64gc-unknown-linux-gnu"
      #     "wasm32-unknown-unknown"
      #   ];
      # })
      rustup
      clang
      llvm
      lld
      coreutils-prefixed
      devenv
      gnugrep
      gnumake
      automake
      autoconf
      meson
      ninja
      picocom
      screen
      hyperfine
      sshfs
      go
      wrk
      cloc
      # python314Packages.ipykernel
      # python314Packages.torch
      # python314Packages.numpy
      # python314Packages.matplotlib
      # python314Packages.scikit-learn
    ];
  };
}
