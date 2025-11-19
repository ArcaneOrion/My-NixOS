{
  description = "AI Code项目环境";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nodejs_22
          python3
        ];

        shellHook = ''
          if [ ! -d "npm-pakages/node_modules" ] && [ -f "npm-pakages/package.json" ]; then
            echo "正在下载npm包"
            (cd npm-pakages && npm install)
          fi

          echo "环境就绪"
          export PATH="$PWD/npm-pakages/node_modules/.bin:$PATH"
          exit  #退出bash
        '';
      };
    };
}
