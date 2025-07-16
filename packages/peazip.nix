{ lib, stdenv, fetchurl, _7zz }:

stdenv.mkDerivation rec {
  pname = "peazip";
  version = "10.5.0";

  src = fetchurl {
    url =
      "https://github.com/peazip/PeaZip/releases/download/${version}/peazip-${version}.DARWIN.aarch64.dmg";
    sha256 = "1kvy77mfym1iahm8dx8glbg57aryjgqdvqfkpfgaxhw0arrhq4ps";
  };

  nativeBuildInputs = [ _7zz ];

  unpackPhase = ''
    runHook preUnpack

    # Extract the DMG using 7zz which can handle APFS filesystems
    7zz x $src

    runHook postUnpack
  '';

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -R peazip.app $out/Applications/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Free archive manager app for macOS";
    longDescription = ''
      PeaZip is an Open Source cross-platform free archive manager application,
      a freeware alternative to WinRar, WinZip and similar utilities, to create,
      open and extract 7z, rar, tar, zip files and many more archive formats.
    '';
    homepage = "https://peazip.github.io/";
    license = licenses.lgpl3Only;
    platforms = [ "aarch64-darwin" ];
    maintainers = [ ];
  };
}
