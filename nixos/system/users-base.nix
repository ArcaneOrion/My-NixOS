# 系统级通用配置：包、nix-ld、zsh
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    sing-box
    appimage-run
    niri
    clash-verge-rev
    htop
    unzip
    unar

    xdg-utils                    # 提供 xdg-open 等命令
    xdg-desktop-portal           # 核心门户服务
    xdg-desktop-portal-gnome     # niri 依赖 GNOME portal 实现屏幕捕获
    xdg-desktop-portal-gtk       # 文件选择器等基础功能
  ];

  # 启用 nix-ld（让下载的二进制文件能运行）
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib # libstdc++, libgcc_s
      zlib             # 压缩库需要
      openssl          # SSL/TLS(网络程序需要)

      # Chromium / Playwright 依赖
      glib
      gtk3
      nss
      nspr
      cups
      libdrm
      mesa
      libx11
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      libxcb
      pango
      cairo
      alsa-lib
      at-spi2-core
      libxkbcommon
      dbus
      expat
      libxkbfile
      libgbm
      libnotify
      libsecret
      libxshmfence
      vulkan-loader
    ];
  };

  # 启用 zsh,主题用p10k,先装oh-my-zsh
  # 重新设置主题  p10k configure
  programs.zsh = {
    enable = true;
  };
}
