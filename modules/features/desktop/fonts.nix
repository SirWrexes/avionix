{ self, inputs, ... }:
{
  flake.nixosModules.desktop = { pkgs, config, lib, ... }:
  {
    fonts.fontconfig.useEmbeddedBitmaps = true;

    fonts.packages =
      with pkgs;
      let
        nerd-fonts' = builtins.filter lib.attrsets.isDerivation (builtins.attrValues nerd-fonts);
      in
      nerd-fonts' ++ [
        corefonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        vista-fonts
      ];
  };
}
