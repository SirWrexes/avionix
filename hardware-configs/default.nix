{ inputs, ... }:
let
  inherit (inputs) import-tree;
  inherit (inputs.nixpkgs.lib) hasSuffix removeSuffix mergeAttrsList;

  getHostNameFromPath = path: removeSuffix ".mod.nix" (baseNameOf path);
  mkConfigAttr = path: {
    "${getHostNameFromPath path}" = import path;
  };
in
{
  flake.hardwareConfigs = mergeAttrsList (
    import-tree
      #
      (i: i.initFilter (hasSuffix ".mod.nix"))
      (i: i.map mkConfigAttr)
      (i: i.leaves ./.)
  );
}
