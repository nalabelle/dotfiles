{
  lib,
  stdenv,
  unzip,
  fetchurl,
}:

# cleaner - prebuilt binary from GitHub release (v0.1.4), macOS arm64

stdenv.mkDerivation rec {
  pname = "cleaner";
  version = "0.2.0";

  src = fetchurl {
    url = "https://github.com/nalabelle/cleaner/releases/download/v${version}/cleaner-macos-arm64.zip";
    # SRI for asset SHA256: 60a8788a3b80991a1c488f2e01951fb8694bbfb91dea95229449e2aa04d66388
    sha256 = "sha256-eRa3QaC/VMR+gyLmJi9XP3zjbhCgbFi3bmEMrl6Vw9k=";
  };

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    runHook preUnpack
    unzip -q "$src"
    runHook postUnpack
  '';

  # Archive layout: a single top-level binary named "cleaner"
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    install -m 0755 "./cleaner-macos-arm64" "$out/bin/cleaner"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Cleaner - small command-line cleaning utility";
    longDescription = ''
      Installs the prebuilt macOS arm64 cleaner binary from the v${version} GitHub release.
    '';
    homepage = "https://github.com/nalabelle/cleaner";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "cleaner";
    maintainers = [ ];
  };
}
