{
  fetchFromGitHub,
  stdenvNoCC,
  coreutils,
}:
stdenvNoCC.mkDerivation {
  name = "genwipe";

  src = fetchFromGitHub {
    owner = "AndyCrowd";
    repo = "genwipe.sh";
    rev = "master";
    hash = "sha256-L21ZTlznvUUkixNM04+5tqry+NK6P9MMyFLRsdyMu+s=";
  };

  buildInputs = [ coreutils ];

  installPhase = ''
    mkdir -p "$out/bin"
    install -m +r-w+x "$src/genwipe.sh" "$out/bin/genwipe"
  '';
}
