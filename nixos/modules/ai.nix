{ config, pkgs, ... }:

{  

  environment.systemPackages = [
    pkgs.opencode
  ];

}
