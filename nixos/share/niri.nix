{ config, pkgs, ... }:

{
  environment.systemPackages = [
      pkgs.fuzzel
      pkgs.xwayland-satellite #启用xwayland
      pkgs.nautilus #文件管理器
      pkgs.imv   # 图片查看器
      pkgs.mpv  #视频
    ];


  xdg.mime.defaultApplications = {
    "inode/directory" = "thunar.desktop";
    "application/x-directory" = "thunar.desktop";
    "image/jpeg" = "imv.desktop";
    "image/png" = "imv.desktop";
    "image/webp" = "imv.desktop";
  };

  services.gvfs.enable = true;

  services.gnome.gnome-keyring.enable = true; #密钥管理，zed需要

  xdg.portal = {
    enable = true;
    wlr.enable = true; # 对 wlroots 合成器的支持
    # Niri 推荐使用 gtk portal 来处理文件选择和打开链接
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # 系统级图形配置 - 必须添加！
  hardware.graphics = {
    enable = true;
  };

  # 环境变量
  environment.variables = {
    LIBGL_DRIVERS_PATH = "${pkgs.mesa}/lib/dri";
  };
}
