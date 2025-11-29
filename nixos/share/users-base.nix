#一部分系统级配置
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
  helix
  vim 
  neovim
  appimage-run
  niri
  clash-verge-rev

  xdg-utils                    # 提供 xdg-open 等命令
  xdg-desktop-portal           # 核心门户服务
  xdg-desktop-portal-gnome     # niri 依赖 GNOME portal 实现屏幕捕获
  xdg-desktop-portal-gtk       # 文件选择器等基础功能
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

  #  启用 Firejail  沙盒环境使用tor
  programs.firejail = {
    enable = true;

    # 包装 Tor Browser
    wrappedBinaries = {
      tor-browser = {
        executable = "${pkgs.lib.getBin pkgs.tor-browser}/bin/tor-browser";
        
        # 使用 Firejail 自带的 profile
        profile = "${pkgs.firejail}/etc/firejail/tor-browser.profile";
        
        extraArgs = [
          # --- 安全增强 ---
          "--private-tmp"
          "--dns=127.0.0.1"
          
          # --- Wayland / Niri 兼容性关键设置 ---
          # 注意：Niri 在某些情况下可能会使用 wayland-1。
          # 如果启动失败，请在终端运行 `echo $WAYLAND_DISPLAY` 查看，
          # 并将下方的 wayland-0 改为对应的名字。
          "--whitelist=\${RUNUSER}/wayland-0"
          "--whitelist=\${RUNUSER}/wayland-1" #以此类推，多写一行作为备用通常无害
          
          # 强制使用原生 Wayland (重要)
          "--env=MOZ_ENABLE_WAYLAND=1"
          
          # 修复 GTK/Wayland 下的一些沙盒报错
          "--ignore=private-dev"
          
          # 如果遇到 DBus 报错，可能需要取消注释下面这行：
          # "--ignore=nodbus" 
        ];
      };
    };
  };


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
