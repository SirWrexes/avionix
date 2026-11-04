{
  lib,

  symlinkJoin,
  makeWrapper,

  devilutionx,

  gameFiles ? [ ],
}:
let
  inherit (lib)
    baseNameOf
    concatMapStringsSep
    ;
in
symlinkJoin {
  name = "devilutionx";
  paths = [ devilutionx ];
  buildInputs = [ makeWrapper ];
  postBuild = concatMapStringsSep "\n" (
    pack: "ln -s ${pack} $out/share/diasurgical/devilutionx/${baseNameOf pack}"
  ) gameFiles;
}
