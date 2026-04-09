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
     telegram-desktop
     discord

     # 数学软件
     geogebra
     wxmaxima
     octaveFull

     # 网络安全
     wireshark #抓包分析
     burpsuite #web渗透测试
     ghidra-bin #逆向工程
     netcat #网络瑞士军刀
     nmap #网络扫描器 

     # 娱乐
     bilibili
     prismlauncher
     hmcl
    
    # 办公
    onlyoffice-desktopeditors
    wpsoffice-cn 
    libreoffice
    feishu 
    obsidian

    figma-linux

    #音乐
    spotify  
 
    # 下载器
    motrix

    # 电子书
    calibre
  ];

}
