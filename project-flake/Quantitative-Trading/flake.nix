{
  description = "量化交易学习 Nix 环境 (Powered by uv)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            uv #管理python解释器及python包
            ghc
            cabal-install
            nodejs_22
            # 添加 pkg-config 有助于某些 python 包编译找到库
            pkg-config
          ];

          env = {
            # nix-ld 读取这个
          NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
              pkgs.stdenv.cc.cc.lib  # libstdc++.so.6
              pkgs.zlib              # libz.so
              pkgs.libxml2           # lxml
              pkgs.libxslt           # lxml
            ];
          };

          shellHook = ''
            source .venv/bin/activate
            echo "🚀 量化环境已启动 (Nix + uv)"
          '';
        };
      }
    );
}

