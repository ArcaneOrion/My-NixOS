# PostgreSQL 数据库服务
{ config, pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    ensureDatabases = [ "arcanedatabase" ];
    authentication = pkgs.lib.mkOverride 10 ''
      # 类型 数据库 用户 认证方式
      local all      all     trust
    '';
  };
}
