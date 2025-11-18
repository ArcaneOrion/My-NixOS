# ~/learning/haskell/flake.nix
{
  description = "Haskell GHC 9.4 学习专用环境";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let 
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      ghc = pkgs.haskellPackages.ghcWithPackages (hp: [
        hp.aeson    # JSON 处理
        hp.text     # 文本处理
        hp.async    # 异步编程
      ]);
    in {
      devShell.x86_64-linux = pkgs.mkShell {
        packages = with pkgs; [
          ghc
          haskell-language-server
          ghcid
        ];
      };
    };
}
