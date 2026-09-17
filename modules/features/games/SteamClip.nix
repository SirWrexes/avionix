# Unused: The app kinda sucks, it doesn't let you cut the clip
{ self, inputs, ... }:
{
  flake.nixosModules.gaming =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.gaming.tools.steamclip;
      steamcfg = config.gaming.platforms.steam;
    in
    {
      options.gaming.tools.steamclip.enable = lib.mkEnableOption "SteamClip" // {
        apply =
          x:
          if cfg.enable && !steamcfg.enable then
            lib.warn "SteamClip is enabled but not Steam itself." x
          else
            x;
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          self.packages.${pkgs.stdenv.hostPlatform.system}.python314Packages.steamclip
        ];
      };
    };

  perSystem =
    {
      self',
      pkgs,
      lib,
      ...
    }:
    {
      packages.steamclip = pkgs.python3Packages.buildPythonApplication rec {
        pname = "steamclip";
        version = "4.6";

        src = pkgs.fetchFromGitHub {
          owner = "Nastas95";
          repo = "SteamClip";
          rev = "v4.6";
          sha256 = "sha256-WD/zdGkk2Kmek+kOvyi2iJO/UFJc3t4Ll3P2QayFVCI=";
        };

        format = "other";

        propagatedBuildInputs = with pkgs.python3Packages; [
          imageio
          imageio-ffmpeg
          pathvalidate
          pillow
          pyqt6
          requests
        ];

        nativeBuildInputs = with pkgs; [
          python3Packages.wrapPython
          qt6.qtbase
          qt6.wrapQtAppsHook
        ];

        installPhase = ''
          runHook preInstall

          mkdir -p "$out/lib/python3/site-packages" "$out/bin"
          cp steamclip.py "$out/bin/steamclip"
          chmod +x "$out/bin/steamclip"

          runHook postInstall
        '';

        meta = {
          mainProgram = "steamclip";
          description = "Glitch free MP4 conversion of your Steam clips";
          license = lib.licenses.gpl3;
          homepage = "https://github.com/Nastas95/SteamClip";
          changelog = "https://github.com/Nastas95/SteamClip/releases/tag/v${version}";
        };
      };
    };
}
