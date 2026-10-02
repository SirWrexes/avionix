# Let's be honest.
# GRUB kinda sucks, and is definitely not necessary if we're going to single boot this thing.
# If goodness forbid you ever want to dual boot, just mkForce this bitch. ╮(ᵕ—ᴗ—)╭
{
  flake.nixosModules.core = {
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
