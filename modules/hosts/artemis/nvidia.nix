{ self, inputs, ... }:
{
  flake.nixosModules.artemis =
    { config, pkgs, ... }:
    {
      # Open source drivers or not, there's still a lot of proprietary code at play.
      nixpkgs.config.allowUnfree = true;

      # Add the drivers.
      services.xserver.videoDrivers = [ "nvidia" ];

      # Make sure we use the big boi GPU
      hardware.graphics.enable = true;

      hardware.nvidia = {
        # REQUIRED on Wayland (Niri)
        modesetting.enable = true;

        # Prefer open-source drivers. They will eventually replace the proprietary ones.
        open = true;
      };

      # Enable CUDA support system-wide.
      nixpkgs.config.cudaSupport = true;

      # Make sure we don't build *everything* from source for CUDA.
      # See https://wiki.nixos.org/wiki/CUDA#Setting_up_CUDA_Binary_Cache
      nix.settings = {
        substituters = [ "https://cache.nixos-cuda.org" ];
        trusted-public-keys = [ "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];
      };

      # Enable Multi-Process Service to improve GPU usage with CUDA
      # See <where link go??>
      systemd.services.nvidia-mps = {
        description = "NVIDIA CUDA Multi-Process Service";
        after = [ "nvidia-persistenced.service" ];
        requires = [ "nvidia-persistenced.service" ];
        wantedBy = [ "multi-user.target" ];
        path = [ config.hardware.nvidia.package.bin ];
        serviceConfig = {
          Type = "forking";
          ExecStart = "${config.hardware.nvidia.package.bin}/bin/nvidia-cuda-mps-control -d";
          ExecStop = "${pkgs.writeShellScript "nvidia-mps-stop" ''
            echo quit | ${config.hardware.nvidia.package.bin}/bin/nvidia-cuda-mps-control
          ''}";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    };
}
