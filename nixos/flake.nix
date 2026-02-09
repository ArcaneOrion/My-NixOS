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
    dankMaterialShell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    }; 

  };

 
  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hardware-configuration.nix
          ./system/base.nix
          ./system/users-base.nix
          ./system/fonts.nix
          ./system/networking.nix
          ./system/gaming.nix
          ./system/desktop/niri.nix
          ./system/service/sing-box.nix
          ./system/service/docker.nix
          ./system/service/postgresql.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              backupFileExtension = "backup";
              
              # ArcaneOrion 主用户
              users.arcaneorion = {
                home.username = "arcaneorion";
                home.homeDirectory = "/home/arcaneorion";
                home.stateVersion = "26.05";
                programs.home-manager.enable = true;

                imports = [
                  ./home/arcaneorion/app.nix
                  ./home/arcaneorion/development.nix
                  ./home/arcaneorion/ai.nix
                  ./home/arcaneorion/noctalia.nix
                  #./home/arcaneorion/dank-material-shell.nix
                  ];
                };

              # Sandbox ——测试沙盒环境
              users.sandbox = {
                home.username = "sandbox";
                home.homeDirectory = "/home/sandbox";
                home.stateVersion = "26.05";
                programs.home-manager.enable = true;

                imports = [
                   ./home/sandbox/base.nix
                  ];
                };

            };
          }
        ];
      };
    };
  };
} 
