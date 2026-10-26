{ dirs, ... }:
{
  flake.nixosModules.hosts =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib) listToAttrs;
      inherit (config.age) secrets;

      user = config.users.user;
      flake = config.flake;

      gpgFingerprint = "E5C24624BEC13FD00B989E32A2838A891FE0378A";
    in
    {
      age = {
        rulesFile = "${flake.root}/secrets/rules.nix";
        identityPaths = [ "${user.home}/.ssh/id_ed25519" ];
      };

      # age.secrets =
      #   let
      #     gpgSecrets =
      #       map
      #         (file: rec {
      #           name = "gpg/${file}";
      #           value = {
      #             file = "${dirs.secrets}/${name}.age";
      #             owner = user.name;
      #           };
      #         })
      #         [
      #           "${gpgFingerprint}.pub"
      #           "${gpgFingerprint}.prv"
      #           "ownertrust"
      #         ];
      #   in
      #   listToAttrs gpgSecrets;
      #
      # programs.gnupg = {
      #   agent.enable = true;
      #   ownertrust = secrets."gpg/ownertrust".path;
      #   keys.${gpgFingerprint} = {
      #     private = secrets."gpg/${gpgFingerprint}.prv".path;
      #     public = secrets."gpg/${gpgFingerprint}.pub".path;
      #   };
      # };
    };
}
