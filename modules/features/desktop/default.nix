{ self, inputs, ... }:
{
  flake.nixosModules.desktop =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.desktop;
    in
    {
      # This option is here mainly to check from other modules that this one has been imported (and thus enabled).
      options.desktop.enable = lib.mkEnableOption "graphical session" // {
        default = true;
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
          gimp
          mpv
          yt-dlp
        ];
      };
    };
}
