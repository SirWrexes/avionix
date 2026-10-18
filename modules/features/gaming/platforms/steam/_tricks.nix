{ lib, ... }:
let
  inherit (lib)
    fixedWidthString
    mkOption
    optionalString
    replaceString
    ;

  types = lib.types // {
    force = types.strMatching "force";
  };

  longestElementLength =
    strings:
    builtins.foldl' (
      max: str:
      let
        len = builtins.stringLength str;
      in
      if len > max then len else max
    ) 0 strings;

  padRight = len: str: fixedWidthString len " " str;

  awkCaptureInside = key: ''
    /^\[${replaceString ''\'' ''\\\\'' key}]/ {
      capturing = 1
      next
    }

    capturing && /^\[/ {
      capturing = 0
      next
    }
  '';

  awkCaptureMatchString = name: ''
    capturing && match($0, /^"${name}"="([^"])"/, m) {
      ${name} = m[1]
      next
    }
  '';

  awkCaptureMatchDword = name: ''
    capturing && match($0, /^"${name}"=dword:([[:digit:]]*)/, m) {
      ${name} = m[1]
      next
    }
  '';

  awkExpect = name: ''
    END { if (${name} != expected) exit 1 }
  '';

  awkExpectEqual =
    pairs:
    let
      lines = builtins.map (
        pair: "if (${builtins.elemAt pair 0} != ${builtins.elemAt pair 1}) exit 1"
      ) pairs;
    in
    ''
      END {
        ${builtins.concatStringsSep "\n" lines}
      }
    '';

  mkEnum =
    { values, check }:
    let
      names = builtins.map ({ name, ... }: name) values;
      width = longestElementLength names;
      descriptions = builtins.map ({ name, desc }: "${padRight width name} -> desc") values;
    in
    {
      inherit check;
      option = mkOption {
        type = with types; nullOr (enum names);
        description = builtins.concatStringsSep "\n" descriptions;
      };
    };

  mkYesNo =
    {
      yes,
      no,
      check,
    }:
    {
      inherit check;
      option = mkOption {
        type = with types; nullOr bool;
        description = ''
          enabled  -> ${yes}
          disabled -> ${no}
        '';
        apply =
          value:
          if builtins.isNull value then
            value
          else if value then
            "y"
          else
            "n";
      };
    };

  mkOnOff =
    {
      on,
      off,
      force ? null,
      check,
    }:
    let
      hasForce = !builtins.isNull force;
    in
    {
      inherit check;
      option = mkOption {
        type = with types; if hasForce then nullOr (either bool types.force) else nullOr bool;
        description = ''
          enabled  -> ${on}
          disabled -> ${off}${optionalString hasForce "\nforce    -> ${force}"}
        '';
        apply =
          value:
          if (builtins.isNull value || value == "force") then
            value
          else if value then
            "on"
          else
            "off";
      };
    };

  # There are inconsistencies among the verbs following an enable/disable pattern, so we have to do some extra
  # checks to get the right terms.
  # Most of these actually get corrected to je enable/disable, but I'm too lazy to roll this back for now.
  mkEnableDisable =
    {
      enable ? null,
      enabled ? null,
      disable ? null,
      disabled ? null,
      force ? null,
      check,
    }:
    let
      truthyValue = if !builtins.isNull enable then "enable" else "enabled";
      falsyValue = if !builtins.isNull disable then "disable" else "disabled";

      truthyDesc = if !builtins.isNull enable then enable else enabled;
      falsyDesc = if !builtins.isNull disable then disable else disabled;

      hasForce = !builtins.isNull force;
    in
    {
      inherit check;
      option = mkOption {
        type = with types; if hasForce then nullOr (either bool types.force) else nullOr bool;
        description = ''
          enabled  -> ${truthyDesc}
          disabled -> ${falsyDesc}${optionalString hasForce "\nforce    -> ${force}"}
        '';
        apply =
          value:
          if (builtins.isNull value || value == "force") then
            value
          else if value then
            truthyValue
          else
            falsyValue;
      };
    };

  mkIntBetween =
    lowest: highest:
    { name, check }:
    {
      inherit check;
      option = mkOption {
        type = with types; nullOr (ints.between lowest highest);
        description = "Set ${name} to the chosen value";
        apply = value: if builtins.isNull value then value else builtins.toString value;
      };
    };
