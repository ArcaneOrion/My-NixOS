{
  description = "整合开发环境 (Haskell, Rust, Python with uv)";

  # inputs: 定义外部依赖项
  inputs = {
    # nixpkgs: Nix 官方软件包仓库，使用不稳定版本以获取最新工具
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # rust-overlay: 提供更灵活的 Rust 工具链版本选择
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  # outputs: 定义 flake 的输出
  outputs = { self, nixpkgs, rust-overlay }:
    let
      # 指定系统平台
      system = "x86_64-linux";
      
      # 导入 pkgs，并应用 rust 覆盖层
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ rust-overlay.overlays.default ];
      };

      # Haskell 配置: 包含 GHC 编译器和指定的 Haskell 库
      ghc = pkgs.haskellPackages.ghcWithPackages (hp: [
        hp.aeson    # JSON 处理库
        hp.text     # 高效文本处理库
        hp.async    # 异步编程支持
      ]);

      # Rust 运行时系统库: Rust GUI 开发 (winit, egui 等) 必需的动态库
      runtimeLibs = with pkgs; [
        wayland
        wayland-protocols
        libxkbcommon
        libGL
        vulkan-loader
        xorg.libX11
        xorg.libXcursor
        xorg.libXi
        xorg.libXrandr
        libdrm
        mesa
        openssl
        pkg-config
      ];

      # Rust 工具链: 使用 stable 最新版本，包含源码和 rust-analyzer
      rustToolchain = pkgs.rust-bin.stable.latest.default.override {
        extensions = [ "rust-src" "rust-analyzer" ];
      };

    in {
      # 开发环境外壳配置
      devShells.${system}.default = pkgs.mkShell {
        # nativeBuildInputs: 编译时需要的工具 (在主控机运行)
        nativeBuildInputs = [ pkgs.pkg-config ];

        # buildInputs: 运行时和开发时需要的包
        buildInputs = [
          # Haskell 工具
          ghc
          pkgs.haskell-language-server
          pkgs.ghcid

          # Rust 工具
          rustToolchain
          
          # Python 管理工具 (不再通过 Nix 安装 python 解释器)
          pkgs.uv

          # 运行时库整合
        ] ++ runtimeLibs;

        # shellHook: 进入环境时自动执行的脚本
        shellHook = ''
          # 修复 Rust GUI 程序找不到动态库的问题
          export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath runtimeLibs}:$LD_LIBRARY_PATH"
          
          # 强制 winit 使用 wayland 后端 (根据您的原配置)
          export WINIT_UNIX_BACKEND=wayland
          
          echo "========================================="
          echo "🚀 整合开发环境已就绪！"
          echo "Haskell: $(ghc --version)"
          echo "Rust:    $(rustc --version)"
          echo "Python:  使用 uv 管理 ($(uv --version))"
          echo "========================================="
        '';
      };
    };
}
