{ self, ... }:
{
  flake.nixosModules.programs =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.programs.mangohud;
    in
    {
      options.programs.mangohud = {
        enable = lib.mkEnableOption "MangoHUD";
        package = lib.mkPackageOption self.packages.${pkgs.stdenv.hostPlatform.system} "mangohud" { };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ cfg.package ];
      };
    };

  # TODO: Make config file through nix to add implicit dependency on font (Fira NerdFont)
  perSystem =
    {
      self',
      pkgs,
      lib,
      ...
    }:
    let
      # Ue plain `writeText` instead of `toINI` to preserve order of insertion, needed to order the sections
      configFile = pkgs.writeText "config.ini" ''
        fps
        network
        cpu_stats
        gpu_stats
        ram

        legacy_layout=false
        gpu_temp
        fps_color_change
        proc_vram
        toggle_logging=Shift_L+F2
        toggle_hud_position=Control_L+Shift_L+F11
        fps_limit_method=late
        toggle_fps_limit=Shift_L+F1
        horizontal
        horizontal_stretch=0
        round_corners=3
        background_alpha=0.2
        position=top-left
        toggle_hud=Shift_R+F12
        font_size=13
        font_file=${pkgs.nerd-fonts.fira-code}/share/fonts/truetype/NerdFonts/FiraCode/FiraCodeNerdFont-Bold.ttf
        font_glyph_ranges=korean, chinese, chinese_simplified, japanese, cyrillic, thai, vietnamese, latin_ext_a, latin_ext_b
        gpu_color=2e9762
        cpu_color=2e97cb
        fps_value=30,60
        fps_color=cc0000,ffaa7f,92e79a
        gpu_load_value=60,90
        gpu_load_color=92e79a,ffaa7f,cc0000
        cpu_load_value=60,90
        cpu_load_color=92e79a,ffaa7f,cc0000
        background_color=000000
        frametime_color=00ff00
        vram_color=ad64c1
        ram_color=c26693
        wine_color=eb5b5b
        engine_color=eb5b5b
        text_color=ffffff
        media_player_color=ffffff
        network_color=e07b85
        battery_color=92e79a
        horizontal_separator_color=ffffff
        media_player_format={title};{artist};{album}
      '';
    in
    {
      packages.mangohud = pkgs.symlinkJoin {
        name = "mangohud-wrapped";
        meta.mainProgram = pkgs.mangohud.meta.mainProgram;
        paths = [ pkgs.mangohud ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          rm $out/bin/mangohud
          rm $out/bin/mangoapp

          makeWrapper ${pkgs.mangohud}/bin/mangohud $out/bin/mangohud \
            --set-default MANGOHUD_CONFIGFILE '${configFile}'

          makeWrapper ${pkgs.mangohud}/bin/mangoapp $out/bin/mangoapp \
            --set-default MANGOHUD_CONFIGFILE '${configFile}'
        '';
      };
    };
}
