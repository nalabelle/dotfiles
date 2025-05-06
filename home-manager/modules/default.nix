{ lib, ... }:

{
  # Import all modules and make them available
  imports = [ ./base.nix ./shell ./terminal ./dev ./macos ];
}
