{
  perSystem =
    { pkgs, lib, ... }:
    {
      devShells.default = pkgs.mkShell {
        shellHook = ''
          git config set core.hooksPath .githooks
        '';
      };
    };
}
