# Steam 游戏 + 性能优化
{ config, pkgs, ... }:

{
  # 启用 Steam
  # steam 需要系统级别配置
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

  # 性能优化
  programs.gamemode.enable = true;
}
