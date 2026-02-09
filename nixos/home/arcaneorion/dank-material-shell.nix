# DankMaterialShell的用户级配置
{ pkgs, inputs, ... }:

{
  imports = [
    #inputs.niri.homeModules.niri
    inputs.dankMaterialShell.homeModules.dank-material-shell
    #inputs.dankMaterialShell.homeModules.dankMaterialShell.niri
  ];

  programs.dank-material-shell = {
   enable = true;
/*
   niri = {
     enableKeybinds = false;   # Automatic keybinding configuration
     enableSpawn = true;      # Auto-start DMS with niri
    };
    
    # 功能开关
    enableSystemMonitoring = true;
    enableClipboard = true;
    enableBrightnessControl = true;
    enableColorPicker = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
    enableSystemSound = true;
    enableVPN = true;

    default.settings = {
      theme = "dark";
      dynamicTheming = true;
    }; */
  };
}
