{ dirs, ... }: {
  flake.nixosModules.artemis =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (config.age) secrets;

      user = config.users.users.${config.core.user.name};
      gpgFingerprint = "E5C24624BEC13FD00B989E32A2838A891FE0378A";
    in
    {
      age = {
        rulesFile = "${config.core.flakePath}/secrets/rules.nix";
        identityPaths = [ "${user.home}/.ssh/id_ed25519" ];
      };

      age.secrets =
        let
          gpgSecrets =
            map
              (file: rec {
                name = "gpg/${file}";
                value = {
                  file = "${dirs.secrets}/${name}.age";
                  owner = user.name;
                };
              })
              [
                "${gpgFingerprint}.pub"
                "${gpgFingerprint}.prv"
                "ownertrust"
              ];
        in
        builtins.listToAttrs gpgSecrets;

      programs.gnupg = {
        agent.enable = true;
        ownerTrust = secrets."gpg/ownertrust".path;
        keys.${gpgFingerprint} = {
          private = secrets."gpg/${gpgFingerprint}.prv".path;
          public = secrets."gpg/${gpgFingerprint}.pub".path;
        };
      };
    };
}
