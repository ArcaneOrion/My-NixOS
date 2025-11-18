# ~/learning/python/flake.nix
{
  description = "Python 3.13 学习专用环境";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let 
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      pythonEnv = pkgs.python313.withPackages (ps: with ps; [
        numpy
        scipy 
        pandas 
        matplotlib
        
        jupyterlab
      ]);
    in {
      devShell.x86_64-linux = pkgs.mkShell {
        packages = [ pythonEnv ];
      };
    };
}
