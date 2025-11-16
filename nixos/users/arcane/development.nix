#  Arcane 开发环境配置
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # 版本控制
    git
    
    # 编辑器 & IDE
    zed-editor #rust写的下一代代码编辑器
    
    # 编程语言 
    ghc 
    ghcid 

    python3

    rustc
    cargo
   
    #容器支持
    distrobox #arch ubuntu (不影响nixos系统环境）   
 
    # 数据库
    #sqlite
    #postgresql
    
    # 终端工具相关
    #tmux
  ];

  # 开发环境变量
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    GOPATH = "$HOME/go";
    NODE_ENV = "development";
  };

  # Git 配置
  programs.git = {
    enable = true;
    settings = {
      user.name = "arcanexis";
      user.email = "3526162625@qq.com";
      init.defaultBranch = "main";
      core.editor = "nvim";
      pull.rebase = false;
    };
  };

}
