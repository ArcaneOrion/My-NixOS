# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs,lib, ... }:

{
  #启动flake等'实验性'功能
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  #允许非自由软件
  nixpkgs.config.allowUnfree = true;

  # Bootloader
  boot.loader = { 
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      
      # 手动添加 Arch Linux 引导条目
      extraEntries = ''
        menuentry "Windows" {
          insmod part_gpt
          insmod fat
          insmod chain
          search --no-floppy --fs-uuid --set=root 729C-E7C6
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
    };
  };

  #更换国内源
  nix.settings.substituters = [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://cache.nixos.org"  # 保留官方源作为备用
  ];

  # 系统基本信息
  networking.hostName = "nixos"; 
  system.stateVersion = "25.05"; 

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  #i18n.defaultLocale = "zh_CN.UTF-8";
  # 可选：确保系统 locale 是英文，避免触发中文目录
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
    LC_MESSAGES = "en_US.UTF-8";

  };

  # 输入法配置
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs.qt6Packages; [
      fcitx5-chinese-addons
    ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };


  # 多用户配置
  users.users.arcane = {
    isNormalUser = true;
    description = "Arcane";
    extraGroups = [ "networkmanager" "wheel" "docker"];
    shell = pkgs.zsh;
  };

  users.users.jerry = {
    isNormalUser = true;
    description = "Jerry";
    extraGroups = [ "networkmanager"];
    #shell = pkgs.zsh;
  };

  users.users.sandbox = {
    isNormalUser = true;
    description = "Sandbox";
    extraGroups = [ "networkmanager"];
    #shell = pkgs.zsh;
  };

  # Install firefox.
  programs.firefox.enable = true;

  # 系统基础包
  environment.systemPackages = with pkgs; [
  os-prober
  blueman
  tlp
  kitty
  alacritty
  tree
  btop
  yazi
  killall
  lsof
  pciutils    # lspci
  usbutils    # lsusb
  lshw        # 硬件信息
  inxi        # 系统信息工具
  mesa-demos  # glxinfo
  iproute2

  docker
  docker-compose
  ];

 # 电源管理服务
  services.upower.enable = true;

  # 蓝牙服务
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # 电源配置服务
  services.power-profiles-daemon.enable = true;

  # 启用系统级别docker（推荐）
  virtualisation.docker = {
    enable = true;
  };

  # 禁止 docker 开机自启 先手动启动clash
  systemd.services.docker.wantedBy = lib.mkForce [];
  systemd.sockets.docker.wantedBy = lib.mkForce [];

  #设置docker网络代理
  systemd.services.docker.serviceConfig.Environment = [
  "HTTP_PROXY=http://127.0.0.1:7897"
  "HTTPS_PROXY=http://127.0.0.1:7897"
  "NO_PROXY=localhost,127.0.0.1,.local,/var/run/docker.sock"
];

}
