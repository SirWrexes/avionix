with builtins;
let

  wrexes = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEeZ2bPiL1z9knSjESgr+nZKzyPSDdmoG5OGrFKFltpC";

  recursiveMerge = foldl' (acc: x: acc // x) { };

  # Takes a set of arbitrary depths, and transforms its paths to `dir.secrets = [ "file1" "file2" ]`
  # into a flat set of `{ "some/arbitrary/depth/path/to/dir.age".publicKeys = [ wrexes ] }`.
  transform' =
    prefix: set:
    let
      fileToAttrs = file: {
        name = if prefix == "" then "${file}.age" else "${prefix}/${file}.age";
        value = {
          publicKeys = [ wrexes ];
        };
      };
      currentSecrets = if set ? secrets then listToAttrs (map fileToAttrs set.secrets) else { };
      subdirKeys = filter (k: k != "secrets") (attrNames set);
      transformNext =
        k:
        let
          nextPrefix = if prefix == "" then k else "${prefix}/${k}";
        in
        transform' nextPrefix set.${k};
      nestedSecrets = map transformNext subdirKeys;
    in
    recursiveMerge ([ currentSecrets ] ++ nestedSecrets);

  transform = transform' "";
in
transform {
  devilutionx.secrets = [
    "DIABDAT.MPQ"
    "hellfire.mpq"
    "hfmonk.mpq"
    "hfmusic.mpq"
    "hfvoice.mpq"
  ];
  gpg.secrets = [
    "E5C24624BEC13FD00B989E32A2838A891FE0378A.prv"
    "E5C24624BEC13FD00B989E32A2838A891FE0378A.pub"
    "ownertrust"
  ];
}
