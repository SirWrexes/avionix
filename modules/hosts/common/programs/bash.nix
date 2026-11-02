{
  flake.nixosModules.hosts =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib)
        concatStringsSep
        mkDefault
        ;

      shopts = concatStringsSep " " [
        "autocd"
        "cdable_vars"
        "cdspell"
        "dirspell"
        "globstar"
        "nocaseglob"
        "nocasematch"
        "nullglob"
      ];
    in
    {
      programs.bash = {
        undistractMe.enable = mkDefault true;
        interactiveShellInit = ''
          shopt -s ${shopts}
        '';
      };
    };
}
