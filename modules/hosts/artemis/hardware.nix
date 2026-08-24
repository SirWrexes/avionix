{ self, inputs, ... }:
{
  flake.nixosModules.artemis-hardware = { config, lib, pkgs, modulesPath, ... }:
  {
    imports =
      [ (modulesPath + "/installer/scan/not-detected.nix")
      ];

    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
    { device = "/dev/disk/by-uuid/dea2f351-ae95-49b0-a4b9-ed7bec17d452";
      fsType = "btrfs";
        };
    
      fileSystems."/home" =
        { device = "/dev/disk/by-uuid/dea2f351-ae95-49b0-a4b9-ed7bec17d452";
          fsType = "btrfs";
          options = [ "subvol=home" ];
        };
    
      fileSystems."/nix" =
        { device = "/dev/disk/by-uuid/dea2f351-ae95-49b0-a4b9-ed7bec17d452";
          fsType = "btrfs";
          options = [ "subvol=nix" ];
        };
    
      fileSystems."/boot" =
        { device = "/dev/disk/by-uuid/8E11-97AE";
          fsType = "vfat";
          options = [ "fmask=0077" "dmask=0077" ];
        };
    
      swapDevices =
        [ { device = "/dev/disk/by-uuid/a18061fe-5ce6-4933-a7da-d1a046fb5bdb"; }
        ];
    
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
