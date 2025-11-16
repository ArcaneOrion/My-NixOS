# Jerry极简学习环境配置
{ config, pkgs, ... }:

{
  # 桌面应用
  home.packages = with pkgs; [
    chromium

    python3
    ghc
    ghcid
  ];

}
