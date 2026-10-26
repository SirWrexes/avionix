{
  stdenvNoCC,
  fetchzip,
  python3,

  settings ? { },
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "er-seamless-coop";
  version = "2.0.1";

  src = fetchzip {
    url = "https://github.com/yuiamoroll/EldenRingSeamlessCoopRelease/releases/download/v${finalAttrs.version}/Seamless.Co-op.v${finalAttrs.version}.zip";
    hash = "sha256-KdhtaToI+TK721PsPhYsPtDFMu9bsMWpl2+yg+jfDBc=";
    stripRoot = false;
  };

  settingsJson = builtins.toJSON settings;
  passAsFile = [ "settingsJson" ];

  nativeBuildInputs = [ python3 ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -a SeamlessCoop/* $out

    pushd $out
    python3 - << 'EOF'
    import os
    import json
    import configparser
    import sys

    with open(os.environ['settingsJsonPath']) as f:
      user_settings = json.load(f)

    config = configparser.ConfigParser()
    config.optionxform = str
    config.read('${finalAttrs.passthru.configFilePath}')

    known_keys = { key for section in config.sections() for key in config[section] }

    for key in user_settings:
      if key not in known_keys:
        print(f"WARNING: Unknown setting '{key}' found in settings override", file=sys.stderr)

    for section in config.sections():
      for key in config[section]:
        if key in user_settings:
          config[section][key] = str(user_settings[key])

    with open('${finalAttrs.passthru.configFilePath}', 'w') as f:
      config.write(f)
    EOF
    popd

    runHook postInstall
  '';

  meta = {
    description = "Seamless Co-op mod for Elden Ring";
    homepage = "https://www.nexusmods.com/eldenring/mods/510";
    changelog = "https://www.nexusmods.com/eldenring/mods/510?tab=logs";
    platforms = [ "x86_64-linux" ];
  };

  passthru = {
    nativeDllPath = "ersc.dll";
    configFilePath = "ersc_settings.ini";
  };
})
