{
  description = "AI Code项目环境 (Nix + UV)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # 关键部分：定义 Python 扩展(C/C++)运行时需要的动态库
      # 因为 uv 下载的 wheel 包是预编译的，它们需要找到标准的 Linux 库
      libraryPath = pkgs.lib.makeLibraryPath [
        pkgs.stdenv.cc.cc.lib # libstdc++.so
        pkgs.zlib             # numpy/pillow 常用
        pkgs.glib             # 许多 python 库依赖
        pkgs.xorg.libX11      # matplotlib 绘图可能需要
        pkgs.libGL            # OpenGL 支持
      ];
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        # 1. 提供基础工具
        packages = with pkgs; [
          uv
          pnpm_9
          nodejs_22
          python313  # 只提供纯净的 Python 解释器
          
          # 如果将来某些包需要编译安装(非wheel)，可能需要这些构建工具
          pkg-config 
          gcc
        ];

        # 2. 设置环境变量，让非 Nix 构建的二进制文件能运行
        env = {
          # 强制 LD_LIBRARY_PATH，解决 "ImportError: libstdc++.so.6: cannot open shared object file"
          LD_LIBRARY_PATH = libraryPath;
          
          # 可选：告诉 uv 优先使用 Nix 提供的 Python，而不是自己下载
          # 这样可以节省空间并利用 Nix 的缓存
          UV_PYTHON_DOWNLOADS = "never";
          UV_PYTHON = "${pkgs.python313}/bin/python";
        };

        shellHook = ''
          # --- Node.js 部分 (保持你原有的逻辑) ---
          if [ ! -d "pnpm-packages/node_modules" ] && [ -f "pnpm-packages/package.json" ]; then
            echo "正在下载npm包..."
            (cd pnpm-packages && pnpm install)
          fi
          export PATH="$PWD/pnpm-packages/node_modules/.bin:$PATH"

          # --- Python/UV 部分 ---
          # 1. 如果没有 pyproject.toml，初始化它
          if [ ! -f "pyproject.toml" ]; then
            echo "未检测到 pyproject.toml，正在初始化 uv 项目..."
            uv init
          fi

          # 2. 创建/同步虚拟环境
          # 如果 .venv 不存在，'uv sync' 会自动创建
          echo "正在同步 Python 环境 (uv)..."
          uv sync

          # 3. 激活虚拟环境
          # 这一步很关键，让 shell 里的 `python` 指向 `.venv/bin/python`
          source .venv/bin/activate

          echo "环境就绪 (Python 3.13 + UV + Node 22 + pnpm_9)"
        '';
      };
    };
}
