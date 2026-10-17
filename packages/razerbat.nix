{
  lib,
  fetchFromGitHub,

  rustPlatform,
  pkg-config,

  rustc,
  cargo,
  dbus,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "razerbat";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "Zenardi";
    repo = "razerbat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4v50cDa19LOQcyyc2dadnk1EnrEvtuvjNuZFb1engc8=";
  };

  cargoHash = "sha256-3urBJPEWZ7bgyOJjhf47qQ4uyC9Sc8G3MhcqinoonAA=";

  strictDeps = true;
  nativeBuildInputs = [
    rustc
    cargo
    rustPlatform.cargoBuildHook
    rustPlatform.cargoInstallHook
    pkg-config
  ];

  buildInputs = [ dbus ];

  postInstall = ''
    cp -r ./icons $out/bin/icons
  '';

  meta = {
    mainProgram = "razerbat";
    description = "Lightweight Razer battery indicator tray";
    homepage = "https://github.com/Zenardi/razerbat";
    downloadPage = "https://github.com/Zenardi/razerbat/releases/tag/v${finalAttrs.version}";
    changelog = finalAttrs.meta.downloadPage;
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
  };
})
