{
  flake.nixosModules.secrets =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib)
        escapeShellArg
        foldlAttrs
        getExe
        length
        literalExpression
        mkIf
        mkOption
        optional
        toJSON
        types
        ;

      safePath =
        with types;
        pathWith {
          inStore = false;
          absolute = true;
        };

      keyPairModule = types.submoduleWith {
        modules = [ (import ./key-pair.mod.nix) ];
        specialArgs = { inherit pkgs safePath; };
      };

      cfg = config.programs.gnupg;
    in
    {
      options = {
        programs.gnupg = {
          ownertrust = mkOption {
            type = with types; nullOr safePath;
            default = null;
            description = ''
              Export with `gpg --export-ownertrust > some/path/ownertrust.txt`
            '';
            example = literalExpression (toJSON "/home/someuser/nixflake/secrets/ownertrust.txt");
            apply =
              path:
              optional (!isNull path) (
                let
                  ownertrust = escapeShellArg path;
                in
                pkgs.writeShellScriptBin "import-gpg-owner-trust" ''
                  if [ ! -f ${ownertrust} ]; then
                    echo -e "\033[41;30mERROR\033[0m No such file: ${ownertrust}" >&2
                    exit 1
                  fi

                  awk_cond=""
                  for fp in "''${fingerprints[@]}"; do
                    if [ -z "$awk_cond" ]; then
                      awk_cond="index(\$0, \"$fp\") > 0"
                    else
                      awk_cond="$awk_cond && index(\$0. \"$fp\") > 0"
                    fi
                  done
                  if gpg --export-ownertrust | awk "$awk_cond { found_all = 1 } END { exit ! found_all }"; then
                    echo -e "\033[42;30mOK\033[0m Import ownertrust"
                    gpg --import-ownertrust ${ownertrust} \
                    && echo -e "\033[42;30mOK\033[0m ownertrust"
                  fi
                ''
              );
          };

          keys = mkOption {
            type =
              with types;
              attrsWith {
                placeholder = "fingerprint";
                elemType = keyPairModule;
              };
            default = { };
            description = ''
              Keys to import, indexed by their fingerprint.
            '';
            example = literalExpression ''
              {
                "273ED719F8D1F17F28F92AE14CEBB3E827CABB7E" = {
                  # Could be a path provided by a secret management tool
                  private = config.age.secrets.gpg-private.path;
                  # Or an absolute path to somehwere outside your flake
                  public = "/path/to/secrets/gpg-public.asc";
                };
              }
            '';
            apply = foldlAttrs (acc: fingerprint: { script, ... }: optional (!isNull script) script ++ acc) [ ];
          };
        };
      };

      config =
        let
          scripts = cfg.ownertrust ++ cfg.keys;
          enable = cfg.agent.enable && (length scripts > 0);
        in
        mkIf enable {
          systemd.user.services.import-gpg-secrets = {
            reloadTriggers = scripts;
            conflicts = [ "shutdown.target" ];
            wantedBy = [ "sysinit-reactivation.target" ];
            partOf = [ "sysinit-reactivation.target" ];
            serviceConfig = {
              ExecStart = map (script: "-${getExe script}") scripts;
              Type = "oneshot";
            };
          };
        };
    };
}
