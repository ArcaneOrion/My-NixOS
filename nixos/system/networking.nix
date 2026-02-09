# 防火墙、TUN 转发、IPv6 配置
{ config, pkgs, ... }:

{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1; # 允许 Linux 内核"转发网络包",TUN模式

  networking.enableIPv6 = false; # 关闭 IPv6

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tun0" ]; # 信任 tun0：允许从 TUN 接口进入/返回的流量
    checkReversePath = false; # 关闭反向路径校验，TUN 模式必需
  };
}
