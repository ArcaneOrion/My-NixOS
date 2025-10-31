{
  description = "Arcane's Modular NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    #下面是noctalia-shell
    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";  # Use same quickshell version
    };

    #下面的是caelestia主题
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem { 
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };  # 添加这一行
      
      modules = [
        #硬件模块
        ./hardware-configuration.nix

        # 基础模块
        ./modules/base.nix

        #AI模块
        ./modules/ai.nix
        
        # 桌面模块
        ./modules/desk-enviroment/deskbase.nix
        ./modules/desk-enviroment/niri.nix
        #./modules/desk-enviroment/hyprland.nix
         #shell主题选择二选一
        #./modules/desk-enviroment/noctalia.nix
        ./modules/desk-enviroment/caelestia.nix

         #开发模块
        ./modules/development.nix

        #服务模块
        ./modules/services.nix

        #游戏模块
        ./modules/gaming.nix
        #./modules/optimization.nix
      ];
    };

  };
}

