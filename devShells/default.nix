{
  perSystem =
    { pkgs, lib, ... }:
    let
      gendocs = pkgs.writeShellScriptBin "gendocs.modules" ''
        set -euo pipefail
        cd "$(git rev-parse --show-toplevel)"

        declare -A OPTS
        for param in "$@"; do
          case "$param" in
            "--dry-run") OPTS[dry]="--dry-run" ;;
            "--quiet")   OPTS[quiet]="--quiet" ;;
            "--force")   OPTS[force]="--force" ;;
          esac
        done

        FLAKE_REV="$(git rev-parse HEAD)"
        HAS_STASH=0

        BUILD_DIR="build"
        FEATURES_DIR="modules/features"

        DOCS_MARKDOWN="$BUILD_DIR/docs/options.md"
        DOCS_GENERATED="$FEATURES_DIR/README.md"

        export FLAKE_REV

        if [ -z "''${OPTS[force]:-}" ] && git diff --quiet --staged origin -- "$FEATURES_DIR" ":(exclude)$DOCS_GENERATED"; then
          echo "🤷 Modules are unchanged. Docs won't be generated."
          exit 0
        fi

        unset 'OPTS[force]'
        echo "💡 Docs will be generated for this push."

        # Some files might be partially committed.
        # We want to run the docs generation on only the parts that are going to be pushed, so we stash the unchanged parts.
        if [ -n "$(git status --porcelain -- "$FEATURES_DIR" ":(exclude)$DOCS_GENERATED")" ]; then
          echo "📥 Stash changes not staged"
          git stash push "''${OPTS[quiet]:-}" --keep-index -u -m "pre-push-autostash"
          HAS_STASH=1
        fi

        trap '
          if [ "$HAS_STASH" -eq 1 ]; then
            echo "📤 Pop it like it'"'"'s hot"
            git stash pop "''${OPTS[quiet]:-}";
          fi
        ' EXIT

        echo "🔨 Build latest flake module docs"
        nix --extra-experimental-features "flakes nix-command" \
          build .#docs.optionsCommonMark \
            --offline \
            --impure \
            "''${OPTS[@]}" \
            -o "$DOCS_MARKDOWN"

        echo "📝 Overwrite old docs"
        if [ -z "''${OPTS[dry]:-}" ]; then
          cat "$DOCS_MARKDOWN" >"$DOCS_GENERATED"
        fi

        echo "📦 Commit doc changes"
        git add    "''${OPTS[@]}"                                       -- "$DOCS_GENERATED" &&
        git commit "''${OPTS[@]}" -m "doc(modules): Auto-generate docs" -- "$DOCS_GENERATED"
      '';

      # Convenience wrapper around `git` to generate docs automatically.
      # This is because I'm lazy and forgetful and WILL screw up a workflow where I need to generate and push docs myself.
      # Therefore, this wrapper overrides the default behaviour of `git push` with a custom hook.
      # The REASON I don't use standard git hooks is that there's no real way to make do these all at once:
      # - be entirely automatic
      # - be able to reference latest local commit hash
      # - not be {pre,post}-commit to avoid unnecessary generations due to my habit of keeping a granular history
      # - not require to `git push` twice in a row (pre-push updates refs *before* running, so a commit inside it is pushed on next invocation)
      git-wrapped = pkgs.writeShellScriptBin "git" ''
        set -euo pipefail

        SELF_PATH="$(realpath "$(dirname "''${BASH_SOURCE[0]}")")"
        PATH="$(echo "$PATH" | tr ':' '\n' | grep -vF "$SELF_PATH" | paste -sd:)"
        export PATH

        declare -A SKIPME

        SKIPME[-h]="Showing help"
        SKIPME[-d]="Deleting refs"
        SKIPME[--prune]="Pruning refs"
        SKIPME[--no-docgen]="Explicitly disabled docgen"

        SKIPME[--help]="''${SKIPME[-h]}"
        SKIPME[--delete]="''${SKIPME[-d]}"

        pre-push() {
          local -a opts

          for param in "$@"; do
            if [ -n "''${SKIPME["$param"]:-}" ]; then
              echo "Skip docgen: ''${SKIPME["$param"]}"
              return
            fi

            case "$param" in
              "-q"|"--quiet")   opts+=("--quiet")   ;;
              "-n"|"--dry-run") opts+=("--dry-run") ;;
              "-f"|"--force")   opts+=("--force")   ;;
            esac
          done

          ${lib.escapeShellArg (lib.getExe gendocs)} "''${opts[@]}"
        }

        if [ "''${1-}" == "push" ]; then
          echo "==>> Considering pre-push docs generation..."
          pre-push "''${@:2}"
        fi

        exec git "$@"
      '';
    in
    {
      devShells.default = pkgs.mkShellNoCC {
        packages = [
          gendocs
          git-wrapped
        ];
      };
    };
}
