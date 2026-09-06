{ self, inputs, ... }:
{
  flake.nixosModules.fonts = { pkgs, config, lib, ... }:
  {
    fonts.fontconfig.useEmbeddedBitmaps = true;

    fonts.packages =
      with pkgs;
      let
        nerd-fonts' = builtins.filter lib.attrsets.isDerivation (builtins.attrValues nerd-fonts);
      in
      nerd-fonts' ++ [
        noto-fonts-color-emoji
        noto-fonts-cjk-sans
      ];
  };
}
