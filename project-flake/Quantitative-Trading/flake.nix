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
        
        # 定义需要的系统级动态库
        # 这些库是 pandas, numpy, lxml 等 wheel 包在运行时需要的
        libraryPath = pkgs.lib.makeLibraryPath [
          pkgs.stdenv.cc.cc.lib # libstdc++.so.6 (必须)
          pkgs.zlib             # libz.so (常见依赖)
          pkgs.glib             # 某些绘图库依赖
          pkgs.libxml2          # lxml (akshare依赖) 需要
          pkgs.libxslt          # lxml 需要
        ];
      in {
        devShells.default = pkgs.mkShell {
          # 1. 提供的工具链
          packages = with pkgs; [
            python311
            uv
            
            # Haskell (保留你原有的)
            ghc
            cabal-install
          ];

          # 2. 环境变量设置
          shellHook = ''
            # 关键：设置动态库路径，让 uv 下载的 wheel 能找到系统库
            export LD_LIBRARY_PATH=${libraryPath}:$LD_LIBRARY_PATH
            
            # 可选：告诉 uv 使用当前的 Python 版本
            export UV_PYTHON=${pkgs.python311}/bin/python
            
            echo "🚀 量化环境已启动 (Nix + uv)"
            echo "   - 初始化项目: uv init"
            echo "   - 添加依赖:   uv add tushare akshare pandas jupyter"
            echo "   - 启动服务:   uv run jupyter notebook"
          '';
        };
      }
    );
}
