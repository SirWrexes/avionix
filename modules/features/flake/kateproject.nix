{ self, ... }:
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
        getExe
        hasInfix
        head
        mkOption
        mkIf
        mkMerge
        mkPackageOption
        optional
        optionals
        split
        types
        ;

      inherit (pkgs.stdenv.hostPlatform) system;
      inherit (config) host;
      inherit (config.programs) nh;

      oneLiner = with types; addCheck str (s: !(hasInfix "\n" s));

      cfg = config.flake;
      EDITOR = config.environment.sessionVariables.EDITOR or "";
    in
    {
      options.flake.kateproject = {
        enable = mkOption {
          type = with types; bool;
          description = ''
            Enable generating a `.kateproject` project plugin in your flake's root directory.
            This file will add options to build, test, switch from inside Kate.
            It will also have options to build the various packages of your flake if `flake.kateproject.packages` is set.

            More info: https://docs.kde.org/stable_kf6/en/kate/kate/kate-application-plugin-projects.html
          '';
          default = (EDITOR == "kate");
        };

        lspclient =
          let
            devnix =
              if (config ? dev && config.dev ? nix) then
                config.dev.nix
              else
                {
                  languageServer = pkgs.nil;
                  formatter = pkgs.nixfmt;
                };
          in
          {
            package = mkPackageOption pkgs "nil" { } // {
              default = devnix.languageServer;
              apply = getExe;
            };

            args = mkOption {
              type = with types; listOf oneLiner;
              default = [ ];
            };

            settings = mkOption {
              type = with types; attrsOf json;
              default = {
                servers.nix = {
                  highlightingModeRegex = "^Nix$";
                  url = "https://github.com/oxalica/nil";
                  command = with cfg.kateproject.lspclient; [ package ] ++ args;
                  settings.nil = {
                    formatting.command = [ (getExe devnix.formatter) ];
                    nix.flake = {
                      autoArchive = true;
                      autoEvalInputs = true;
                    };
                  };
                };
              };
              description = ''
                LSP settings for your editor.
              '';
            };

            extraSettings = mkOption {
              type = with types; attrsOf json;
              default = { };
              description = ''
                Extra LSP settings for your editor.
                Will be merged with `flake.kateproject.lspSettings` using `lib.mkMerge`.
              '';
            };

            finalSettings = mkOption {
              type = with types; attrsOf json;
              readOnly = true;
              internal = true;
              default =
                with cfg.kateproject.lspclient;
                mkMerge [
                  settings
                  extraSettings
                ];
            };
          };
      };

      config =
        let
          mkOsTargets =
            cmd:
            (map
              (target: {
                name = "NixOS: ${head (split " " target)}";
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
            }) (attrNames cfg.self.packages.${system});

          finalTargets = nixTargets ++ nhTargets ++ (optionals (cfg.self ? packages) packageTargets);

          kateproject = pkgs.writers.writeJSON ".kateproject" {
            inherit (cfg) name;
            files = [ { git = true; } ];
            build = {
              directory = cfg.root;
              targets = finalTargets;
            };
            lspclient = cfg.kateproject.lspclient.finalSettings;
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
