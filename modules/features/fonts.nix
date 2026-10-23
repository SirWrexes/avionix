{
  flake.nixosModules.fonts =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      inherit (lib)
        filterAttrs
        isDerivation
        length
        literalExpression
        mkIf
        mkOption
        types
        ;

      cfg = config.fonts;

      nerd-fonts = filterAttrs (name: value: isDerivation value) pkgs.nerd-fonts;
    in
    {
      options.fonts.nerd-fonts = {
        packages = mkOption {
          type = with types; functionTo (listOf package);
          default = _: [ ];
          description = ''
            NerdFonts packages to install.
          '';
          example = literalExpression ''
            nf: with nf; [
              fira-mono
              fira-code
            ]
          '';
          apply = fn: fn nerd-fonts;
        };
      };

      config = mkIf (length cfg.nerd-fonts.packages > 0) {
        fonts.packages = cfg.nerd-fonts.packages;
      };
    };
}
