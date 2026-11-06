{
  perSystem =
    { pkgs, lib, ... }:
    {
      devShells.default = pkgs.mkShell {
        shellHook = ''
          echo ziggy gougou zgoin
          git config set core.hooksPath .githooks
        '';
      };
    };
}
