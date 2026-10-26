{
  flake.nixosModules.hosts =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      fonts = {
        packages = with pkgs; [
          corefonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
          vista-fonts
        ];

        fontconfig.useEmbeddedBitmaps = true;

        nerd-fonts.packages =
          nf: with nf; [
            fira-code
            fira-mono
            noto
          ];
      };
    };
}
