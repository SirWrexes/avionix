## dev\.bash\.enable

Whether to enable Devtools for Bash\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/features/dev/bash\.nix, via option flake\.nixosModules\.dev](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/dev/bash.nix)



## dev\.bash\.formatter



The shfmt package to use\.



*Type:*
package



*Default:*

```nix
pkgs.shfmt
```

*Declared by:*
 - [modules/features/dev/bash\.nix, via option flake\.nixosModules\.dev](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/dev/bash.nix)



## dev\.bash\.languageServer



The bash-language-server package to use\.



*Type:*
package



*Default:*

```nix
pkgs.bash-language-server
```

*Declared by:*
 - [modules/features/dev/bash\.nix, via option flake\.nixosModules\.dev](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/dev/bash.nix)



## dev\.bash\.linter



The shellcheck package to use\.



*Type:*
package



*Default:*

```nix
pkgs.shellcheck
```

*Declared by:*
 - [modules/features/dev/bash\.nix, via option flake\.nixosModules\.dev](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/dev/bash.nix)



## dev\.nix\.enable



Whether to enable Devtools for Nix\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/features/dev/nix\.nix, via option flake\.nixosModules\.dev](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/dev/nix.nix)



## dev\.nix\.formatter



The nixfmt package to use\.



*Type:*
package



*Default:*

```nix
pkgs.nixfmt
```

*Declared by:*
 - [modules/features/dev/nix\.nix, via option flake\.nixosModules\.dev](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/dev/nix.nix)



## dev\.nix\.languageServer



The nil package to use\.



*Type:*
package



*Default:*

```nix
pkgs.nil
```

*Declared by:*
 - [modules/features/dev/nix\.nix, via option flake\.nixosModules\.dev](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/dev/nix.nix)



## display\.monitors



List of monitor info\.
Doesn’t actually set anything, but can be used to share information to other modules\.
Other modules can check if this module has been imported and configured with ` config.display.monitorsConfigured or false `\.



*Type:*
list of (submodule)



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/features/display\.nix, via option flake\.nixosModules\.desktop](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/display.nix)



## display\.monitors\.\*\.device



Device name (port)



*Type:*
string



*Example:*

```nix
"DP-1"
```

*Declared by:*
 - [modules/features/display\.nix, via option flake\.nixosModules\.desktop](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/display.nix)



## display\.monitors\.\*\.height



Monitor display height (pixels)



*Type:*
positive integer, meaning >0



*Example:*

```nix
1080
```

*Declared by:*
 - [modules/features/display\.nix, via option flake\.nixosModules\.desktop](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/display.nix)



## display\.monitors\.\*\.primary



Set this monitor as your primary display



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/features/display\.nix, via option flake\.nixosModules\.desktop](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/display.nix)



## display\.monitors\.\*\.refreshRate



Monitor display refresh rate (hertz)



*Type:*
positive integer, meaning >0



*Example:*

```nix
60
```

*Declared by:*
 - [modules/features/display\.nix, via option flake\.nixosModules\.desktop](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/display.nix)



## display\.monitors\.\*\.width



Monitor display width (pixels)



*Type:*
positive integer, meaning >0



*Example:*

```nix
1920
```

*Declared by:*
 - [modules/features/display\.nix, via option flake\.nixosModules\.desktop](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/display.nix)



## flake\.autoUpdate\.enable



Whether to enable auto updating of flake inputs\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/features/flake/auto-update\.nix, via option flake\.nixosModules\.flake](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/flake/auto-update.nix)



## flake\.autoUpdate\.command



The script that will run to update inputs



*Type:*
string



*Default:*

```nix
''
  /nix/store/3x16p9yylwijl4k8ba7bnidhkgbqasdx-nix-2.34.9/bin/nix flake update --flake "/etc/nixos"
''
```

*Declared by:*
 - [modules/features/flake/auto-update\.nix, via option flake\.nixosModules\.flake](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/flake/auto-update.nix)



## flake\.autoUpdate\.commit\.enable



Whether to enable committing the lockfile after an update\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/features/flake/auto-update\.nix, via option flake\.nixosModules\.flake](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/flake/auto-update.nix)



## flake\.autoUpdate\.commit\.command



Command used to commit the updated lockfile\.



*Type:*
string



*Default:*

