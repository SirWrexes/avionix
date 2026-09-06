{
  description = "Avionix: NixOS configs from outer space";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Note:
  #  The flake is neatly organised in a feature-oriented directory architecture.
  #  I tried my best making it make sense and I'm quite happy with the results.
  #
  #  I kept the habit of making <module>/default.nix files, but it isn't *necessary*, due to import-tree.
  #  That said, it is a Nix-idiomatic name and any Nix user with the slightest experience will recognise it is the entry
  #  point of the module. That is why I decided to keep it as such.
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
