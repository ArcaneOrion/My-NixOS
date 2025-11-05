{ config, pkgs, ... }:

{
  environment.systemPackages = [
      pkgs.niri
      pkgs.fuzzel
      pkgs.xwayland-satellite #启用xwayland
    ];

}
