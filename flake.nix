{
  description = "System Configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = github:nix-community/NUR;
    myrmidon.url = github:mhanggi/myrmidon;
  };

  outputs = { nixpkgs, home-manager, nur, myrmidon, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
      overlays = [ nur.overlay myrmidon.overlay ];
    };

    lib = nixpkgs.lib;

  in {
    homeManagerConfigurations = {
      marc = home-manager.lib.homeManagerConfiguration {
        inherit system pkgs;
        username = "marc";
        homeDirectory = "/home/marc";
        configuration = {
          imports = [ ./users/marc/home.nix ];
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
