{
  description = "AI Agent Development Environment with uv ";

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
            uv #使用uv管理python解释器版本及python包
            jupyter
            nodejs_22
            pnpm_10
            texlive.combined.scheme-full #latex
            jq
 
            cargo
            rustc
            rustup

            elan #Lean 4 版本管理器（含lean4+lake）

            go
          ];

          env = {
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

