# Realistically, I don't see myself needing to make any other user definition.
# But you never know! And I love things to be modular. I think those are good enough excuses.
# ...Right?
{ inputs, ... }:
let
  inherit (inputs) import-tree;
  inherit (inputs.nixpkgs.lib) hasSuffix removeSuffix mergeAttrsList;

  getUserNameFromPath = path: removeSuffix ".mod.nix" (baseNameOf path);
  mkUserAttr = path: {
    "${getUserNameFromPath path}" = import path;
  };
in
{
  flake.users = mergeAttrsList (
    import-tree
      #
      (i: i.initFilter (hasSuffix ".mod.nix"))
      (i: i.map mkUserAttr)
      (i: i.leaves ./.)
  );
}