```nix
''
  /nix/store/xgw813vgzl2q0696sq45adpj0xd690jq-git-2.56.0/bin/git -C "/etc/nixos" diff --quiet           -- "/etc/nixos/flake.lock" && \
  /nix/store/xgw813vgzl2q0696sq45adpj0xd690jq-git-2.56.0/bin/git -C "/etc/nixos" commit -m "[AUTO] Update flake inputs" -- "/etc/nixos/flake.lock"
''
```

*Declared by:*
 - [modules/features/flake/auto-update\.nix, via option flake\.nixosModules\.flake](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/flake/auto-update.nix)



## flake\.autoUpdate\.commit\.message



Message used when committing the updated lockfile\.



*Type:*
string



*Default:*

```nix
"[AUTO] Update flake inputs"
```

*Declared by:*
 - [modules/features/flake/auto-update\.nix, via option flake\.nixosModules\.flake](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/flake/auto-update.nix)



## flake\.autoUpdate\.notification\.enable



Whether to enable desktop notification when inputs have been updated\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/features/flake/auto-update\.nix, via option flake\.nixosModules\.flake](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/flake/auto-update.nix)



## flake\.autoUpdate\.notification\.actions



Actions to provide on the notification pop-up\.
These must be shell snippets and will be converted into scripts\.



*Type:*
attribute set of string



*Default:*

```nix
{
  "Apply updates" = ''
    ''${TERMINAL:-/nix/store/9kf88zx0zhvilvlrrf9na9dsmax8m13z-konsole-26.08.2/bin/konsole} -e /nix/store/kwyi4bq5s2qgwbhz6cs4gjy57c2zdxws-bash-interactive-5.3p20/bin/bash -c "
      if /nix/store/7dbpy71z609raq51wv5m226acm62ril3-nixos-rebuild-ng-26.11/bin/nixos-rebuild --flake /etc/nixos#nixos switch; then
        exit 0
      fi
    
      # Keep terminal open on error
      exec /nix/store/kwyi4bq5s2qgwbhz6cs4gjy57c2zdxws-bash-interactive-5.3p20/bin/bash
    "
  '';
  "Dry build" = ''
    ''${TERMINAL:-/nix/store/9kf88zx0zhvilvlrrf9na9dsmax8m13z-konsole-26.08.2/bin/konsole} -e /nix/store/kwyi4bq5s2qgwbhz6cs4gjy57c2zdxws-bash-interactive-5.3p20/bin/bash -c '
      if /nix/store/7dbpy71z609raq51wv5m226acm62ril3-nixos-rebuild-ng-26.11/bin/nixos-rebuild --flake /etc/nixos#nixos dry-build; then
        read -p "Dry run successful. Would you like to apply the update? [Y/n]" -n 1 -r CHOICE
        if [[ -z "$CHOICE" || "$CHOICE" ~= ^[Yy]\$ ]] && /nix/store/7dbpy71z609raq51wv5m226acm62ril3-nixos-rebuild-ng-26.11/bin/nixos-rebuild --flake /etc/nixos#nixos switch; then
          exit 0
        fi
      fi
    
      # Keep terminal open on error
      exec /nix/store/kwyi4bq5s2qgwbhz6cs4gjy57c2zdxws-bash-interactive-5.3p20/bin/bash
    '
  '';
}
```

*Declared by:*
 - [modules/features/flake/auto-update\.nix, via option flake\.nixosModules\.flake](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/flake/auto-update.nix)



## flake\.autoUpdate\.notification\.icon



Icon for the notification\.



*Type:*
absolute path



*Default:*

```nix
"/nix/store/2qcrn5ay12pnbaf9lb0bbxfjm7abx497-mgfvrd3w2ddg4mxqchj5j6mcyfyrm88k-source/assets/icons/nixos.png"
```

*Declared by:*
 - [modules/features/flake/auto-update\.nix, via option flake\.nixosModules\.flake](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/flake/auto-update.nix)



## flake\.autoUpdate\.notification\.message



Message to display on the notification\.



*Type:*
string



*Default:*

```nix
"Your flake inputs have been updated."
```

*Declared by:*
 - [modules/features/flake/auto-update\.nix, via option flake\.nixosModules\.flake](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/flake/auto-update.nix)



## flake\.autoUpdate\.notification\.timeout



