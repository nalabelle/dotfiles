{ pkgs, ... }:

pkgs.buildNpmPackage rec {
  pname = "fetch-mcp-server";
  version = "2025.4.7";

  src = ./fetch-mcp-server;

  npmDepsHash = "sha256-rLb/VMNPezr03IwT8f2ubLP8qVhNlc3t18G2/vmAwZ8=";

  nativeBuildInputs = with pkgs; [
    nodejs
    typescript
  ];

  buildPhase = ''
    runHook preBuild
    npm run build
    runHook postBuild
  '';

  installPhase = ''
        runHook preInstall

        mkdir -p $out/lib/node_modules/fetch-mcp-server
        cp -r dist package.json node_modules $out/lib/node_modules/fetch-mcp-server/

        mkdir -p $out/bin
        cat > $out/bin/fetch-mcp-server << EOF
    #!/usr/bin/env bash
    exec ${pkgs.nodejs}/bin/node $out/lib/node_modules/fetch-mcp-server/dist/index.js "\$@"
    EOF
        chmod +x $out/bin/fetch-mcp-server

        runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "A Model Context Protocol server providing tools to fetch and convert web content for usage by LLMs";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
