{ config, pkgs, ... }:

{  

  home.packages = with pkgs; [
    cherry-studio
    kiro
    code-cursor
    lmstudio
    ollama
    onnxruntime
  ];

}
