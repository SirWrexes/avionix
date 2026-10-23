{
  name,
  pkgs,
  lib,
  config,
  safePath,
  ...
}:
let
  inherit (lib)
    escapeShellArg
    literalExpression
    match
    mkIf
    mkOption
    optionalString
    types
    ;

  isFingerprint =
    str:
    let
      chars40 = match "^[A-F0-9]{40}$" str;
      chars64 = match "^[A-F0-9]{64}$" str;
    in
    isNull chars40 -> !isNull chars64;
in
{
  options = {
    public = mkOption {
      type = with types; nullOr safePath;
      default = null;
      description = ''
        Export with `gpg --armor --export your_email@example.com > public-key.asc`
      '';
      example = literalExpression ''config.age.secrets."273ED719F8D1F17F28F92AE14CEBB3E827CABB7E.pub".path'';
    };

    private = mkOption {
      type = with types; nullOr safePath;
      default = null;
      description = ''
        Export with `gpg --armor --export-secret-keys your_email@example.com > private-key.asc`
      '';
      example = literalExpression ''config.age.secrets."273ED719F8D1F17F28F92AE14CEBB3E827CABB7E.prv".path'';
    };

    script = mkOption {
      type = with types; nullOr package;
      internal = true;
      default = null;
    };
  };

  config.script =
    assert (
      isFingerprint name
      || throw ''
        Not a key fingerprint: ${name}
        Must be a 40 or 64 characters long uppercase hexadecimal string.
      ''
    );
    let
      hasPrivate = !isNull config.private;
      hasPublic = !isNull config.public;

      fingerprint = escapeShellArg name;
      private = escapeShellArg config.private;
      public = escapeShellArg config.public;
    in
    mkIf (hasPrivate || hasPublic) (
      pkgs.writeShellScriptBin "import-gpg-keys-${name}" ''
        EXIT_STATUS=0
        trap "EXIT_STATUS=1" ERR

        echo "Import GPG key ${fingerprint}"
        ${optionalString hasPrivate ''
          if [ ! -f ${private} ]; then
            echo -e "\033[41;30mERROR\033[0m No such file: ${private}" >&2
            EXIT_STATUS=1
          elif ! gpg --list-secret-keys ${fingerprint} >/dev/null 2>&1; then
            gpg --import ${private} \
            && echo "\033[42;307mOK\033[0m Private key"
          fi
        ''}
        ${optionalString hasPublic ''
          if [ -f ${public} ]; then
            echo -e "\033[41;30mERROR\033[0m No such file: ${public}" >&2
            EXIT_STATUS=1
          elif ! gpg --list-keys ${fingerprint} >/dev/null 2>&1; then
            gpg --import ${public} \
            && echo -e "\033[42;30mOK\033[0m Public key"
          fi
        ''}
        exit "$EXIT_STATUS"
      ''
    );
}
