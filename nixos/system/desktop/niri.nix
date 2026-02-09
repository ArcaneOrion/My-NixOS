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

    # wlroots/niri 需要 wlr 后端来正确处理 OpenURI
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];

    config.common = {
      default = [ "wlr" "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = "gtk";
      "org.freedesktop.impl.portal.OpenURI" = "wlr";
    };
  };

  # 环境变量
  environment.variables = {
    LIBGL_DRIVERS_PATH = "${pkgs.mesa}/lib/dri";
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
