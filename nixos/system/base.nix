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
    };
  };

  nix.settings.substituters = [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://cache.nixos.org"  
  ];

  # 系统基本信息
  networking.hostName = "nixos"; 
  system.stateVersion = "26.05"; 

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
  users.users.arcaneorion = {
    isNormalUser = true;
    description = "ArcaneOrion";
    extraGroups = [ "networkmanager" "wheel" "docker"];
    shell = pkgs.zsh;
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
    brightnessctl # 亮度控制
    libnotify # 桌面通知库
    # mako # 通知守护进程
    grim #截图工具
    powertop #功耗分析工具
  ];

 # 电源管理服务
  services.upower.enable = true;

  # 蓝牙服务
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # 电源配置服务
  #services.tlp = {
    #enable = true;
    #settings = {
    #  START_CHARGE_THRESH_BAT0 = 70;
    #  STOP_CHARGE_THRESH_BAT0 = 80;
    # };
  #};

  # 内存压缩交换 — 防止内存爆满时系统假死
  zramSwap = {
    enable = true;
    memoryPercent = 50;  # 7G zram, 实际能存 ~18G 数据(lz4 压缩)
    priority = 100;       # 优先用 zram, 不行再落 NVMe swap
  };

  # 关掉默认的 systemd-oomd(基于 PSI, 桌面场景反应慢)
  systemd.oomd.enable = false;

  # earlyoom: 简单阈值触发, 交互式桌面更适用
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;    # 内存剩 5% 时开始杀
    freeSwapThreshold = 10;  # swap 剩 10% 时开始杀
  };

  # 内核内存管理调优 — 降低磁盘 swap 倾向,保留文件缓存
  boot.kernel.sysctl = {
    "vm.swappiness" = 30;          # 适度提前换出冷页，降低顶满内存的概率
    "vm.vfs_cache_pressure" = 50;  # 默认100 → 50: 多留文件缓存,Chrome/IDE受益
  };

}
