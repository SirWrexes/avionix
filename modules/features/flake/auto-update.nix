{ dirs, ... }:
{
  flake.nixosModules.flake =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (lib) types;
      inherit (config) flake;

      cfg = config.flake.autoUpdate;

      service = "update-flake-inputs";

      nix = lib.getExe config.nix.package;
      nixos-rebuild = "${lib.getExe pkgs.nixos-rebuild-ng} --flake ${flake.root}#${flake.host}";
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
            ${nix} flake update --flake "${flake.root}"
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

                git = ''${lib.getExe config.programs.git.package} -C "${flake.root}"'';
              in
              ''
                ${git} diff --quiet           -- "${flake.root}/flake.lock" && \
                ${git} commit -m "${message}" -- "${flake.root}/flake.lock"
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
            description = ''
              Message to display on the notification.
            '';
          };

          icon = lib.mkOption {
            type = with types; path;
            default = "${dirs.icons}/nixos.png";
            description = ''
              Icon for the notification.
            '';
          };

          timeout = lib.mkOption {
            type = with types; ints.unsigned;
            default = 0;
            description = "Duration of the notification (in miliseconds)";
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
        };
      };

      config = lib.mkIf cfg.enable {
        systemd.user.services.${service} = {
          script =
            let
              inherit (cfg)
                commit
                notification
                preRunHook
                ;

              actionList = lib.attrsToList notification.actions;
              actionNames = builtins.attrNames notification.actions;
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

              command = pkgs.writeShellScript "${service}.actions.command" ''
                ${lib.getExe pkgs.libnotify} \
                  --expire-time ${notification.timeout} \
                  --icon ${notification.icon} \
                  --app-name NixOS \
                  "Flake inputs updated" ${lib.optionalString hasActions ''
                    \
                    ${actionFlagsStr} | ${actionFlagsSwitch}
                  ''}
              '';
            in
            ''
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

              ${lib.optionalString notification.enable "nohup ${command} >/dev/null 2>&1 &"}
            '';
          description = "Updates `${flake.root}`'s inputs.";
          serviceConfig.Type = "oneshot";
        };

        systemd.user.timers.${service} = {
          description = "Automatically updates `${flake.root}`'s inputs.";
          after = [ "multi-user.target" ];
          timerConfig = {
            OnCalendar = "Mon 00:00:00"; # On every Monday, as early as possible
            Persistent = true; # ... or on the very next boot if off on a Monday.
          };
        };
      };
    };
}
