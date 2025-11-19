{
  description = "极简量化交易学习 Nix 环境";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # 核心 Python 环境
        pythonEnv = pkgs.python311.withPackages (ps: with ps; [
          pandas      
          numpy     
          yfinance   
          jupyter    
          matplotlib 
        ]);
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            pythonEnv

          # Haskell 基础工具链
            ghc
            cabal-install
          ];
          
          shellHook = ''
            echo "✅ 量化环境就绪！"
            echo "🚀 启动 Jupyter: jupyter lab"
            exec zsh #启动zsh
          '';
        };
      }
    );
}
