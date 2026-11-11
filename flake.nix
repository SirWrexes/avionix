rec {
  description = "🛫 Avionix — Dotfiles from outer space";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";

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
    flake-parts.lib.mkFlake
      {
        inherit inputs;

        specialArgs = {
          inherit description;

          # Yes, I know <nixpkgs>' flake says it's bad.
          # But it's quite useful, and I think I know what I'm doing.
          lib' = nixpkgs.lib.extend (import ./lib);

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
      }
      (
        import-tree.filterNot (nixpkgs.lib.hasSuffix ".mod.nix") [
          ./devShells
          ./hardware-configs
          ./modules
          ./users
        ]
      );
}
