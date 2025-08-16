{ pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "fetch-mcp-server";
  version = "2025.4.7";

  # No source needed, we'll install from PyPI
  src = null;
  dontUnpack = true;

  nativeBuildInputs = with pkgs; [ uv python3 ];

  buildPhase = ''
    # Set up uv cache directory in the build environment
    export UV_CACHE_DIR=$TMPDIR/uv-cache
    export UV_NO_SYNC=1

    # Create a virtual environment and install mcp-server-fetch
    uv venv venv
    source venv/bin/activate
    uv pip install mcp-server-fetch==${version}

    # No Node.js dependencies - use Python-only HTML processing
  '';

  installPhase = ''
    mkdir -p $out/bin

    # Copy the virtual environment first
    cp -r venv $out/

    # Create a fake node executable that makes have_node() return False
    mkdir -p $out/fake-bin
    cat > $out/fake-bin/node << 'FAKE_NODE_EOF'
#!/usr/bin/env bash
# Fake node that exits with error to make readabilipy use Python-only mode
exit 1
FAKE_NODE_EOF
    chmod +x $out/fake-bin/node

    # Create wrapper script that uses fake node
    cat > $out/bin/fetch-mcp-wrapper << EOF
#!/usr/bin/env bash
# Put fake node first in PATH to force Python-only mode in readabilipy
export PATH="$out/fake-bin:\$PATH"
exec $out/venv/bin/python -m mcp_server_fetch "\$@"
EOF
    chmod +x $out/bin/fetch-mcp-wrapper
  '';

  meta = with pkgs.lib; {
    description = "MCP Fetch Server with Node.js support";
    license = licenses.mit;
  };
}
