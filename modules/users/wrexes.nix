{
  flake.users.wrexes = {
    name = "wrexes";
    isNormalUser = true;
    useDefaultShell = true;
    description = "Sir Wrexes";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    initialPassword = "changeme";
  };
}
