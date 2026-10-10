{
  flake.nixosModules.inputRemapper =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.services.input-remapper;
    in
    {
      options.services.input-remapper =
        let
          inherit (lib) types;
        in
        {
          configDir = lib.mkOption {
            type = with types; nullOr (strMatching "/([^/]+/)*[^/]+/?");
            description = ''
              Path to where your Input Remapper configs are saved.
            '';
            default = null;
            apply = p: if builtins.isNull p then p else lib.removeSuffix "/" p;
          };
        };

      config =
        let
          guiWrapper = pkgs.writeShellApplication {
            name = "input-remapper-gtk";
            bashOptions = [ "pipefail" ];
            excludeShellChecks = [ ];
            runtimeInputs = with pkgs; [
              coreutils
              diffutils
              git
              gnused
              kdePackages.kdialog
              rsync
            ];
            text = ''
              trap 'on_error "$?" "$LINENO" "$BASH_COMMAND"' ERR
              trap 'on_exit' EXIT

              XDG_CONFIG_HOME=$(mktemp -u -p /tmp -d input-remapper.XXXX)
              export XDG_CONFIG_HOME

              EXIT_STATUS=0
              BACKPORTED=0
              ROLLBACK_ON_EXIT=0

              CONFIG_SRC=${lib.escapeShellArg cfg.configDir}
              CONFIG_TMP="$XDG_CONFIG_HOME/input-remapper-2"

              ERR_ADVICE_TERM="Try running \`input-remapper-gtk\` from a terminal to get some details, maybe."

              ERR_INVAL_CONFIGDIR="Invalid directory: \"$CONFIG_SRC\""

              ERR_REMAPPER_EXEC+="Something went wrong during execution of Input Remapper.\n"
              ERR_REMAPPER_EXEC+="$ERR_ADVICE_TERM"

              ERR_BACKPORT+="Something went wrong when backporting your configs to $CONFIG_SRC.\n"
              ERR_BACKPORT+="$ERR_ADVICE_TERM"

              ERR_COMMIT+="Something went wrong when committing changes.\n"
              ERR_COMMIT+="$ERR_ADVICE_TERM"

              run() {
                local prefix
                prefix=$(basename "$1")

                "$@" 2>&1 | sed "s/^/[$prefix]: /"
              }

              popup() {
                run kdialog --desktopfile 'input-remapper-gtk' --icon 'input-remapper' --title 'Input Remapper wrapper' "$@"
              }

              on_error() {
                EXIT_STATUS="''${1:-1}"
                local lineno="''${2:-unknown}"
                local command="''${3:-unknown}"
                local message="Error on line $lineno (exit code $EXIT_STATUS): '$command'"

                echo "$message" >&2
                popup --detailederror "''${ON_ERROR_MESSAGE:-"That's not good..."}" "$message"
              }

              on_exit() {
                if  (( "$ROLLBACK_ON_EXIT" )) && [ -d "$CONFIG_BKP" ]; then
                  echo "Revert config backport \"$CONFIG_BKP\" -> \"$CONFIG_SRC\""
                  run rm -rf "$CONFIG_SRC"
                  run cp -a "$CONFIG_BKP" "$CONFIG_SRC"
                fi
                if [ -d "$XDG_CONFIG_HOME" ]; then
                  echo "Delete temporary directory \"$CONFIG_TMP\"."
                  # This command looks scary, even knowing I exported XDG_CONFIG_HOME to a temp dir.
                  # I wish Input Remapper provided a unique variable for its configs.
                  run rm -rf "$XDG_CONFIG_HOME"
                fi
                echo "Delete backup \"$CONFIG_BKP\"."
                run rm -rf "$CONFIG_BKP"
                exit "$EXIT_STATUS"
              }

              # TODO: Add Nix option to always accept backport
              backport_configs() {
                local target="$CONFIG_SRC"
                local source="$CONFIG_TMP"
                local backup

                if diff -qr "$CONFIG_TMP" "$CONFIG_SRC"; then
                  echo "No change detected. Skipping backport."
                  return
                fi

                if ! popup --yesno "Changes detected. Backport config?"; then
                  echo "Backport aborted by user."
                  return
                fi

                backup="$target"."$(date +%s)"
                CONFIG_BKP="$backup"
                ROLLBACK_ON_EXIT=1
                {
                  echo "Create backup at \"$CONFIG_BKP\"."
                  run cp -a "$target" "$backup" 2>&1
                  echo "Backporting configs from \"$CONFIG_TMP\" to \"$CONFIG_SRC\"..."
                  run rsync -a --delete "$source/" "$target/" 2>&1
                }
                ROLLBACK_ON_EXIT=0
                BACKPORTED=1
              }

              # TODO: Add Nix option to always accept commit
              # TODO: Add Nix option for default commit message
              commit_changes() {
                local message

                if (( ! "$BACKPORTED" )); then return; fi

                if ! run git -C "$CONFIG_SRC" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
                  echo "\"$CONFIG_SRC\" is not inside a git repository. Skipping commit."
                  return
                fi

                message=$(
                  popup --inputbox "Commit changes?\n\nMessage:" "[AUTO] Update Input Remapper configs" \
                        --geometry 320x0
                )
                # shellcheck disable=SC2181
                if (( "$?" )); then
                  echo "Commit aborted by user."
                  return
                fi

                run git -C "$CONFIG_SRC" commit . -m "$message"
              }

              try() {
                ON_ERROR_MESSAGE="$1"
                shift
                "$@"
                unset ON_ERROR_MESSAGE
              }

              if [ ! -d "$CONFIG_SRC" ]; then
                popup --error "$ERR_INVAL_CONFIGDIR" \
                      --ok-label "I should check my flake."
                exit 1
              fi

              echo "Create temporary directory at \"$XDG_CONFIG_HOME\""
              run mkdir -p "$XDG_CONFIG_HOME"

              echo "Copy \"$CONFIG_SRC\" to \"$CONFIG_TMP\""
              run cp -r "$CONFIG_SRC" "$CONFIG_TMP"

              try "$ERR_REMAPPER_EXEC" run ${lib.escapeShellArg (lib.getExe' pkgs.input-remapper "input-remapper-gtk")}
              try "$ERR_BACKPORT" backport_configs
              try "$ERR_COMMIT" commit_changes
            '';
          };

          cliWrapper = pkgs.writeShellApplication {
            name = "input-remapper-control";
            text = ''
              ${lib.escapeShellArg (lib.getExe' pkgs.input-remapper "input-remapper-control")} --config-dir ${lib.escapeShellArg cfg.configDir} "$@"
            '';
          };
        in
        lib.mkIf (cfg.enable && !builtins.isNull cfg.configDir) {
          services.input-remapper.package = pkgs.symlinkJoin {
            name = "input-remapper-wrapped";

            paths = [
              guiWrapper
              cliWrapper
              pkgs.input-remapper
            ];

            postBuild = ''
              rm -f $out/bin/input-remapper-{gtk,control}

              ln -sf ${guiWrapper}/bin/input-remapper-gtk     $out/bin/input-remapper-gtk
              ln -sf ${cliWrapper}/bin/input-remapper-control $out/bin/input-remapper-control
            '';
          };
        };
    };
}
