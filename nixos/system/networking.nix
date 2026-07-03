# 防火墙、TUN 转发、IPv6 配置
{ config, pkgs, ... }:

{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1; # 允许 Linux 内核"转发网络包",TUN模式

  networking.enableIPv6 = false; # 关闭 IPv6

  # NetworkManager 激活接口时会重新启用该接口 IPv6，覆盖上面的 enableIPv6=false，
  # 导致 DNS 返回的 IPv6 地址让程序优先尝试不通的 IPv6、超时数秒后才回退 IPv4（网络卡顿）。
  # 用 dispatcher 在每次接口 up 后强制禁用 IPv6，彻底杜绝该问题。
  networking.networkmanager.dispatcherScripts = [{
    type = "basic";
    source = pkgs.writeText "nm-disable-ipv6" ''
      #!/bin/sh
      case "$2" in
        up|reconnect)
          ${pkgs.procps}/bin/sysctl -w "net.ipv6.conf.$1.disable_ipv6=1" >/dev/null 2>&1 || true
          ;;
      esac
    '';
  }];

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tun0" ]; # 信任 tun0：允许从 TUN 接口进入/返回的流量
    checkReversePath = false; # 关闭反向路径校验，TUN 模式必需
  };
}
