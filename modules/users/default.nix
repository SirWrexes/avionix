{ self, inputs, ... }:
let
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;

  pkgs = import nixpkgs {};

  osConfigModules = lib.evalModules {
    modules = import "${nixpkgs}/nixos/modules/module-list.nix";
    specialArgs = { inherit pkgs; };
  };
in {
  options.flake = inputs.flake-parts.lib.mkSubmoduleOptions {
    users = lib.mkOption {
      inherit (osConfigModules.options.users.users) type;
      description = "Users of the NixOS configurations";
      default = {};
    };
  };
}
