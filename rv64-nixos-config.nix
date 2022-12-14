{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/virtualisation/qemu-vm.nix")
  ];
  virtualisation = {
    cores = 4;
    memorySize = 4096;
    graphics = false;
    qemu = {
    guestAgent.enable = false;
      package = lib.mkDefault (pkgs.buildPackages.qemu.override {
      libiscsiSupport = false;
      tpmSupport = false;
      alsaSupport = false;
      jackSupport = false;
      smartcardSupport = false;
      spiceSupport = false;
      openGLSupport = false;
      virglSupport = false;
      vncSupport = false;
      gtkSupport = false;
      sdlSupport = false;
      pulseSupport = false;
      smbdSupport = false;
      seccompSupport = false;
      # TODO: don't hardcode these
      hostCpuTargets = [
        "riscv64-softmmu"
      ];
    });
   };
  };
  boot.kernelPatches = [
    {
      name = "pci-config";
      patch = null;
      # Build the PCI host controller support into the kernel so it probes correctly.
      extraConfig = ''
        PCI_HOST_GENERIC y
      '';
    }
  ];

  boot.loader = {
    grub.enable = false;
    generic-extlinux-compatible = {
      enable = true;

      # Don't even specify FDTDIR - We do not have the correct DT
      # The DTB is generated by QEMU at runtime
      useGenerationDeviceTree = false;
    };
  };
  services.udisks2.enable = false;
  xdg.icons.enable = false;
  xdg.sounds.enable = false;

  nixpkgs = {
    crossSystem = {
      config = "riscv64-unknown-linux-gnu";
    };
  };

  users = {
    mutableUsers = false;
    users = {
      root = {
        password = "test0000";
      };
      nixos = {
        isNormalUser = true;
        extraGroups = ["wheel" "networkmanager" "video"];
        initialHashedPassword = "";
      };
    };
  };

  # Automatically log in at the virtual consoles.
  services.getty.autologinUser = "nixos";

  # Allow passwordless sudo from nixos user
  security.sudo = {
    enable = true;
    wheelNeedsPassword = lib.mkForce false;
  };

  system.stateVersion = "22.05";
}
