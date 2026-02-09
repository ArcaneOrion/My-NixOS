# noctalia的用户级配置
{ pkgs, inputs, ... }:
{
    imports = [
      inputs.noctalia.homeModules.default
    ];

    # configure options
    programs.noctalia-shell = {
      enable = true;
    };
}
