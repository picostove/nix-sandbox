{
  description = "stove's nix sandbox";

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
