{
  pkgs,
  ...
}:
let
  opencodeConfig = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    permission = {
      bash = {
        # Destructive file operations
        "rm *" = "ask";
        "rmdir *" = "ask";
        "shred *" = "ask";
        "wipe *" = "ask";
        # Overwriting/truncating
        "dd *" = "ask";
        "truncate *" = "ask";
        # Moving/renaming (can overwrite without -i)
        "mv *" = "ask";
        # Permission/ownership changes
        "chmod *" = "ask";
        "chown *" = "ask";
        "chgrp *" = "ask";
        # Package management (system-wide changes)
        "apt *" = "ask";
        "apt-get *" = "ask";
        "dpkg *" = "ask";
        "rpm *" = "ask";
        "yum *" = "ask";
        "dnf *" = "ask";
        "pacman *" = "ask";
        "brew *" = "ask";
        # Systemd / service control
        "systemctl *" = "ask";
        "service *" = "ask";
        # Network
        "curl *" = "ask";
        "wget *" = "ask";
        "ssh *" = "ask";
        "scp *" = "ask";
        "rsync *" = "ask";
        "nc *" = "ask";
        "ncat *" = "ask";
        # Process killing
        "kill *" = "ask";
        "killall *" = "ask";
        "pkill *" = "ask";
        # Disk / filesystem
        "mkfs *" = "ask";
        "mount *" = "ask";
        "umount *" = "ask";
        "fdisk *" = "ask";
        "parted *" = "ask";
        # Crontab / scheduled tasks
        "crontab *" = "ask";
        # Sudo / privilege escalation
        "sudo *" = "ask";
        "su *" = "ask";
        "doas *" = "ask";
        # Environment / shell config
        "export *" = "ask";
        "source *" = "ask";
        ". *" = "ask";
      };
    };
    mcp = {
      github = {
        enabled = true;
        type = "local";
        command = [
          "${pkgs.nix}/bin/nix"
          "shell"
          "nixpkgs#nodejs"
          "--command"
          "npx"
          "-y"
          "@modelcontextprotocol/server-github"
        ];
        environment = {
          GITHUB_PERSONAL_ACCESS_TOKEN = "{env:GITHUB_MCP_TOKEN}";
          GITHUB_TOOLSETS = "";
          GITHUB_READ_ONLY = "1";
        };
      };
      nixos = {
        enabled = true;
        type = "local";
        command = [
          "${pkgs.nix}/bin/nix"
          "run"
          "github:utensils/mcp-nixos"
          "--"
        ];
      };
      context7 = {
        enabled = true;
        type = "local";
        command = [
          "${pkgs.nix}/bin/nix"
          "shell"
          "nixpkgs#nodejs"
          "--command"
          "npx"
          "-y"
          "@upstash/context7-mcp"
        ];
        environment = {
          DEFAULT_MINIMUM_TOKENS = "";
        };
      };
    };
  };
in
{
  # OpenCode configuration (generated to resolve nix binary path per-platform)
  home.file.".config/opencode/opencode.json".text = opencodeConfig;
  # KiloCode uses the same MCP server configuration
  home.file.".config/kilo/opencode.json".text = opencodeConfig;
}