Duration of the notification (in miliseconds)



*Type:*
unsigned integer, meaning >=0



*Default:*

```nix
0
```

*Declared by:*
 - [modules/features/flake/auto-update\.nix, via option flake\.nixosModules\.flake](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/flake/auto-update.nix)



## flake\.autoUpdate\.preRunHook



Runs before calling the update command\. If it returns a non-zero value, the update is prevented\.



*Type:*
string



*Default:*

```nix
"true"
```

*Declared by:*
 - [modules/features/flake/auto-update\.nix, via option flake\.nixosModules\.flake](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/flake/auto-update.nix)



## flake\.host



Target machine’s name\.



*Type:*
string matching the pattern ^$|^\[\[:alnum:]](\[\[:alnum:]_-]{0,61}\[\[:alnum:]])?$



*Default:*

```nix
"nixos"
```

*Declared by:*
 - [modules/features/flake/default\.nix, via option flake\.nixosModules\.flake](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/flake/default.nix)



## flake\.kateproject\.enable



Enable generating a ` .kateproject ` project plugin in your flake’s root directory\.
This file will add options to build, test, switch from inside Kate\.
It will also have options to build the various packages of your flake if ` flake.kateproject.packages ` is set\.

More info: https://docs\.kde\.org/stable_kf6/en/kate/kate/kate-application-plugin-projects\.html



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/features/flake/kateproject\.nix, via option flake\.nixosModules\.flake](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/flake/kateproject.nix)



## flake\.kateproject\.lspclient\.package



The nil package to use\.



*Type:*
package



*Default:*

```nix
pkgs.nil
```

*Declared by:*
 - [modules/features/flake/kateproject\.nix, via option flake\.nixosModules\.flake](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/flake/kateproject.nix)



## flake\.kateproject\.lspclient\.args



Arguments passed to the LSP client\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/features/flake/kateproject\.nix, via option flake\.nixosModules\.flake](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/flake/kateproject.nix)



## flake\.kateproject\.lspclient\.extraSettings



Extra LSP settings for your editor\.
Will be merged with ` flake.kateproject.lspSettings ` using ` lib.mkMerge `\.



*Type:*
attribute set of (JSON value)



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/features/flake/kateproject\.nix, via option flake\.nixosModules\.flake](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/flake/kateproject.nix)



## flake\.kateproject\.lspclient\.settings



LSP settings for your editor\.



*Type:*
attribute set of (JSON value)



*Default:*

```nix
{
  servers = {
    nix = {
      command = [
        "/nix/store/43w2c08ayi5sp7z7a5xv86sr45smix3z-nil-2026-07-23/bin/nil"
      ];
      highlightingModeRegex = "^Nix$";
      settings = {
        nil = {
          formatting = {
            command = [
              "/nix/store/903yaq3yjr8zjcfskmr7f16ha9hha7by-nixfmt-1.5.0/bin/nixfmt"
            ];
          };
          nix = {
            flake = {
              autoArchive = true;
              autoEvalInputs = true;
            };
          };
        };
      };
      url = "https://github.com/oxalica/nil";
    };
  };
}
```

*Declared by:*
 - [modules/features/flake/kateproject\.nix, via option flake\.nixosModules\.flake](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/flake/kateproject.nix)



## flake\.name



A name for your OS config flake\.



*Type:*
string



*Default:*

```nix
"Cool NixOS flake"
```



*Example:*

```nix
"Even cooler NixOS flake"
```

*Declared by:*
 - [modules/features/flake/default\.nix, via option flake\.nixosModules\.flake](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/flake/default.nix)



## flake\.root



Absolute path to your flake’s root directory\.



*Type:*
absolute path not in the Nix store



*Default:*

```nix
"/etc/nixos"
```



*Example:*

```nix
"/home/user/.nixos"
```

*Declared by:*
 - [modules/features/flake/default\.nix, via option flake\.nixosModules\.flake](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/flake/default.nix)



## flake\.self



Your flake’s ` self `\.
This option doesn’t do any type checking\.
Behaviour is you provide it with anything else than your flake’s ` self ` is undefined\.



*Type:*
lazy attribute set of anything



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/features/flake/default\.nix, via option flake\.nixosModules\.flake](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/flake/default.nix)



## fonts\.nerd-fonts\.packages



NerdFonts packages to install\.



