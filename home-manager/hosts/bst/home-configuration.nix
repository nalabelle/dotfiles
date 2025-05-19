{ pkgs, inputs, ... }:
let
  extraNodePackages = import ../../node {
    inherit pkgs system;
    nodejs = pkgs.nodejs_22;
  };
in {
  home.packages = with pkgs; [
    awscli2
    duckdb
    extraNodePackages."@anthropic-ai/claude-code"
  ];
}
