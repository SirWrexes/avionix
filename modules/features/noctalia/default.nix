{ self, inputs, ... }:

let
#  rawJsonSettings = builtins.readFile ./noctalia.json;
#  settingsObject = builtins.fromJSON rawJsonSettings;
#  settings = settingsObject.settings;
  settings = {};
in
{
  perSystem = { pkgs, ... }:
  {
    packages.wrx-noctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs settings;
    };
  };
}
