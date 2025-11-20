{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
  helix
  vim 
  neovim
  appimage-run
  niri
  ];

   # 完整的字体配置
  fonts = {
    enableDefaultPackages = true;
    
    packages = with pkgs; [
      # 英文字体
      noto-fonts
      noto-fonts-color-emoji
      dejavu_fonts
      liberation_ttf
      
      # 中文字体 - 关键！
      noto-fonts-cjk-sans    # 思源黑体
      noto-fonts-cjk-serif   # 思源宋体
      wqy_zenhei             # 文泉驿正黑
      wqy_microhei           # 文泉驿微米黑
      
      # 可选的其他中文字体
      sarasa-gothic          # 更纱黑体
      
      # 编程字体
      jetbrains-mono
      fira-code
    ];
    
    fontconfig = {
      enable = true;
      
       # 设置默认字体优先级
      defaultFonts = {
        sansSerif = [ "Noto Sans" "Noto Sans CJK SC" "DejaVu Sans" ];
        serif = [ "Noto Serif" "Noto Serif CJK SC" "DejaVu Serif" ];
        monospace = [ "JetBrains Mono" "Noto Sans Mono CJK SC" "DejaVu Sans Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # 启用 zsh,主题用p10k,先装oh-my-zsh
  # 重新设置主题  p10k configure
  programs.zsh.enable = true;

  # 启用 Steam

  # steam需要系统级别配置
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
  };
  # 32 位图形支持
  hardware.graphics = {
    enable = true;        
    enable32Bit = true; 
  };
  # 可选：性能优化
  programs.gamemode.enable = true;

   # 环境变量（Wayland 必需）
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Niri";
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";

    # 输入法环境变量
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
  }; 

}
