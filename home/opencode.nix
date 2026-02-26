{
  pkgs,
  ...
}:
{
  # OpenCode configuration file (generated to resolve nix binary path per-platform)
  home.file.".config/opencode/opencode.json" = {
    text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      permission = {
        edit = "ask";
        bash = "ask";
        webfetch = "ask";
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
  };
}
