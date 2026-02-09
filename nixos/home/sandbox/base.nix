{ config, pkgs, ... }:

{
   home.packages = with pkgs; [
    chromium
    tor-browser
   ];

}
