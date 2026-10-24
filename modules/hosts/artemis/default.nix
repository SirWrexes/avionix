{
  flake.nixosModules.hosts =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib)
        mkIf
        ;

      # See https://github.com/NixOS/nixpkgs/issues/575192 and https://github.com/NixOS/nixpkgs/pull/576293
      patch = pkgs.fetchpatch2 {
        url = "https://github.com/NixOS/nixpkgs/commit/0923331843f01909ddbd657690468643cf2a5aec.diff?full_index=1";
        hash = "sha256-enLTAX2seKD3CEJ4AliD/aEgCtNo1FGDc4KvPA/S6Bg=";
      };

      nixpkgs-576293' = pkgs.applyPatches {
        src = pkgs.path;
        patches = [ patch ];
      };

      nixpkgs-576293 = import nixpkgs-576293' {
        inherit (pkgs.stdenv.hostPlatform) system;
        config = { inherit (config.nixpkgs.config) allowUnfree; };
      };
    in
    mkIf (config.host == "artemis") {
      boot.kernelPackages = nixpkgs-576293.linuxPackages_xanmod_latest;

      hardware.openrazer = {
        enable = true;
        users = [ config.users.user.name ];
      };

      services.razerbat = {
        enable = true;
        devices = [ "Razer Naga V2 HyperSpeed" ];
      };

      services.input-remapper = {
        enable = true;
        configDir = "${config.flake.root}/modules/hosts/artemis/input-remapper";
      };

      display.monitors =
        let
          iiyama = device: {
            inherit device;
            width = 3440;
            height = 1440;
            refreshRate = 165;
          };
        in
        [
          ((iiyama "DP-1") // { primary = true; })
          (iiyama "DP-2")
        ];
    };
}
