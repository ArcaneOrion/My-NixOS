{
  description = "AI Agent Development Environment with uv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        libs = with pkgs; [
          stdenv.cc.cc.lib
          zlib
          glib
          libGL
          libxml2
          libxslt
        ];
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            python311
            uv
            jupyter
            nodejs_22
          ];

          env = {
            UV_PYTHON = "${pkgs.python311}/bin/python";
            NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath libs;
          };

          shellHook = ''
            source .venv/bin/activate
            echo "🚀 AI Agent Dev Environment Loaded!"
          '';
        };
      }
    );
}

