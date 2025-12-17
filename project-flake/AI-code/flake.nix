{
  description = "AI Code项目环境 (Nix + UV)";

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
          uv #管理python解释器及python包
          pnpm_9
          nodejs_22
          pkg-config
          gcc
        ];

        env = {
          # nix-ld 会读取这个（用于非 Nix 二进制）
          NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.stdenv.cc.cc.lib
            pkgs.zlib
            pkgs.glib
            pkgs.xorg.libX11
            pkgs.libGL
          ];
        };

        shellHook = ''
          if [ ! -f "pyproject.toml" ]; then
            echo "未检测到 pyproject.toml，正在初始化 uv 项目..."
            uv init
          fi

          echo "正在同步 Python 环境 (uv)..."
          uv sync
          source .venv/bin/activate

          echo "✅ 环境就绪"
        '';
      };
    };
}