*Type:*
function that evaluates to a(n) list of package



*Default:*

```nix
<function>
```



*Example:*

```nix
nf: with nf; [
  fira-mono
  fira-code
]

```

*Declared by:*
 - [modules/features/fonts\.nix, via option flake\.nixosModules\.fonts](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/fonts.nix)



## games\.devilutionx\.enable



Whether to enable DevilutionX\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/features/games/devilutionx\.nix, via option flake\.nixosModules\.games](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/games/devilutionx.nix)



## games\.devilutionx\.gameFiles



Game files for DevilutionX\.

See https://github\.com/diasurgical/DevilutionX\#how-to-install
For licensig reason, it is recommended not to push these in a git repo\.
Instead, use a secret management solution\.



*Type:*
list of (string or absolute path)



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "\${./.}/games/devilutionx/DIABDAT.MPQ"
]
```

*Declared by:*
 - [modules/features/games/devilutionx\.nix, via option flake\.nixosModules\.games](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/games/devilutionx.nix)



## programs\.gnupg\.keys



Keys to import, indexed by their fingerprint\.



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  "273ED719F8D1F17F28F92AE14CEBB3E827CABB7E" = {
    # Could be a path provided by a secret management tool
    private = config.age.secrets.gpg-private.path;
    # Or an absolute path to somehwere outside your flake
    public = "/path/to/secrets/gpg-public.asc";
  };
}

```

*Declared by:*
 - [modules/features/programs/gnupg/secrets\.nix, via option flake\.nixosModules\.secrets](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/gnupg/secrets.nix)



## programs\.gnupg\.keys\.\<fingerprint>\.private



Export with ` gpg --armor --export-secret-keys your_email@example.com > private-key.asc `



*Type:*
null or absolute path not in the Nix store



*Default:*

```nix
null
```



*Example:*

```nix
config.age.secrets."273ED719F8D1F17F28F92AE14CEBB3E827CABB7E.prv".path
```

*Declared by:*
 - [modules/features/programs/gnupg/secrets\.nix, via option flake\.nixosModules\.secrets](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/gnupg/secrets.nix)



## programs\.gnupg\.keys\.\<fingerprint>\.public



Export with ` gpg --armor --export your_email@example.com > public-key.asc `



*Type:*
null or absolute path not in the Nix store



*Default:*

```nix
null
```



*Example:*

```nix
config.age.secrets."273ED719F8D1F17F28F92AE14CEBB3E827CABB7E.pub".path
```

*Declared by:*
 - [modules/features/programs/gnupg/secrets\.nix, via option flake\.nixosModules\.secrets](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/gnupg/secrets.nix)



## programs\.gnupg\.ownertrust



Export with ` gpg --export-ownertrust > some/path/ownertrust.txt `



*Type:*
null or absolute path not in the Nix store



*Default:*

```nix
null
```



*Example:*

```nix
"/home/someuser/nixflake/secrets/ownertrust.txt"
```

*Declared by:*
 - [modules/features/programs/gnupg/secrets\.nix, via option flake\.nixosModules\.secrets](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/gnupg/secrets.nix)



## programs\.steam\.apps



Set of options and configs for each of your Steam apps\.
For shortcuts to non-Steam apps, see ` programs.steam.shortcuts ` (arriving Soon™️)\.



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.launchOptions\.enable



Whether to enable managing launch options for app ‹name› from nix\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.launchOptions\.text



Steam app ‹name›'s launch options



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.enable



Whether to enable managing launch options for this app ‹name› from nix\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings



Attribute set of protontricks settings for your app\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.alldlls



builtin -> Override most common DLLs to builtin  
default -> Remove all DLL overrides



*Type:*
null or one of “builtin”, “default”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.autostart_winedbg



enabled  -> Automatically launch winedbg when an unhandled exception occurs (default)
disabled -> Prevent winedbg from launching when an unhandled exception occurs



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.cfc



enabled  -> Enable CheckFloatConstants
disabled -> Disable CheckFloatConstants (default)



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.csmt



off -> Disable Command Stream Multithreading  
on -> Enable Command Stream Multithreading (default)  
force -> Enable and force serialisation of OpenGL or Vulkan commands between multiple command streams in the same application



*Type:*
null or one of “off”, “on”, “force”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.fontsmooth



