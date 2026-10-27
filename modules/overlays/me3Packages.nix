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
        zipAttrsWith
        ;

      parentOf = path: baseNameOf (dirOf path);
      toNestedPackage =
        pkgs: file:
        let
          parent = unsafeDiscardStringContext (parentOf file);
          file' = unsafeDiscardStringContext (baseNameOf file);
          package = removeSuffix ".nix" file';
        in
        {
          ${parent} = {
            name = package;
            value = pkgs.callPackage file { };
          };
        };

      mkNestedPackages =
        pkgs:
        inputs.import-tree (i: i.map (toNestedPackage pkgs)) (i: i.leaves "${dirs.packages}/me3-packages");
    in
    {
      me3Packages = makeScope newScope (
        self: zipAttrsWith (name: values: listToAttrs values) (mkNestedPackages self)
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
