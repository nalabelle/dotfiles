{ pkgs, inputs, lib, ... }: {
  programs.git = {
    extraConfig = {
      user.signingkey = lib.mkForce
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIRve0sisbmh3zDSJyWqPhDEbPeODk/K9YiIHnZmDv7Z";
    };
  };

  home.packages = with pkgs; [ awscli2 duckdb claude-code ];

  # BST-specific MCP server configurations
  vscode.hostMcpServers = {
    duck = {
      command = "nix";
      args = [
        "shell"
        "nixpkgs#uv"
        "--command"
        "uvx"
        "--"
        "mcp-server-motherduck"
        "--db-path"
        ":memory:"
      ];
      env = {
        HOME = "/Users/nalabelle/.mcp";
        AWS_PROFILE = "readonly";
      };
    };
  };

  # Graphite completion (co-located with graphite installation via homebrew)
  programs.zsh.initContent = lib.mkAfter ''
    if command -v gt > /dev/null 2>&1; then
      eval "$(gt completion)"
    fi
  '';
}
