{
  description = "Arcane's Modular NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
     url = "github:nix-community/home-manager";
     inputs.nixpkgs.follows = "nixpkgs";
    };

    #noctalia-shell(niri)
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
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
              backupFileExtension = "backup";
              
              # ArcaneOrion 主用户 —— AI使用和研究，成为AI超级个体
              users.arcaneorion = {
                home.username = "arcaneorion";
                home.homeDirectory = "/home/arcaneorion";
                home.stateVersion = "26.05";
                programs.home-manager.enable = true;

                imports = [
                  ./users/arcaneorion/arcaneorion-base.nix
                  ./users/arcaneorion/development.nix
                  ./users/arcaneorion/ai.nix
                  #./users/arcaneorion/noctalia.nix
                  ./users/arcaneorion/DankMaterialShell.nix
                  ];
                };

              # Sandbox ——测试沙盒环境
              users.sandbox = {
                home.username = "sandbox";
                home.homeDirectory = "/home/sandbox";
                home.stateVersion = "26.05";
                programs.home-manager.enable = true;

                imports = [
                   ./users/sandbox/sandbox-base.nix
                  ];
                };

            };
          }
        ];
      };
    };
  };
} 
