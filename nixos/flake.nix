{
  description = "Arcane's Modular NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
     url = "github:nix-community/home-manager";
     inputs.nixpkgs.follows = "nixpkgs";
    };

    #noctalia-shell(niri)
    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell"; 
    };
    
    # DankMaterialShell(niri) 
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dankMaterialShell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.dgop.follows = "dgop";
    }; 

  };

 
  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hardware-configuration.nix
          ./base.nix
          ./share/users-base.nix
          ./share/niri.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              
              # Arcane 主用户 —— AI使用和研究，成为AI超级个体
              users.arcane = {
                home.username = "arcane";
                home.homeDirectory = "/home/arcane";
                home.stateVersion = "25.05";
                programs.home-manager.enable = true;

                imports = [
                  ./users/arcane/arcane-base.nix
                  ./users/arcane/development.nix
                  #./users/arcane/noctalia.nix
                  ./users/arcane/DankMaterialShell.nix
                  ];
                };
              
              # Jerry  —— 极简学习环境
              users.jerry = {
                home.username = "jerry";
                home.homeDirectory = "/home/jerry";
                home.stateVersion = "25.05"; 
                programs.home-manager.enable = true;

                imports = [
                  ./users/jerry/jerry-base.nix
                 ];
               };

              # Sandbox ——测试沙盒环境
              users.sandbox = {
                home.username = "sandbox";
                home.homeDirectory = "/home/sandbox";
                home.stateVersion = "25.05";
                programs.home-manager.enable = true;

                imports = [
                   #./users/sandbox/sandbox-base.nix
                   #./share/DankMaterialShell.nix
                  ];
                };

            };
          }
        ];
      };
    };
  };
} 
