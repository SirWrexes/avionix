{
  flake.nixosModules.secrets =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.programs.gnupg;
    in
    {
      options =
        let
          inherit (lib)
            mkOption
            types
            ;

          isFingerprint =
            str:
            let
              chars40 = builtins.match "^[A-F0-9]{40}$" str;
              chars64 = builtins.match "^[A-F0-9]{64}$" str;
            in
            builtins.isNull chars40 -> !builtins.isNull chars64;

          attrNamesAreFingerprints = lib.foldlAttrs (
            acc: name: _value:
            isFingerprint name && acc
          ) true;

          polyPath = with types; either path strPath;

          keysSubmodule = types.submodule {
            options = {
              public = mkOption {
                type = with types; nullOr polyPath;
                default = null;
                description = ''
                  Export with `gpg --armor --export your_email@example.com > public-key.asc`
                '';
              };
              private = mkOption {
                type = with types; nullOr polyPath;
                default = null;
                description = ''
                  DO NOT COMMIT YOUR PRIVATE KEY, GIT IGNORE IT.

                  Export with `gpg --armor --export-secret-keys your_email@example.com > private-key.asc`

                  DO NOT COMMIT YOUR PRIVATE KEY, GIT IGNORE IT.
                '';
              };
            };
          };
        in
        {
          programs.gnupg = {
            ownerTrust = mkOption {
              type = with lib.types; nullOr polyPath;
              default = null;
              description = ''
                Export with `gpg --export-ownertrust > some/path/otrust.txt`
              '';
              example = "/home/someuser/nixflake/secrets/otrust.txt";
            };

            keys = mkOption {
              type = with lib.types; (addCheck (attrsOf keysSubmodule) attrNamesAreFingerprints);
              default = { };
              example = lib.literalExpression ''
                {
                  "7FFA029B212AD4CCB7F91767C8CC44B119FF76ED" = {
                    private = config.age.secrets.gpg-private.path;
                    public = "/home/someuser/nixflake/secrets/gpg-public.asc";
                  };
                }
              '';
            };
            description = ''
              Keys to import, indexed by their fingerprint.
            '';
          };
        };

      config = lib.mkIf cfg.agent.enable {
        system.userActivationScripts.import-gpg-keys.text =
          let
            inherit (lib) escapeShellArg optionalString getExe;

            hasOwnerTrust = !builtins.isNull cfg.ownerTrust;
            hasPrivateKey = { private, ... }: !builtins.isNull private;
            hasPublicKey = { public, ... }: !builtins.isNull public;

            script = pkgs.writeShellApplication {
              name = "import-gpg-keys";
              runtimeInputs = with pkgs; [
                cfg.package
                gawk
              ];
              text =
                lib.concatMapAttrsStringSep "\n" (
                  fingerprint:
                  { private, public }@pair:
                  ''
                    ${optionalString (hasOwnerTrust) "fingerprints+=(${escapeShellArg fingerprint})"}
                    ${optionalString (hasPrivateKey pair) ''
                      if ! gpg --list-secret-keys ${escapeShellArg fingerprint} >/dev/null 2>&1; then
                        echo "Import private key ${private}"
                        gpg --import ${escapeShellArg private}
                      fi
                    ''}
                    ${optionalString (hasPublicKey pair) ''
                      if ! gpg --list-keys ${escapeShellArg fingerprint} >/dev/null 2>&1; then
                        echo "Import public key ${public}"
                        gpg --import ${escapeShellArg public}
                      fi
                    ''}
                  ''
                ) cfg.keys
                + (optionalString (hasOwnerTrust) ''
                  awk_cond=""
                  for fp in "''${fingerprints[@]}"; do
                    if [ -z "$awk_cond" ]; then
                      awk_cond="index(\$0, \"$fp\") > 0"
                    else
                      awk_cond="$awk_cond && index(\$0. \"$fp\") > 0"
                    fi
                  done
                  if gpg --export-ownertrust | awk "$awk_cond { found_all = 1 } END { exit ! found_all }"; then
                    gpg --import-ownertrust ${escapeShellArg cfg.ownerTrust}
                  fi
                '');
            };
          in
          ''
            ${getExe script}
          '';
      };
    };
}
