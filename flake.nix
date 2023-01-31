{
  description = "stove's nix sandbox";

  inputs.nixpkgs.url = "nixpkgs/nixos-22.11";

  nixConfig = {
    extra-substituters = ["s3://rivos-nix-cache?region=us-west-1"];
    extra-trusted-public-keys = ["nix-cache.ba.rivosinc.com-1:+VQgHlJeU5uI2xaO9EpWMijpXSXUiijgmPWjCWPgTC4="];
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    cfg = nixpkgs.lib.nixosSystem {
      modules = [./rv64-nixos-config.nix];
      system = "x86_64-linux";
    };
  in {
    packages.x86_64-linux = {
      riscv-vm = cfg.config.system.build.vm;
    };

    devShells.x86_64-linux.speccpu-novec = let
      pkgs = (import nixpkgs) {
        config.replaceStdenv = {pkgs, ...}: pkgs.gcc12Stdenv;
        system = "x86_64-linux";
        overlays = [
          (final: prev: {
            gfortran = prev.gfortran12;
            glibc =
              (prev.glibc.overrideAttrs (finalAttrs: {
                dontStrip = true;
              }))
              .override {
                stdenv = final.stdenvAdapters.withCFlags ["-ggdb" "-fno-tree-vectorize"] final.stdenv;
              };
          })
        ];
      };
      specStdenv = pkgs.stdenvAdapters.impureUseNativeOptimizations pkgs.stdenv;
    in
      pkgs.mkShell.override { stdenv = specStdenv; } {
        name = "gcc12-novectorization";
        packages = [pkgs.gfortran pkgs.glibc.static];
        hardeningDisable = [ "all" ];
      };
  };
}
