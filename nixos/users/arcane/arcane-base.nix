# 桌面环境配置
{ config, pkgs, ... }:

{
  # 桌面应用
  home.packages = with pkgs; [
    # 浏览器
    chromium
    google-chrome
    tor-browser

    # 通讯信息
     wechat
     qq

     # 娱乐
     bilibili
    
    # 办公
    onlyoffice-desktopeditors
    wpsoffice-cn 
    feishu 
    obsidian
 
    # 下载器
    motrix
  ];

}
