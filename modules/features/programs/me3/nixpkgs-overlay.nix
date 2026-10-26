{ inputs, dirs, ... }:
let
  overlay =
    final: prev:
    let
      inherit (builtins)
        unsafeDiscardStringContext
        ;

      inherit (prev)
        newScope
        ;

      inherit (prev.lib)
        listToAttrs
        makeScope
        removeSuffix
        ;

      files = inputs.import-tree.leaves "${dirs.packages}/me3-packages";
    in
    {
      me3Packages = makeScope newScope (
        self:
        listToAttrs (
          map (f: {
            name = unsafeDiscardStringContext (removeSuffix ".nix" (baseNameOf f));
            value = self.callPackage f { };
          }) files
        )
      );
    };
in
{
  flake.overlays.me3Packages = overlay;

  perSystem =
    { pkgs, ... }:
    let
      pkgs' = pkgs.appendOverlays [ overlay ];
    in
    {
      legacyPackages.me3Packages = pkgs'.me3Packages;
    };
}
