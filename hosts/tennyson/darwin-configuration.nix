{ pkgs, inputs, hostname, username, ... }: {
  homebrew = {
    casks = [
      "android-ndk"
      "android-platform-tools"
      "android-studio"
      "balenaetcher"
      "calibre"
      "foobar2000"
      "kopiaui"
      "mountain-duck"
      "obsidian"
      "onlyoffice"
      "protonvpn"
      "zed"
    ];
  };
}