```
bgr -> Enable subpixel font smoothing for BGR LCDs  
rgb -> Enable subpixel font smoothing for RGB LCDs  
```

gray -> Enable subpixel font smoothing  
disable -> Disable font smoothing



*Type:*
null or one of “bgr”, “rgb”, “gray”, “disable”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.grabfullscreen



enabled  -> Disable cursor clipping for full-screen windows (default)  
disabled -> Force cursor clipping for full-screen windows (needed by some games)



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.graphics



default -> Set graphics driver to default  
mac -> Set graphics driver to Quartz (for macOS)  
wayland -> Set graphics driver to Wayland  
x11 -> Set graphics driver to X11



*Type:*
null or one of “default”, “mac”, “wayland”, “x11”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.gsm



Set MaxShaderModelGS to the chosen value



*Type:*
null or integer between 0 and 3 (both inclusive)



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.mackeyremap



none -> Do not remap keys for the Mac native driver (default)  
left -> Enable mapping of left opt->alt and cmd->ctrl keys for the Mac native driver  
both -> Enable mapping opt->alt and cmd->ctrl keys for the Mac native driver



*Type:*
null or one of “none”, “left”, “both”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.mimeassoc



enabled  -> Enable exporting MIME-type file associations to the native desktop (default)  
disabled -> Disable exporting MIME-type file associations to the native desktop



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.mwo



enabled  -> Set DirectInput MouseWarpOverride to enabled (default)
disabled -> Set DirectInput MouseWarpOverride to disable
force    -> Set DirectInput MouseWarpOverride to force (needed by some games)



*Type:*
null or boolean or string matching the pattern force



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.orm



backbuffer -> Set OffscreenRenderingMode=backbuffer  
fbo -> Set OffscreenRenderingMode=fbo (default)



*Type:*
null or one of “backbuffer”, “fbo”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.psm



Set MaxShaderModelPS to the chosen value



*Type:*
null or integer between 0 and 3 (both inclusive)



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.renderer



gdi -> Set renderer to gdi  
gl -> Set renderer to gl  
no3d -> Set renderer to no3d  
vulkan -> Set renderer to vulkan



*Type:*
null or one of “gdi”, “gl”, “no3d”, “vulkan”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.rtlm



```
auto -> Set RenderTargetLockMode to auto (default)  
```

disabled -> Set RenderTargetLockMode to disabled  
readdraw -> Set RenderTargetLockMode to readdraw  
readtex -> Set RenderTargetLockMode to readtex  
texdraw -> Set RenderTargetLockMode to texdraw  
textex -> Set RenderTargetLockMode to textex



*Type:*
null or one of “auto”, “disabled”, “readdraw”, “readtex”, “texdraw”, “textex”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.shader_backend



arb -> Set shader_backend to arb  
glsl -> Set shader_backend to glsl  
none -> Set shader_backend to none



*Type:*
null or one of “arb”, “glsl”, “none”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.sound



```
 alsa -> Set sound driver to ALSA  
pulse -> Set sound driver to PulseAudio  
```

coreaudio -> Set sound driver to Mac CoreAudio  
oss -> Set sound driver to OSS  
disabled -> Set sound driver to disabled



*Type:*
null or one of “alsa”, “pulse”, “coreaudio”, “oss”, “disabled”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.ssm



enabled  -> Enable Struct Shader Math
disabled -> Disable Struct Shader Math (default)



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.theme



light -> Use default Wine theme (light) for the WINEPREFIX  
dark -> Use dark theme for the WINEPREFIX



*Type:*
null or one of “light”, “dark”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.useegl



enabled  -> Enable EGL (default)  
disabled -> Disable EGL, use GLX instead



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.usetakefocus



enabled  -> Enable UseTakeFocus  
disabled -> Disable UseTakeFocus (default)



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.vd



Use a virtual desktop of size \<width>x\<height>\.
Set to off or disabled to disable\.



*Type:*
null or string matching the pattern off or string matching the pattern disabled or string matching the pattern \[1-9]\*x\[1-9]\*



*Default:*

```nix
null
```



*Example:*

```nix
"1920x1080"
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.videomemorysisze



Inform Wine of your VRAM in MB\.
Use “default” to let Wine detect it automatically\. (default)



*Type:*
null or string matching the pattern default or (positive integer, meaning >0)



*Default:*

```nix
null
```



*Example:*

```nix
2048
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.vsm



