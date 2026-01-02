#  Arcaneorion 开发环境配置
{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # 版本控制
    git
    
    # 编辑器 & IDE
    vscode
    zed-editor #rust写的下一代代码编辑器
    antigravity #谷歌反重力编辑器

    #容器支持
    distrobox #arch ubuntu (不影响nixos系统环境）  

    #数据库可视化
    dbeaver-bin

    #安卓工具
    android-tools
    scrcpy 
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

 # 启用 direnv 和 nix-direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  # 关键：即使系统安装了 zsh，这里也必须启用
  # 这样 Home Manager 才有权限去管理 ~/.zshrc 并写入 direnv 的 hook
   programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    # 2. 使用新的 initContent API，并利用 mkMerge 保持顺序
    initContent = lib.mkMerge [
      (lib.mkBefore ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')

      ''
        # 加载 p10k 配置
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

        # LM Studio
        export PATH="$PATH:/home/arcaneorion/.lmstudio/bin"

        # --- 自定义补全函数 ---
        
        # NixOS Rebuild 补全
        if [ -n "''${commands[nixos-rebuild]}" ]; then
          _nixos-rebuild() {
            local curcontext="$curcontext" state line
            typeset -A opt_args
            _arguments -C '1: :->command' '*: :->args'
            case $state in
              (command)
                local -a subcommands
                subcommands=(
                  "switch:build, activate and generation"
                  "boot:build and add to boot menu"
                  "test:build and activate but don't add to generation"
                  "build:build but don't make active"
                  "dry-activate:show what would be activated"
                  "build-vm:build a virtual machine"
                  "build-vm-with-bootloader:build a virtual machine with boot loader"
                )
                _describe -t commands 'nixos-rebuild command' subcommands
                ;;
            esac
          }
          compdef _nixos-rebuild nixos-rebuild
        fi

        # Flake 补全
        _nix_flake() {
          local curcontext="$curcontext" state line
          typeset -A opt_args
          _arguments -C '1: :->command' '*: :->args'
          case $state in
            (command)
              local -a subcommands
              subcommands=(
                "run:run a flake app"
                "develop:run a bash shell with the flake development environment"
                "build:build a flake output"
                "check:build and run checks"
                "search:search packages"
                "registry:manage flake registry"
                "update:update flake lock file"
                "init:initialize a flake in the current directory"
                "show:show the outputs of a flake"
                "clone:clone a flake into a directory"
                "archive:create a tarball from a flake"
                "bundles:manage bundles"
                "copy:copy flake outputs to a store"
                "edit:open the flake in $EDITOR"
                "eval:evaluate a nix expression"
                "log:show the build log of a flake output"
                "path-info:query information about store paths"
                "repl:start an interactive environment for evaluating Nix expressions"
                "profile:manage Nix profiles"
              )
              _describe -t commands 'nix flake command' subcommands
              ;;
            (args)
              case $words[2] in
                (build|develop|run|show|check|archive)
                  _files
                  ;;
              esac
              ;;
          esac
        }
        compdef _nix_flake nix
      ''
    ];
  };

}
