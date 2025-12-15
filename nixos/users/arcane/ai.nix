{ config, pkgs, ... }:

{  

  home.packages = with pkgs; [
    cherry-studio
    kiro
    code-cursor
    vscode
    lmstudio
    ollama
    onnxruntime
  ];

}
