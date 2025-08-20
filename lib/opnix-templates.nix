{
  config,
  lib,
  pkgs,
  ...
}:
# opnix Template System
#
# This module extends opnix with a template system for managing configuration files
# that need secret injection. It provides build-time safety by using placeholders
# that are replaced with actual secrets during Home Manager activation.
#
# ## Key Features
# - Build-time safety: Templates contain placeholders, never actual secrets
# - Runtime substitution: Secrets injected during Home Manager activation
# - Cross-platform: Automatic group assignment (macOS: staff, NixOS: users)
# - Dependency ordering: Templates processed after secret retrieval
# - Auto-generated placeholders: Uses SHA256 hashes for consistent substitution
#
# ## Usage Example
# ```nix
# programs.onepassword-secrets = {
#   enable = true;
#
#   # Define secrets with cross-platform group support
#   secrets.githubToken = {
#     reference = "op://Applications/GitHub/password";
#     path = ".config/secrets/github-token";
#     mode = "0600";
#     group = if pkgs.stdenv.isDarwin then "staff" else "users";
#   };
#
#   # Define templates that use secrets
#   templates.vscode-mcp = {
#     content = ''
#       {
#         "mcpServers": {
#           "github": {
#             "env": {
#               "GITHUB_TOKEN": "${config.programs.onepassword-secrets.placeholder.githubToken}"
#             }
#           }
#         }
#       }
#     '';
#     path = "${config.home.homeDirectory}/.vscode/User/settings.json";
#     mode = "0600";
#   };
# };
# ```
#
# ## Architecture
# 1. Template files generated at ~/.config/opnix-templates/ with placeholders
# 2. Home Manager activation scripts replace placeholders with real secrets
# 3. Final configuration files created with actual secret values
# 4. Placeholder format: {{ SHA256_HASH_OF_SECRET_NAME }}
#
# ## Cross-Platform Compatibility
# Always use conditional group assignment for secrets:
# - macOS: group = "staff" (users belong to staff group)
# - NixOS: group = "users" (standard Linux user group)

let
  inherit (lib)
    mkOption
    types
    mapAttrs
    mapAttrs'
    concatStringsSep
    mkIf
    nameValuePair
    ;
  cfg = config.programs.onepassword-secrets;
  templateType = types.submodule {
    options = {
      content = mkOption {
        type = types.str;
        description = "Template content with placeholder references";
      };
      path = mkOption {
        type = types.str;
        description = "Target path for rendered template";
      };
      mode = mkOption {
        type = types.str;
        default = "0600";
        description = "File permissions";
      };
      trim = mkOption {
        type = types.bool;
        default = true;
        description = "Trim whitespace from secrets";
      };
    };
  };
in
{
  options.programs.onepassword-secrets = {
    templates = mkOption {
      type = types.attrsOf templateType;
      default = { };
    };
    placeholder = mkOption {
      type = types.attrsOf types.str;
      default = { };
    };
  };
  config = mkIf (cfg.templates != { }) {
    # Existing placeholder generation
    programs.onepassword-secrets.placeholder = mapAttrs (
      name: _: "{{ ${builtins.hashString "sha256" name} }}"
    ) cfg.secrets;

    # NEW: Template file generation in home directory
    home.file = lib.mapAttrs' (
      name: template:
      lib.nameValuePair ".config/opnix-templates/${name}.json" {
        text = template.content; # Contains placeholders, not secrets
      }
    ) cfg.templates;

    # NEW: Activation scripts for runtime substitution
    home.activation = lib.mapAttrs' (
      name: template:
      lib.nameValuePair "opnix-template-${name}" (
        lib.hm.dag.entryAfter [ "retrieveOpnixSecrets" ] ''
          TEMPLATE_FILE="$HOME/.config/opnix-templates/${name}.json"
          TARGET_FILE="${template.path}"

          # Ensure target directory exists
          mkdir -p "$(dirname "$TARGET_FILE")"

          # Perform placeholder substitution for each secret
          # This will need to iterate over secrets and substitute each one
          cp "$TEMPLATE_FILE" "$TARGET_FILE.tmp"
          ${lib.concatStringsSep "\n" (
            lib.mapAttrsToList (secretName: secretPath: ''
              PLACEHOLDER_HASH="${builtins.hashString "sha256" secretName}"
              ${pkgs.gnused}/bin/sed -i "s|{{ $PLACEHOLDER_HASH }}|$(cat "${secretPath}")|g" "$TARGET_FILE.tmp"
            '') cfg.secretPaths
          )}

          # Move to final location and set permissions
          mv "$TARGET_FILE.tmp" "$TARGET_FILE"
          chmod ${template.mode} "$TARGET_FILE"
        ''
      )
    ) cfg.templates;
  };
}
