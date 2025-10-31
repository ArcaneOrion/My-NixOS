# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  #启动flake等'实验性'功能
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
        menuentry "Arch Linux" {
          insmod part_gpt
          insmod ext2
          insmod fat
          search --no-floppy --fs-uuid --set=root 729C-E7C6
          linux /vmlinuz-linux root=UUID=169acbe0-8049-4c17-9ca1-87f62fdb2b69 rw quiet
          initrd /initramfs-linux.img
        }
        
        menuentry "Arch Linux (Fallback)" {
          insmod part_gpt
          insmod ext2
          insmod fat
          search --no-floppy --fs-uuid --set=root 729C-E7C6
          linux /vmlinuz-linux root=UUID=169acbe0-8049-4c17-9ca1-87f62fdb2b69 rw quiet
          initrd /initramfs-linux-fallback.img
        }
        
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
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "cn";
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.arcane = {
    isNormalUser = true;
    description = "Arcane";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # 系统基础包
  environment.systemPackages = with pkgs; [
  os-prober
  blueman
  tlp
  kitty
  alacritty
  tree
  killall
  ];

  # 启用 zsh,主题用p10k,先装oh-my-zsh
  # 重新设置主题  p10k configure
  programs.zsh.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  #system.stateVersion = "25.05"; # Did you read the comment?

}
