{
  description = "Odilf's nix configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-utils.url = "github:numtide/flake-utils";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    churri = {
      url = "github:odilf/churri";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sentouki = {
      url = "github:odilf/sentouki";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    apple-silicon.url = "github:tpwrules/nixos-apple-silicon";
    nixpkgs-systemd-boot-apple-silicon.url = "github:NixOS/nixpkgs?rev=41dea55321e5a999b17033296ac05fe8a8b5a257";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      nix-darwin,
      home-manager,
      ...
    }@inputs:
    {
      nixosConfigurations."uoh-server" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/uoh-server/configuration.nix
          ./modules
          ./modules/polyfill/nix-darwin.nix
          home-manager.nixosModules.default
          inputs.churri.nixosModules.default
          inputs.sentouki.nixosModules.default
        ];
      };

      nixosConfigurations."nixbook" = inputs.nixpkgs-systemd-boot-apple-silicon.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./hosts/nixbook/configuration.nix
          ./modules
          ./modules/polyfill/nix-darwin.nix
          home-manager.nixosModules.default
          inputs.apple-silicon.nixosModules.default
        ];
      };

      darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/macbook/configuration.nix
          ./modules
          ./modules/polyfill/nixos.nix
          home-manager.nixosModules.default
        ];
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
