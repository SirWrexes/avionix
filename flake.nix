{
  description = "Avionix: NixOS configs from outer space";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-parts,
      import-tree,
      ...
    }@inputs:
    flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = {
        dirs = rec {
          root = ./.;

          assets = "${root}/assets";
          icons = "${assets}/icons";

          hosts = "${root}/hosts";
          secrets = "${root}/secrets";

          packages = "${root}/packages";
          scripts = "${packages}/scripts";
        };
      };
    } (import-tree.filterNot (nixpkgs.lib.hasSuffix ".mod.nix") ./modules);
}
