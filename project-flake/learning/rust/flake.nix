# ~/learning/rust/flake.nix
{
  description = "Rust 1.75+ 学习专用环境";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, rust-overlay }:
    let 
      pkgs = import nixpkgs {
        overlays = [ rust-overlay.overlays.default ];
        system = "x86_64-linux";
      };
    in {
      devShell.x86_64-linux = pkgs.mkShell {
        packages = with pkgs; [
          # 锁定 Rust 稳定版（可改为 nightly 学习新特性）
          (rust-bin.stable.latest.default.override {
            extensions = [ "rust-src" "rust-analyzer" ];
          })
          
          cargo
          rustc
        ];

      shellHook = ''
          echo "环境就绪"
          exit  #退出bash
        '';
      };
    };
}
