{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "kilocode-cli";
  version = "7.0.27";

  src = fetchurl {
    url = "https://registry.npmjs.org/@kilocode/cli-darwin-arm64/-/cli-darwin-arm64-${finalAttrs.version}.tgz";
    hash = "sha256-VQ7v+++nwMvQqg1o+vOSXIa6opjfTJUmybOIZgLO42g=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 package/bin/kilo $out/bin/kilo
    ln -s $out/bin/kilo $out/bin/kilocode
    runHook postInstall
  '';

  # Bun standalone executables append data after the binary;
  # fixup phases may corrupt this appended data.
  dontFixup = true;

  meta = {
    description = "Kilo Code CLI";
    homepage = "https://kilocode.ai/cli";
    license = lib.licenses.mit;
    mainProgram = "kilo";
    platforms = [ "aarch64-darwin" ];
  };
})
