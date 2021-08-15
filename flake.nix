{
  description = "System Configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  #  flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, home-manager, ... }: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
    };

    lib = nixpkgs.lib;

  in {
    homeManagerConfigurations = {
      marc = home-manager.lib.homeManagerConfiguration {
        inherit system pkgs;
        username = "marc";
        homeDirectory = "/home/marc";
        configuration = {
          import = [ ./users/marc/home.nix ];
        };
      };
    };

    nixosConfigurations = {
      t560 = lib.nixosSystem {
        inherit system;
        modules = [ ./system/configuration.nix ];
      };
    };
  };
}
