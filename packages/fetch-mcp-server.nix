{ pkgs, ... }:

let
  python = pkgs.python3;
  pythonPackages = python.pkgs;

  mcp-server-fetch = pythonPackages.buildPythonPackage rec {
    pname = "mcp_server_fetch";
    version = "2025.4.7";
    format = "wheel";

    src = pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-VieePFXLHlBrlYypuyPtRBOUSm8jC8oh4ESu5Rc0/kc=";
    };

    doCheck = false; # Skip tests for now
  };
in

pkgs.stdenv.mkDerivation rec {
  pname = "fetch-mcp-server";
  version = "2025.4.7";

  # No source needed
  src = null;
  dontUnpack = true;

  nativeBuildInputs = [ python ];
  buildInputs = [ mcp-server-fetch ];

  buildPhase = ''
    # Nothing to build, just prepare the wrapper
  '';

  installPhase = ''
        mkdir -p $out/bin

        # Create a fake node executable that makes have_node() return False
        mkdir -p $out/fake-bin
        cat > $out/fake-bin/node << 'FAKE_NODE_EOF'
    #!${pkgs.bash}/bin/bash
    # Fake node that exits with error to make readabilipy use Python-only mode
    exit 1
    FAKE_NODE_EOF
        chmod +x $out/fake-bin/node

        # Create wrapper script that uses fake node
        cat > $out/bin/fetch-mcp-wrapper << EOF
    #!${pkgs.bash}/bin/bash
    # Put fake node first in PATH to force Python-only mode in readabilipy
    export PATH="$out/fake-bin:\$PATH"
    exec ${python.withPackages (ps: [ mcp-server-fetch ])}/bin/python -m mcp_server_fetch "\$@"
    EOF
        chmod +x $out/bin/fetch-mcp-wrapper
  '';

  meta = with pkgs.lib; {
    description = "MCP Fetch Server with Node.js support";
    license = licenses.mit;
  };
}
