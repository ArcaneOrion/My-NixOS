{ config, pkgs, inputs, ... }:  # 注意：加了 inputs 参数

{
  environment.systemPackages = with pkgs; [
    inputs.caelestia-shell.packages."x86_64-linux".default
  ];
}
