# 桌面环境配置
{ config, pkgs, ... }:

{
  # 桌面应用
  environment.systemPackages = with pkgs; [
    # 浏览器
    firefox
    chromium
    google-chrome
    
    # 通讯
     wechat
     qq
    
    #网络
     clash-verge-rev   

    # 视频媒体
    bilibili
    #spotify
    
    # 办公
    onlyoffice-desktopeditors 
    #libreoffice
    obsidian
 
    # 图形工具
    
    # 系统工具
    appimage-run
    
  ];

  # 字体
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    sarasa-gothic  # 更现代的中文字体（可选）
  ];

  # 输入法配置（新写法）
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs.qt6Packages; [
      fcitx5-chinese-addons
    ];
  };

  # 环境变量（Wayland 必需）
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Niri";
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
  };

}
