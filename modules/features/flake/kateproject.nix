{ self, description, ... }:
{
  flake.nixosModules.flake =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib)
        attrNames
        concatStringsSep
        elem
        escapeShellArg
        first
        mkEnableOption
        mkIf
        optional
        split
        ;

      inherit (pkgs.stdenv.hostPlatform) system;
      inherit (config) host;
      inherit (config.programs) nh;

      cfg = config.flake;
      EDITOR = config.environment.sessionVariables.EDITOR or "";
    in
    {
      options.flake = {
        kateproject.enable = mkEnableOption "generating a `.kateproject` in ${cfg.root}" // {
          default = (lib.last (builtins.split "/" EDITOR) == "kate");
        };
      };

      config =
        let
          mkOsTargets =
            cmd:
            (map
              (target: {
                name = "NixOS: ${first (split " " target)}";
                build_cmd = target;
              })
              [
                "build -o ${escapeShellArg "build/os/${host}"}"
                "test"
                "switch"
              ]
            );

          nixTargets =
            (optional (elem "nix-command" config.nix.settings.experimental-features) [
              {
                name = "Update flake inputs";
                build_cmd = "nix flake update --flake .";
              }
            ])
            ++ (optional (!nh.enable) (mkOsTargets "nixos-rebuild --flake ${escapeShellArg ".#${host}"}"));

          nhTargets = optional (nh.enable) (
            mkOsTargets (
              concatStringsSep " " [
                "NH_FLAKE=${escapeShellArg cfg.root}"
                "NH_OS_FLAKE=${escapeShellArg "${cfg.root}#${host}"}"
                "NH_NOM=off"
                "nh os"
              ]
            )
          );

          packageTargets =
            let
              cmd =
                if elem "nix-command" config.nix.settings.experimental-features then "nix build" else "nix-build";
            in
            map (pkg: {
              name = "Build package: ${pkg}";
              build_cmd = "${cmd} ${escapeShellArg ".#packages.${system}.${pkg}"} -o ${escapeShellArg "build/pkgs/${pkg}"}";
            }) (attrNames self.packages.${system});

          finalTargets = nixTargets ++ nhTargets ++ packageTargets;

          kateproject = pkgs.writers.writeJSON ".kateproject" {
            name = description;
            files = [ { git = true; } ];
            build = {
              directory = cfg.root;
              targets = finalTargets;
            };
            lspclient.servers.nix = {
              highlightingModeRegex = "^Nix$";
              url = "https://github.com/oxalica/nil";
              command = [ (lib.getExe config.dev.nix.lsp) ];
              settings.nil.nix.flake = {
                autoArchive = true;
                autoEvalInputs = true;
              };
            };
          };
        in
        {
          systemd.user.tmpfiles.rules = mkIf cfg.kateproject.enable [
            "r  ${cfg.root}/.kateproject.build"
            "L+ ${cfg.root}/.kateproject - - - - ${kateproject}"
          ];
        };
    };
}
