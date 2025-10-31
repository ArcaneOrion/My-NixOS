# 开发环境配置
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # 版本控制
    git
    
    # 编辑器 & IDE
    zed-editor #rust写的下一代代码编辑器
    helix
    neovim
    vim
    
    # 编程语言
    python3
    #rust
    #gcc
    #gnumake
    #cmake
    
    # 开发工具
    docker
    docker-compose
    #postman
    #insomnia
    
    # 数据库
    #sqlite
    #postgresql
    
    # 终端工具相关
    #tmux
    htop
    yazi
  ];

  # 开发相关服务
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # 开发环境变量
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    GOPATH = "$HOME/go";
    NODE_ENV = "development";
  };

  # Git 配置
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      user.email = "3526162625@qq.com";
      user.name = "arcanexis";
    };
  };

}
