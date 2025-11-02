# 在 modules/base.nix 或专门的桌面配置中
{ config, pkgs, ... }:

{
  # 电源管理服务
  services.upower.enable = true;
  
  # 蓝牙服务
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  
  # 电源配置服务
  services.power-profiles-daemon.enable = true;
 
}
