{ config, pkgs, ... }:

{
  # 不启用 X11
  services.xserver.enable = false;

  # 启用 Hyprland
  programs.hyprland.enable = true;

  # 常用 Wayland 工具
  environment.systemPackages = with pkgs; [
    waybar
    wofi          # 应用启动器
    swaylock      # 锁屏
    swaybg        # 壁纸
    wl-clipboard  # 剪贴板（wl-copy / wl-paste）
  ];

}

