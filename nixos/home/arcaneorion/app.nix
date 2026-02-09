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
     discord

     # 数学软件
     geogebra
     wxmaxima
     octave

     # 娱乐
     bilibili
    
    # 办公
    onlyoffice-desktopeditors
    wpsoffice-cn 
    libreoffice
    feishu 
    obsidian

    #音乐
    spotify  
 
    # 下载器
    motrix

    # 电子书
    calibre
  ];

}
