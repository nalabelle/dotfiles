{ pkgs, inputs, hostname, username, ... }: {
  homebrew = {
    casks = [
      "android-ndk"
      "android-platform-tools"
      "android-studio"
      "calibre"
      "kopiaui"
      "mountain-duck"
      "obsidian"
      "onlyoffice"
      "protonvpn"
      "zed"
    ];
  };
}
