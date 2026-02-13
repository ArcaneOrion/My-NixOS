# sing-box 代理服务
{ lib, pkgs, ... }:
let
  singBoxDir = "/home/arcaneorion/sing-box";
  sourceConfig = "${singBoxDir}/config.jsonc";
  runtimeConfig = "${singBoxDir}/config.auto.json";
  updateScript = "${singBoxDir}/scripts/update-node-ips.sh";
  singBoxBin = "${pkgs.sing-box}/bin/sing-box";
in
{
  # 主服务：开机启动 sing-box；每次启动前先刷新节点入口 IP
  systemd.services.sing-box = {
    description = "sing-box service";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      WorkingDirectory = singBoxDir;
      ExecStartPre = "${updateScript} --config ${sourceConfig} --output ${runtimeConfig}";
      ExecStart = "${singBoxBin} run -c ${runtimeConfig}";
      Restart = "on-failure";
      RestartSec = 3;
    };

    path = [ pkgs.bash pkgs.systemd pkgs.coreutils pkgs.gnugrep pkgs.gawk pkgs.nodejs pkgs.sing-box ];
  };
}
