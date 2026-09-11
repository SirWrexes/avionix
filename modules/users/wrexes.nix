{ self, inputs, ... }:
{
  flake.users.wrexes = {
    name = "wrexes";
    isNormalUser = true;
    description = "Sir Wrexes";
    extraGroups = [ "networkmanager" "wheel" ];
    initialPassword = "changeme";
  };
}
