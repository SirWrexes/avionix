{ self, dirs, ... }:
let
  scriptsDir = with builtins; rec {
    meta = readDir dirs.scripts;
    nixFiles = filter (name: meta.${name} == "regular" && !isNull (match ''.*\.nix'' name)) (
      attrNames meta
    );
  };

  scripts =
    with builtins;
    let
      list = map (file: {
        name = elemAt (match ''(.*)\.nix'' file) 0;
        value = "${dirs.scripts}/${file}";
      }) scriptsDir.nixFiles;
    in
    listToAttrs list;
in
{
  flake.nixosModules.scripts =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      options.shellScripts = builtins.mapAttrs (name: file: {
        enable = lib.mkEnableOption "shell script '${name}'" // {
          default = true;
        };
        package = lib.mkPackageOption self.packages.${pkgs.stdenv.hostPlatform.system} name { } // {
          readOnly = true;
        };
      }) scripts;

      config.environment.systemPackages = lib.foldlAttrs (
        acc: name: file:
        let
          cfg = config.shellScripts.${name};
        in
        lib.optional cfg.enable cfg.package ++ acc
      ) [ ] scripts;
    };

  # TODO: Use legacyPackages.shellScripts
  perSystem =
    { pkgs, ... }:
    {
      packages = builtins.mapAttrs (name: file: pkgs.callPackage file { }) scripts;
    };
}
