# Home Manager configuration
# This module defines user-level configuration shared across all hosts.
# Platform-specific settings are conditionally imported based on the target system.

# Platform-Specific Import Options Explained:
#
# 1. Self-guarding modules (lib.mkIf inside the module):
#    Each platform-specific module imports unconditionally and uses `config = lib.mkIf pkgs.stdenv.isDarwin { ... }`
#    to guard its contents. This is simple but requires all options referenced to exist on all platforms.
#
# 2. Conditional imports via specialArgs (CURRENT APPROACH):
#    Pass `isDarwin` and `isLinux` flags through extraSpecialArgs in lib/default.nix.
#    Use these plain booleans (not derived from pkgs) to conditionally import modules.
#    This avoids infinite recursion because the flags are passed from outside the module system.
#
# 3. Separate entrypoints per platform:
#    Create entirely separate default.nix files for Darwin and Linux (e.g., home/darwin-default.nix,
#    home/linux-default.nix). Each entrypoint imports the shared modules plus platform-specific ones.
#    No conditional logic needed, but requires maintaining multiple entrypoint files.

{
  lib,
  isDarwin,
  isLinux,
  ...
}:

{
  imports = [
    ./colors
    ./fonts.nix
    ./git.nix
    ./opencode
    ./tmux.nix
    ./tools.nix
    ./vim
    ./zed
    ./zsh.nix
    ./shell.nix
  ]
  ++ lib.optionals isDarwin [ ./darwin.nix ]
  ++ lib.optionals isLinux [ ./linux.nix ];

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  xdg = {
    enable = true;
  };

  # Prefer XDG directories for consistency with the rest of the configuration
  home.preferXdgDirectories = true;
}
