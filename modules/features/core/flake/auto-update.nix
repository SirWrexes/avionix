{ dirs, ... }:
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
      inherit (config) host;
      inherit (config.core) flakePath;

      cfg = config.flake.autoUpdate;

      service = "update-flake-inputs";

      nix = lib.getExe config.nix.package;
      nixos-rebuild = "${lib.getExe pkgs.nixos-rebuild-ng} --flake ${flakePath}#${host}";
    in
    {
      # Took a couple hours to write this whole module subsection only to find out afterwards about `system.autoUpgrade`.
      # Oh well, I like my module better anyway--not copium, I swear! 😨
      options.flake.autoUpdate = {
        enable = lib.mkEnableOption "auto updating of flake inputs" // {
          default = true;
        };

        preRunHook = lib.mkOption {
          type = with types; str;
          description = "Runs before calling the update command. If it returns a non-zero value, the update is prevented.";
          default = "true";
          apply = pkgs.writeShellScript "${service}.pre-run-hook";
        };

        command = lib.mkOption {
          type = with types; str;
          description = "The script that will run to update inputs";
          default = ''
            ${nix} flake update --flake "${flakePath}"
          '';
          apply = pkgs.writeShellScript "${service}.command";
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
                inherit (cfg.commit) message;

                git = ''${lib.getExe config.programs.git.package} -C "${flakePath}"'';
              in
              ''
                ${git} diff --quiet           -- "${flakePath}/flake.lock" && \
                ${git} commit -m "${message}" -- "${flakePath}/flake.lock"
              '';
            apply = pkgs.writeShellScript "${service}.commit.command";
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
            default = "${dirs.icons}/nixos.png";
          };

          timeout = lib.mkOption {
            type = with types; ints.unsigned;
            description = "Duration of the notification (in miliseconds)";
            default = 0;
            apply = builtins.toString;
          };

          actions = lib.mkOption {
            type = with types; attrsOf str;
            description = ''
              Actions to provide on the notification pop-up.
              These must be shell snippets and will be converted into scripts.
            '';
            default =
              let
                terminal = "\${TERMINAL:-${lib.getExe pkgs.kdePackages.konsole}}";
                bash = lib.getExe pkgs.bash;
                shell = lib.getExe (config.user.shell or config.users.defaultShell or pkgs.bash);
                switch = "${nixos-rebuild} switch";
                dry-build = "${nixos-rebuild} dry-build";
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
                action: script: pkgs.writeShellScript "${service}.action.${kebabify action}.script" script
              );
          };

          command = lib.mkOption {
            readOnly = true;
            default =
              with cfg.notification;
              let
                actionList = lib.attrsToList actions;
                actionNames = builtins.attrNames actions;
                hasActions = builtins.length actionList > 0;

                actionFlags = builtins.map (action: ''--action="${action}=${action}"'') actionNames;
                actionFlagsStr = builtins.concatStringsSep "\\\n" actionFlags;

                actionFlagCases = builtins.map ({ name, value }: ''
                  "${name}") "${value}" ;;
                '') actionList;
                actionFlagsSwitch = ''
                  {
                    read -r action
                    case "$action" in
                      ${builtins.concatStringsSep "\n" actionFlagCases}
                    esac
                  }
                '';
              in
              pkgs.writeShellScript "${service}.actions.command" ''
                ${lib.getExe pkgs.libnotify} \
                  --expire-time ${timeout} \
                  --icon ${icon} \
                  --app-name NixOS \
                  "Flake inputs updated" ${lib.optionalString hasActions ''
                    \
                    ${actionFlagsStr} | ${actionFlagsSwitch}
                  ''}
              '';
          };
        };

        script = lib.mkOption {
          type = with types; str;
          description = "Final script ran by the auto-update service";
          readOnly = true;
          default = with cfg; ''
            if ! ${preRunHook}; then
              echo "info: Update aborted by pre-run hook." 2>&1
              exit
            fi

            if ! ${command}; then
              echo "error: Something went wrong during update" 2>&1
              exit 1
            fi

            ${lib.optionalString commit.enable ''
              if ! ${commit.command}; then
                echo "error: Something went wrong when committing the update" 2>&1
              fi
            ''}

            ${lib.optionalString notification.enable "nohup ${notification.command} >/dev/null 2>&1 &"}
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        systemd.user.services.${service} = {
          inherit (cfg) script;
          description = "Updates `${flakePath}`'s inputs.";
          serviceConfig.Type = "oneshot";

        };

        systemd.user.timers.${service} = {
          description = "Automatically updates `${flakePath}`'s inputs.";
          after = [ "multi-user.target" ];
          timerConfig = {
            OnCalendar = "Mon 00:00:00"; # On every Monday, as early as possible
            Persistent = true; # ... or on the very next boot if off on a Monday.
          };
        };
      };
    };
}
