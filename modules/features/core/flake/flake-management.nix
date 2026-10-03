{ iconsDir, ... }:
{
  flake.nixosModules.core =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (lib) types;
      inherit (config.core) flakePath hostName system;

      cfg = config.core.flake;

      updateFlakeInputsService = "update-flake-inputs";

      nh = lib.getExe config.programs.nh.package;
      nix = lib.getExe config.nix.package;
      nixos-rebuild = "${lib.getExe pkgs.nixos-rebuild-ng} --flake ${flakePath}#${hostName}";
    in
    {
      options.core.flake = {
        nh.enable = lib.mkEnableOption "nh as a nix wrapper" // {
          default = true;
        };

        # Took a couple hours to write this whole module subsection only to find out afterwards
        # about `system.autoUpgrade`.
        # Oh well, I like my module better anyway--not copium, I swear! 😨
        autoUpdate = {
          enable = lib.mkEnableOption "auto updating of flake inputs" // {
            default = true;
          };

          preRunHook = lib.mkOption {
            type = with types; str;
            description = "Runs before calling the update command. If it returns a non-zero value, the update is prevented.";
            default = "true";
            apply = pkgs.writeShellScript "${updateFlakeInputsService}.pre-run-hook";
          };

          command = lib.mkOption {
            type = with types; str;
            description = "The script that will run to update inputs";
            default = ''
              ${nix} flake update --flake "${flakePath}"
            '';
            apply = pkgs.writeShellScript "${updateFlakeInputsService}.command";
          };

          commit = {
            enable = lib.mkEnableOption "committing the lockfile after an update" // {
              default = true;
            };

            command = lib.mkOption {
              type = with types; str;
              description = "Command used to commit the updated lockfile.";
              default =
                let
                  inherit (cfg.autoUpdate.commit) message;

                  git = ''${lib.getExe config.programs.git.package} -C "${flakePath}"'';
                in
                ''
                  ${git} diff --quiet           -- "${flakePath}/flake.lock && \
                  ${git} commit -m "${message}" -- "${flakePath}/flake.lock"
                '';
              apply = pkgs.writeShellScript "${updateFlakeInputsService}.commit.command";
            };

            message = lib.mkOption {
              type = with types; str;
              description = "Message used when committing the updated lockfile.";
              default = "[AUTO] Update flake inputs";
            };
          };

          notification = {
            enable = lib.mkEnableOption "desktop notification when inputs have been updated" // {
              default = config.desktop.enable;
            };

            message = lib.mkOption {
              type = with types; str;
              default = "Your flake inputs have been updated.";
            };

            icon = lib.mkOption {
              type = with types; path;
              default = "${iconsDir}/nixos.png";
            };

            timeout = lib.mkOption {
              type = with types; ints.unsigned;
              description = "Duration of the notification (in miliseconds)";
              default = 0;
              apply = builtins.toString;
            };

            actions = lib.mkOption {
              type = with types; attrsOf str;
              description = "Actions to provide on the notification pop-up.";
              default =
                let
                  hasNh = config.core.flake.nh.enable;

                  terminal = "\${TERMINAL:-${lib.getExe pkgs.kdePackages.konsole}}";
                  bash = lib.getExe pkgs.bash;
                  shell = lib.getExe (config.user.shell or config.users.defaultShell or pkgs.bash);
                  switch = if hasNh then "${nh} os switch" else "${nixos-rebuild} switch";
                  dry-build = if hasNh then "${nh} os build --dry" else "${nixos-rebuild} dry-build";
                in
                {
                  "Apply updates" = ''
                    ${terminal} -e ${bash} -c "
                      if ${switch}; then
                        exit 0
                      fi

                      # Keep terminal open on error
                      exec ${shell}
                    "
                  '';
                  "Dry build" = ''
                    ${terminal} -e ${bash} -c '
                      if ${dry-build}; then
                        read -p "Dry run successful. Would you like to apply the update? [Y/n]" -n 1 -r CHOICE
                        if [[ -z "$CHOICE" || "$CHOICE" ~= ^[Yy]\$ ]] && ${switch}; then
                          exit 0
                        fi
                      fi

                      # Keep terminal open on error
                      exec ${shell}
                    '
                  '';
                };
              apply =
                let
                  kebabify = str: lib.toLower (builtins.replaceStrings [ " " ] [ "-" ] str);
                in
                builtins.mapAttrs (
                  action: script:
                  pkgs.writeShellScript "${updateFlakeInputsService}.action.${kebabify action}.script" script
                );
            };

            command = lib.mkOption {
              readOnly = true;
              default =
                with cfg.autoUpdate.notification;
                let
                  actionList = lib.attrsToList actions;
                  actionNames = builtins.attrNames actions;
                  hasActions = builtins.length actionList > 0;
                in
                pkgs.writeShellScript "${updateFlakeInputsService}.actions.command" ''
                  ${lib.getExe pkgs.libnotify} \
                    --expire-time ${timeout} \
                    --icon ${icon} \
                    --app-name NixOS \
                    ${
                      builtins.concatStringsSep "\\\n" (
                        builtins.map (action: ''--action="${action}=${action}"'') actionNames
                      )
                    } \
                    "Flake inputs updated" ${lib.optionalString hasActions ''
                      | {
                        read -r action
                        case "$action" in
                          ${builtins.concatStringsSep "\n" (
                            builtins.map ({ name, value }: ''
                              "${name}")
                                nohup ${value} &
                                ;;
                            '') actionList
                          )}
                        esac
                      } &
                    ''}
                '';
            };
          };

          script = lib.mkOption {
            type = with types; str;
            description = "Final script ran by the auto-update service";
            readOnly = true;
            default = with cfg.autoUpdate; ''
              if ! ${preRunHook}; then
                echo "info: Update aborted by pre-run hook." > &2
                exit
              fi

              if ! ${command}; then
                echo "error: Something went wrong during update" > &2
                exit 1
              fi

              ${lib.optionalString commit.enable ''
                if ! ${commit.command}; then
                  echo "error: Something went wrong when committing the update" > &2
                fi
              ''}

              ${lib.optionalString (false && notification.enable) "nohup ${notification.command} &"}
            '';
          };
        };
      };

      config = {
        programs.nh = {
          inherit (cfg.nh) enable;

          clean.enable = true;
          clean.extraArgs = "--keep-since 7d --keep 3";
          flake = builtins.toString flakePath;
        };

        environment.sessionVariables = lib.mkMerge [
          (lib.mkIf cfg.nh.enable {
            # Takes precedence over NH_FLAKE (programs.nh.flake) for `nh os` commands
            NH_OS_FLAKE = "${flakePath}#nixosConfigurations.${hostName}";
          })
          {
            FLAKE_HOME = "${flakePath}";
            FLAKE_PACKAGES = "${flakePath}#packages.${system}";
          }
        ];

        systemd.user.services.${updateFlakeInputsService} = {
          inherit (cfg.autoUpdate) enable script;

          description = "Updates `${flakePath}`'s inputs.";
          serviceConfig.Type = "oneshot";
        };

        systemd.user.timers.${updateFlakeInputsService} = {
          inherit (cfg.autoUpdate) enable;

          description = ''
            Automatically updates `${flakePath}`'s inputs weekly.
          '';
          after = [ "multi-user.target" ];
          timerConfig = {
            OnCalendar = "Mon 00:00:00"; # On every Monday, as early as possible
            Persistent = true; # ... or on the very next boot if off on a Monday.
          };
        };
      };
    };
}
