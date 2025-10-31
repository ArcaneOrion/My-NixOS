# /etc/nixos/modules/gaming.nix
{ config, pkgs, ... }:

{
  # 启用 Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
  };

  # 32 位图形支持（NixOS 25.05+）
  hardware.graphics = {
    enable = true;        
    enable32Bit = true; 
  };

  # 可选：性能优化
  programs.gamemode.enable = true;
}
