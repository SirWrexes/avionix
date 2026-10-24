{ inputs, ... }:
{
  flake.nixosModules.age =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.age;
    in
    {
      imports = [ inputs.agenix.nixosModules.default ];

      options.age =
        let
          inherit (lib) mkOption types;
        in
        {
          rulesFile = mkOption {
            type =
              with types;
              pathWith {
                inStore = false;
                absolute = true;
              };
            description = ''
              Sets `AGENIX_RULES` environment variable. Agenix usage states the following:
              > AGENIX_RULES environment variable with path to Nix file specifying recipient public keys.
              > Searches the current directory for agenix-rules.nix, then secrets.nix.
              > Searches parent directories for agenix-rules.nix only.
              > Resolves relative secret paths from the selected rules file's directory.
            '';
          };
        };

      config = lib.mkIf cfg.enable {
        environment.sessionVariables = {
          AGENIX_RULES = builtins.toString cfg.rulesFile;
        };
      };
    };
}
