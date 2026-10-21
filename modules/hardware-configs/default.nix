{ inputs, hosts, ... }:
let
  inherit (inputs.nixpkgs.lib) map listToAttrs;

  configs = map (host: {
    name = host;
    value = import "${./.}/${host}.mod.nix";
  }) hosts;
in
{
  flake.hardwareConfigs = listToAttrs configs;
}