Set MaxShaderModelVS to the chosen value



*Type:*
null or integer between 0 and 3 (both inclusive)



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.windowmanagerdecorated



enabled  -> Allow the window manager to decorate windows (default)  
disabled -> Prevent the window manager from decorating windows



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.windowmanagermanaged



enabled  -> Allow the window manager to control windows (default)  
disabled -> Prevent the window manager from controlling windows



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.apps\.\<id>\.protontricks\.settings\.winver



default -> Set Windows version to default (win7)  
winme -> Set Windows version to Windows ME  
nt351 -> Set Windows version to Windows NT 3\.51  
nt40 -> Set Windows version to Windows NT 4\.0  
win20 -> Set Windows version to Windows 2\.0  
win30 -> Set Windows version to Windows 3\.0  
win31 -> Set Windows version to Windows 3\.1  
win95 -> Set Windows version to Windows 95  
win98 -> Set Windows version to Windows 98  
win2k -> Set Windows version to Windows 2000  
win2k3 -> Set Windows version to Windows 2003  
win2k8 -> Set Windows version to Windows 2008  
win2k8r2 -> Set Windows version to Windows 2008 R2  
winxp -> Set Windows version to Windows XP  
vista -> Set Windows version to Windows Vista  
win7 -> Set Windows version to Windows 7  
win8 -> Set Windows version to Windows 8  
win81 -> Set Windows version to Windows 8\.1  
win10 -> Set Windows version to Windows 10 (default)  
win11 -> Set Windows version to Windows 11



*Type:*
null or one of “default”, “winme”, “nt351”, “nt40”, “win20”, “win30”, “win31”, “win95”, “win98”, “win2k”, “win2k3”, “win2k8”, “win2k8r2”, “winxp”, “vista”, “win7”, “win8”, “win81”, “win10”, “win11”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## programs\.steam\.dirs\.steam



Path to your Steam root\.
This doesn’t change where Steam is installed, rather it is used by scripts in this module to find the things it needs\.



*Type:*
string



*Default:*

```nix
"$HOME/.steam/steam"
```

*Declared by:*
 - [modules/features/programs/steam/default\.nix, via option flake\.nixosModules\.programs](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/programs/steam/default.nix)



## services\.input-remapper\.configDir



Path to where your Input Remapper configs are saved\.



*Type:*
null or string matching the pattern /(\[^/]+/)\*\[^/]+/?



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/services/input-remapper\.nix, via option flake\.nixosModules\.services](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/services/input-remapper.nix)



## services\.razerbat\.enable



Whether to enable Razer battery indicator\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/features/services/razerbat\.nix, via option flake\.nixosModules\.services](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/services/razerbat.nix)



## services\.razerbat\.package



The razerbat package to use\.



*Type:*
package



*Default:*

```nix
pkgs.razerbat
```

*Declared by:*
 - [modules/features/services/razerbat\.nix, via option flake\.nixosModules\.services](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/services/razerbat.nix)



## services\.razerbat\.devices



Device(s) to enable the tray for\.
If left empty, razerbat will be installed but no autostart service will be created\.



*Type:*
string or list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "Naga V2 HyperSpeed"
]
```

*Declared by:*
 - [modules/features/services/razerbat\.nix, via option flake\.nixosModules\.services](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/services/razerbat.nix)



## services\.razerbat\.quitOnDisconnect



Device(s) to enable quitting on disconnect for\.



*Type:*
string or list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "Naga V2 HyperSpeed"
]
```

*Declared by:*
 - [modules/features/services/razerbat\.nix, via option flake\.nixosModules\.services](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/services/razerbat.nix)



## shellScripts\.dupes\.enable



Whether to enable shell script ‘dupes’\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/features/scripts\.nix, via option flake\.nixosModules\.scripts](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/scripts.nix)



## users\.user



Main user of the config\.
Will take care of defining the corresponding ` users.users.<name> ` entry\.



*Type:*
null or (submodule)



*Default:*

```nix
null
```

*Declared by:*
 - [modules/features/user\.nix, via option flake\.nixosModules\.user](https://github.com/SirWrexes/avionix/blob/b573cadc877c0595807ad73da40820de244b08f6/modules/features/user.nix)


