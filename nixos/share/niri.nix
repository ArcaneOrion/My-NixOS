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
    "inode/directory" = "org.gnome.Nautilus.desktop";
    "image/jpeg" = "imv.desktop";
    "image/png" = "imv.desktop";
    "image/webp" = "imv.desktop";
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
