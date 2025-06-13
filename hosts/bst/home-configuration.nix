{ pkgs, inputs, ... }:
let
  extraNodePackages = import ../../node {
    inherit pkgs;
    nodejs = pkgs.nodejs_22;
  };
in {
  home.packages = with pkgs; [
    awscli2
    duckdb
    extraNodePackages."@anthropic-ai/claude-code"
  ];

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
}