in
{
  alldlls = mkEnum {
    values = [
      {
        name = "builtin";
        desc = "Override most common DLLs to builtin";
      }
      {
        name = "default";
        desc = "Remove all DLL overrides";
      }
    ];
    # TODO: Don't forget to set WINETRICKS in module config
    check = ''
      WINETRICKS=$(cat $(command -v winetricks) | sed -n 's|.*"\(/nix/store/.*\.winetricks-wrapped\)".*|\1|p')

      if [[ "$OPTION_VALUE" =~ "default" ]]; then
        ! grep -qF 'Software\\Wine\\DllOverrides' "$HKCU"
              else
        awk '
          FILENAME == ARGV[1] {
            if (/w_override_all_dlls\(\)/) {
              inside_fn = 1
              next
            }

            if (inside_fn && /w_override_dlls builtin/) {
              capturing = 1
              next
            }

            if (capturing && /# blank line/) {
              capturing = 0
              inside_fn = 0
              next
            }

            if (capturing) {
              gsub(/\\|#.*/, "")
              for (i = 1; i <= NF; i++)
                if ($i != "w_override_dlls" && $i != "builtin") needed[$i] = 1
            }
          }

          FILENAME == ARGV[2] {
            if (match($0, /^"\*?([^"]+)"="builtin"/, m)) delete needed[m[1]]
          }

          END {
            missing_count = 0
            for (dll in needed) missing_count++
            if (missing_count > 0) exit 1
          }
        ' "$WINETRICKS" "$HKCU"
      fi
    '';
  };

  autostart_winedbg = mkEnableDisable {
    enabled = "Automatically launch winedbg when an unhandled exception occurs (default)";
    disabled = "Prevent winedbg from launching when an unhandled exception occurs";
    check = ''
      awk -v expected="$OPTION_VALUE" '
        ${awkCaptureInside ''Software\Microsoft\Windows NT\CurrentVersion\AeDebug''}
        ${awkCaptureMatchString "Debugger"}
        ${awkExpect "Debugger"}
      ' "$HKLM"
    '';
  };

  cfc = mkEnableDisable {
    enabled = "Enable CheckFloatConstants";
    disabled = "Disable CheckFloatConstants (default)";
    check = ''
      awk -v expected="$OPTION_VALUE" '
        ${awkCaptureInside ''Software\Wine\Direct3D''}
        ${awkCaptureMatchString "CheckFloatConstants"}
        ${awkExpect "CheckFloatConstants"}
      ' "$HKCU"
    '';
  };

  csmt = mkEnum {
    values = [
      {
        name = "off";
        desc = "Disable Command Stream Multithreading";
      }
      {
        name = "on";
        desc = "Enable Command Stream Multithreading (default)";
      }
      {
        name = "force";
        desc = "Enable and force serialisation of OpenGL or Vulkan commands between multiple command streams in the same application";
      }
    ];
    check = ''
      case "$OPTION_VALUE" in
        off)   csmt=0;;
        on)    csmt=1;;
        force) csmt=3;;
      esac

      awk -v expected=$csmt '
        ${awkCaptureInside ''Software\Wine\Direct3D''}
        ${awkCaptureMatchDword "csmt"}
        ${awkExpect "csmt"}
      ' "$HKCU"
    '';
  };

  fontsmooth = mkEnum {
    values = [
      {
        name = "bgr";
        desc = "Enable subpixel font smoothing for BGR LCDs";
      }
      {
        name = "rgb";
        desc = "Enable subpixel font smoothing for RGB LCDs";
      }
      {
        name = "gray";
        desc = "Enable subpixel font smoothing";
      }
      {
        name = "disable";
        desc = "Disable font smoothing";
      }
    ];
    check = ''
      case "$OPTION_VALUE" in
        disable)   smoothing=0; orientation=1; type=0;;
        gray)      smoothing=2; orientation=1; type=1;;
        bgr)       smoothing=2; orientation=0; type=2;;
        rgb)       smoothing=2; orientation=1; type=2;;
      esac

      awk -v smoothing=$smoothing -v orientation=0000000$orientation -v type=0000000$type '
        ${awkCaptureInside ''Control Panel\Desktop''}
        ${awkCaptureMatchString "FontSmoothing"}
        ${awkCaptureMatchDword "FontSmoothingOrientation"}
        ${awkCaptureMatchDword "FontSmoothingType"}
        ${awkExpectEqual [
          [
            "FontSmoothing"
            "smoothing"
          ]
          [
            "FontSmoothingOrientation"
            "orientation"
          ]
          [
            "FontSmoothingType"
            "type"
          ]
        ]}
      ' "$HKCU"
    '';
  };

  grabfullscreen = mkYesNo {
    yes = "Disable cursor clipping for full-screen windows (default)";
    no = "Force cursor clipping for full-screen windows (needed by some games)";
    check = ''
      awk -v expected="$OPTION_VALUE" '
        ${awkCaptureInside ''Software\Wine\X11 Driver''}
        ${awkCaptureMatchString "GrabFullscreen"}
        ${awkExpect "GrabFullscreen"}
      ' "$HKCU"
    '';
  };

  graphics = mkEnum {
    values = [
      {
        name = "default";
        desc = "Set graphics driver to default";
      }
      {
        name = "mac";
        desc = "Set graphics driver to Quartz (for macOS)";
      }
      {
        name = "wayland";
        desc = "Set graphics driver to Wayland";
      }
      {
        name = "x11";
        desc = "Set graphics driver to X11";
      }
    ];
    check = ''
      case "$OPTION_VALUE" in
        default) graphics="";;
        x11)     graphics='x11';;
        wayland) graphics='wayland,x11';;
        mac)     graphics='mac,x11';;
      esac

      awk -v expected="$graphics" '
        ${awkCaptureInside ''Software\Wine\Drivers''}
        ${awkCaptureMatchString "Graphics"}
        ${awkExpect "Graphics"}
      ' "$HKCU"
    '';
  };

  gsm = mkIntBetween 0 3 {
    name = "MaxShaderModelGS";
    check = ''
      awk -v expected="$OPTION_VALUE" '
        ${awkCaptureInside ''Software\Wine\Direct3D''}
        ${awkCaptureMatchString "MaxShaderModelGS"}
        ${awkExpect "MaxShaderModelGS"}
      ' "$HKCU"
    '';
  };

  mackeyremap = mkEnum {
    values = [
      {
        name = "none";
        desc = "Do not remap keys for the Mac native driver (default)";
      }
      {
        name = "left";
        desc = "Enable mapping of left opt->alt and cmd->ctrl keys for the Mac native driver";
      }
      {
        name = "both";
        desc = "Enable mapping opt->alt and cmd->ctrl keys for the Mac native driver";
      }
    ];
    check = ''
      case "$OPTION_VALUE" in
        none) left=n; right=n;;
        left) left=y; right=n;;
        both) left=y; right=y;;
      esac

      awk -v left=$left -v right=$right '
        ${awkCaptureInside ''Software\Wine\Mac Driver''}
        ${awkCaptureMatchString "LeftCommandIsCtrl"}
        ${awkCaptureMatchString "LeftOptionIsAlt"}
        ${awkCaptureMatchString "RightCommandIsCtrl"}
        ${awkCaptureMatchString "RightOptionIsAlt"}
        ${awkExpectEqual [
          [
            "LeftCommandIsCtrl"
            "left"
          ]
          [
            "LeftOptionIsAlt"
            "left"
          ]
          [
            "RightCommandIsCtrl"
            "right"
          ]
          [
            "RightOptionIsAlt"
            "right"
          ]
        ]}
      ' "$HKCU"
    '';
  };

  mimeassoc = mkOnOff {
    on = "Enable exporting MIME-type file associations to the native desktop (default)";
    off = "Disable exporting MIME-type file associations to the native desktop";
    check = ''
      case "$OPTION_VALUE" in
        on)  mimeassoc=Y;;
        off) mimeassoc=N;;
      esac

      awk -v expected=$mimeassoc '
        ${awkCaptureInside ''Software\Wine\FileOpenAssociations''}
        ${awkCaptureMatchString "Enable"}
        ${awkExpect "Enable"}
      ' "$HKCU"
    '';
  };

  mwo = mkEnableDisable {
    enabled = "Set DirectInput MouseWarpOverride to enabled (default)";
    disable = "Set DirectInput MouseWarpOverride to disable";
    force = "Set DirectInput MouseWarpOverride to force (needed by some games)";
    check = ''
      awk -v expected="$OPTION_VALUE" '
        ${awkCaptureInside ''Software\Wine\DirectInput''}
        ${awkCaptureMatchString "MouseWarpOverride"}
        ${awkExpect "MouseWarpOverride"}
      ' "$HKCU"
    '';
  };

  orm = mkEnum {
    values = [
      {
        name = "backbuffer";
        desc = "Set OffscreenRenderingMode=backbuffer";
      }
      {
        name = "fbo";
        desc = "Set OffscreenRenderingMode=fbo (default)";
      }
    ];
    check = ''
      awk -v expected="$OPTION_VALUE" '
        ${awkCaptureInside ''Software\Wine\Direct3D''}
        ${awkCaptureMatchString "OffscreenRenderingMode"}
        ${awkExpect "OffscreenRenderingMode"}
      ' "$HKCU"
    '';
  };

  psm = mkIntBetween 0 3 {
    name = "MaxShaderModelPS";
    check = ''
      awk -v expected="$OPTION_VALUE" '
        ${awkCaptureInside ''Software\Wine\Direct3D''}
        ${awkCaptureMatchString "MaxShaderModelPS"}
        ${awkExpect "MaxShaderModelPS"}
      ' "$HKCU"
    '';
  };

  renderer = mkEnum {
    values = [
      {
        name = "gdi";
        desc = "Set renderer to gdi";
      }
      {
        name = "gl";
        desc = "Set renderer to gl";
      }
      {
        name = "no3d";
        desc = "Set renderer to no3d";
      }
      {
        name = "vulkan";
        desc = "Set renderer to vulkan";
      }
    ];
    check = ''
      awk -v expected="$OPTION_VALUE" '
        ${awkCaptureInside ''Software\Wine\Direct3D''}
        ${awkCaptureMatchString "renderer"}
        ${awkExpect "renderer"}
      ' "$HKCU"
    '';
  };

  rtlm = mkEnum {
    values = [
      {
        name = "auto";
        desc = "Set RenderTargetLockMode to auto (default)";
      }
      {
        name = "disabled";
        desc = "Set RenderTargetLockMode to disabled";
      }
      {
        name = "readdraw";
        desc = "Set RenderTargetLockMode to readdraw";
      }
      {
        name = "readtex";
        desc = "Set RenderTargetLockMode to readtex";
      }
      {
        name = "texdraw";
        desc = "Set RenderTargetLockMode to texdraw";
      }
      {
        name = "textex";
        desc = "Set RenderTargetLockMode to textex";
      }
    ];
    check = ''
      awk -v expected="$OPTION_VALUE" '
        ${awkCaptureInside ''Software\Wine\Direct3D''}
        ${awkCaptureMatchString "RenderTargetLockMode"}
        ${awkExpect "RenderTargetLockMode"}
      ' "$HKCU"
    '';
  };

  shader_backend = mkEnum {
    values = [
      {
        name = "arb";
        desc = "Set shader_backend to arb";
      }
      {
        name = "glsl";
        desc = "Set shader_backend to glsl";
      }
      {
        name = "none";
        desc = "Set shader_backend to none";
      }
    ];
    check = ''
      awk -v expected="$OPTION_VALUE" '
        ${awkCaptureInside ''Software\Wine\Direct3D''}
        ${awkCaptureMatchString "shader_backend"}
        ${awkExpect "shader_backend"}
      ' "$HKCU"
    '';
  };

  sound = mkEnum {
    values = [
      {
        name = "alsa";
        desc = "Set sound driver to ALSA";
      }
      {
        name = "pulse";
        desc = "Set sound driver to PulseAudio";
      }
      {
        name = "coreaudio";
        desc = "Set sound driver to Mac CoreAudio";
      }
      {
        name = "oss";
        desc = "Set sound driver to OSS";
      }
      {
        name = "disabled";
        desc = "Set sound driver to disabled";
      }
    ];
    check = ''
      awk -v expected="$OPTION_VALUE" '
        ${awkCaptureInside ''Software\Wine\Drivers''}
        ${awkCaptureMatchString "Audio"}
        ${awkExpect "Audio"}
      ' "$HKCU"
    '';
  };

  ssm = mkEnableDisable {
    enabled = "Enable Struct Shader Math";
    disabled = "Disable Struct Shader Math (default)";
    check = ''
      case "$OPTION_VALUE" in
        enabled)  ssm=1
        disabled) ssm=0
      esac

      awk -v expected=$ssm '
        ${awkCaptureInside ''Software\Wine\Direct3D''}
        ${awkCaptureMatchDword "strict_shader_math"}
        ${awkExpect "strict_shader_math"}
      ' "$HKCU"
    '';
  };

  theme = mkEnum {
    values = [
      {
        name = "light";
        desc = "Use default Wine theme (light) for the WINEPREFIX";
      }
      {
        name = "dark";
        desc = "Use dark theme for the WINEPREFIX";
      }
    ];
    # Safe to assume theme won't be touched by user outside module so we can check for only one variable
    check = ''
      case "$OPTION_VALUE" in
        dark)  theme=00000000;;
        light) theme=00000001;;
      esac

      awk -v expected=$theme '
        ${awkCaptureInside ''Software\Microsoft\Windows\CurrentVersion\Themes\Personalize''}
        ${awkCaptureMatchDword "SystemUsesLightTheme"}
        ${awkExpect "SystemUsesLightTheme"}
      ' "$HKCU"
    '';
  };

  useegl = mkYesNo {
    yes = "Enable EGL (default)";
    no = "Disable EGL, use GLX instead";
    check = ''
      case "$OPTION_VALUE" in
        y) useegl=Y;;
        n) useegl=N;;
      esac

      awk -v expected=$useegl '
        ${awkCaptureInside ''Software\Wine\X11 Driver''}
        ${awkCaptureMatchString "UseEGL"}
        ${awkExpect "UseEGL"}
      ' "$HKCU"
    '';
  };

  usetakefocus = mkYesNo {
    yes = "Enable UseTakeFocus";
    no = "Disable UseTakeFocus (default)";
    check = ''
      case "$OPTION_VALUE" in
        y) usetakefocus=Y;;
        n) usetakefocus=N;;
      esac

      awk -v expected=$usetakefocus '
        ${awkCaptureInside ''Software\Wine\X11 Driver''}
        ${awkCaptureMatchString "UseTakeFocus"}
        ${awkExpect "UseTakeFocus"}
      ' "$HKCU"
    '';
  };

  vd = {
    option = mkOption {
      type =
        with types;
        nullOr (oneOf [
          (strMatching "off")
          (strMatching "disabled")
          (strMatching "[1-9]*x[1-9]*")
        ]);
      description = ''
        Use a virtual desktop of size <width>x<height>.
        Set to off or disabled to disable.
      '';
      example = "1920x1080";
      default = null;
    };
    # FIXME: The option works, but I couldn't find a proper way to test it.
    # Code in winetricks sets some registry values, but nothing shows up when parsing the destination file.
    check = ''
      true
    '';
  };

  videomemorysisze = {
    option = mkOption {
      type = with types; nullOr (either (strMatching "default") ints.positive);
      description = ''
        Inform Wine of your VRAM in MB.
        Use "default" to let Wine detect it automatically. (default)
      '';
      example = 2048;
      apply = value: if builtins.isNull value then value else builtins.toString value;
      default = null;
    };
    check = ''
      case "$OPTION_VALUE" in
        default) ! grep -qF "VideoMemorySize" "$HKCU";;
        *)
          awk -v expected="$OPTION_VALUE" '
            ${awkCaptureInside ''Software\Wine\Direct3D''}
            ${awkCaptureMatchString "VideoMemorySize"}
            ${awkExpect "VideoMemorySize"}
          ' "$HKCU"
          ;;
      esac
    '';
  };

  vsm = mkIntBetween 0 3 {
    name = "MaxShaderModelVS";
    check = ''
      awk -v expected="$OPTION_VALUE" '
        ${awkCaptureInside ''Software\Wine\Direct3D''}
        ${awkCaptureMatchString "MaxShaderModelVS"}
        ${awkExpect "MaxShaderModelVS"}
      ' "$HKCU"
    '';
  };

  windowmanagerdecorated = mkYesNo {
    yes = "Allow the window manager to decorate windows (default)";
    no = "Prevent the window manager from decorating windows";
    check = ''
      awk -v expected="$OPTION_VALUE" '
        ${awkCaptureInside ''Software\Wine\X11 Driver''}
        ${awkCaptureMatchString "Decorated"}
        ${awkExpect "Decorated"}
      ' "$HKCU"
    '';
  };

  windowmanagermanaged = mkYesNo {
    yes = "Allow the window manager to control windows (default)";
    no = "Prevent the window manager from controlling windows";
    check = ''
      awk -v expected="$OPTION_VALUE" '
        ${awkCaptureInside ''Software\Wine\X11 Driver''}
        ${awkCaptureMatchString "Managed"}
        ${awkExpect "Managed"}
      ' "$HKCU"
    '';
  };

  winver = mkEnum {
    values = [
      {
        name = "default";
        desc = "Set Windows version to default (win7)";
      }
      {
        name = "winme";
        desc = "Set Windows version to Windows ME";
      }
      {
        name = "nt351";
        desc = "Set Windows version to Windows NT 3.51";
      }
      {
        name = "nt40";
        desc = "Set Windows version to Windows NT 4.0";
      }
      {
        name = "win20";
        desc = "Set Windows version to Windows 2.0";
      }
      {
        name = "win30";
        desc = "Set Windows version to Windows 3.0";
      }
      {
        name = "win31";
        desc = "Set Windows version to Windows 3.1";
      }
      {
        name = "win95";
        desc = "Set Windows version to Windows 95";
      }
      {
        name = "win98";
        desc = "Set Windows version to Windows 98";
      }
      {
        name = "win2k";
        desc = "Set Windows version to Windows 2000";
      }
      {
        name = "win2k3";
        desc = "Set Windows version to Windows 2003";
      }
      {
        name = "win2k8";
        desc = "Set Windows version to Windows 2008";
      }
      {
        name = "win2k8r2";
        desc = "Set Windows version to Windows 2008 R2";
      }
      {
        name = "winxp";
        desc = "Set Windows version to Windows XP";
      }
      {
        name = "vista";
        desc = "Set Windows version to Windows Vista"; # Why would you?
      }
      {
        name = "win7";
        desc = "Set Windows version to Windows 7"; # winetricks listing shows this as default but code says it's win10
      }
      {
        name = "win8";
        desc = "Set Windows version to Windows 8";
      }
      {
        name = "win81";
        desc = "Set Windows version to Windows 8.1";
      }
      {
        name = "win10";
        desc = "Set Windows version to Windows 10 (default)";
      }
      {
        name = "win11";
        desc = "Set Windows version to Windows 11";
      }
    ];
    check = ''
      winver=$(wine winecfg /v 2>&1 | tail -n1 | tr -d '\n\r')

      if [[ "$target" =~ "default" ]]; then
        ! [[ "$winver" =~ "win10" ]]
      elif [[ $target =~ "winxp" ]]; then
        ! [[ "$winver" =~ "winxp" || "$winver" =~ "winxp64" ]]
      else
        case "$target" in
          win2k3)   target="win2003";;
          win2k8)   target="win2008";;
          win2k8r2) target="win2008r2";;
        esac
        ! [[ "$winver" =~ "$target" ]]
      fi
    '';
  };
}
