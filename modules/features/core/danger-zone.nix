# Things might explode if you change stuff in there.
#
#
# Be VERY careful.
#
#
# Only change if you know what you are doing.
#
#
# I mean it.
#
#
# ...
#
#
# No but for real though.
{ ... }:
{
  flake.nixosModules.core = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    system.stateVersion = "26.05";
  };
}
