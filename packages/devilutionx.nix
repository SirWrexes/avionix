{
  symlinkJoin,
  makeWrapper,

  devilutionx,

  gameFiles ? [ ],
}:

symlinkJoin {
  name = "devilutionx";
  paths = [ devilutionx ];
  buildInputs = [ makeWrapper ];
  postBuild =
    let
      linkPack = pack: "ln -s ${pack} $out/share/diasurgical/devilutionx/${builtins.baseNameOf pack}";
    in
    ''
      ${builtins.concatStringsSep "\n" (builtins.map linkPack gameFiles)}
    '';
}
