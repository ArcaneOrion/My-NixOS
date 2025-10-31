{ pkgs, inputs, ... }:
{
  # install package
  environment.systemPackages = with pkgs; [
    inputs.noctalia.packages.${system}.default
    papirus-icon-theme
    hicolor-icon-theme
    # ... maybe other stuff
  ];

  # 启用UPower服务
  services.upower.enable = true;
  
  # 启用PowerProfiles守护进程
  services.power-profiles-daemon.enable = true;
  
  # 确保dbus服务已启用
  services.dbus.enable = true;

}
