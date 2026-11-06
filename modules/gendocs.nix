{ self, inputs, ... }:
{
  flake.docs =
    let
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      inherit (pkgs) lib;
      inherit (lib)
        elemAt
        hasPrefix
        removePrefix
        splitString
        ;

      modules = import "${pkgs.path}/nixos/modules/module-list.nix" ++ [
        self.nixosModules.default
        { nixpkgs.hostPlatform = system; }
      ];

      inherit (lib.evalModules { inherit modules; })
        options
        ;

      flakeStorePath = toString self;
      flakeRev =
        let
          FLAKE_REV = builtins.getEnv "FLAKE_REV";
        in
        if FLAKE_REV != "" then
          FLAKE_REV
        else
          builtins.warn "Building docs for unknown revision. Links will point to blobs from `main` but code might differ from docs." "main";
    in
    pkgs.nixosOptionsDoc {
      inherit pkgs lib;

      options = with options; {
        inherit
          dev
          display
          flake
          games
          shellScripts
          ;

        users = { inherit (users) user; };

        fonts = { inherit (fonts) nerd-fonts; };

        programs = with programs; {
          gnupg = { inherit (gnupg) ownertrust keys; };
          steam = { inherit (steam) dirs apps; };
        };

        services = with services; {
          inherit razerbat;
          input-remapper = { inherit (input-remapper) configDir; };
        };
      };

      transformOptions =
        opt:
        opt
        // {
          declarations = map (
            decl:
            let
              # Originally, `/nix/store/<hash path>/<module path>, via <module>`
              s = toString decl;

              outOfStoreDecl = removePrefix flakeStorePath s;
              outOfStoreDeclPath = elemAt (splitString "," outOfStoreDecl) 0;
            in
            if hasPrefix flakeStorePath s then
              {
                name = removePrefix "/" outOfStoreDecl;
                url = "https://github.com/SirWrexes/avionix/blob/${flakeRev}${outOfStoreDeclPath}";
              }
            else
              builtins.warn ''
                Some option declaration doesn't link to something from the flake: ${s}
                Check your documentation generator.
              '' s
          ) opt.declarations;
        };
    };
}
