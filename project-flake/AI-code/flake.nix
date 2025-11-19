{
  description = "AI Code项目环境";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs_22
            python3
          ];

          shellHook = ''
            if [ ! -d "npm-pakages/node_modules" ] && [ -f "npm-pakages/package.json" ]; then
             echo "正在下载npm包"
             (cd npm-pakages && npm install)
            fi

            if [ -d "npm-pakages/node_modules" ] && [ -f "npm-pakages/package.json" ]; then
             echo "正在更新npm包"
             (cd npm-pakages && npm update)
            fi

            echo "环境就绪"
            export PATH="$HOME/AI/AI-code/npm-pakages/node_modules/.bin:$PATH" 
          '';
        };
      }
    );
}
