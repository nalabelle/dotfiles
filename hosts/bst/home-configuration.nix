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
}
