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

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = {
        dirs = {
          root = ./.;

          assets = ./assets;
          icons = ./assets/icons;

          hosts = ./hosts;
          packages = ./packages;
          secrets = ./secrets;
        };
      };
    } (inputs.import-tree ./modules);
}
