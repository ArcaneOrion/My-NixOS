#  Arcane 开发环境配置
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # 版本控制
    git
    
    # 编辑器 & IDE
    zed-editor #rust写的下一代代码编辑器
    antigravity #谷歌反重力编辑器

    #容器支持
    distrobox #arch ubuntu (不影响nixos系统环境）   
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
