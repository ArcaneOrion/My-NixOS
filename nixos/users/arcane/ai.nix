{ config, pkgs, ... }:

{  

  home.packages = with pkgs; [
    opencode
    cherry-studio
    lmstudio
    ollama
    onnxruntime
  ];

}
