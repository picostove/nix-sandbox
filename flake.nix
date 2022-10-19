{
  description = "stove's nix sandbox";

  inputs.nixpkgs.url = "github:picostove/nixpkgs?ref=dev/stove/riscv64-cross-boot-test";

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
  };
}
