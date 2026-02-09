# Docker 容器服务
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
  ];

  virtualisation.docker = {
    enable = true;
  };
}
