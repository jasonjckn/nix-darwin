#
#   __ _       _                _
#  / _| | __ _| | _____   _ __ (_)_  __
# | |_| |/ _` | |/ / _ \ | '_ \| \ \/ /
# |  _| | (_| |   <  __/_| | | | |>  <
# |_| |_|\__,_|_|\_\___(_)_| |_|_/_/\_\
#
{
  description = ''
    A calm winter's day...
  '';

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    pkgs.url = "path:pkgs";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin/master";
  };

  outputs = { self, ... }@inputs:
    let
      inherit (lib._) mapModules mapModulesRec mkNixosSystem deepMerge eachDefaultSystem;
      lib = import ./pkgs/lib { inherit inputs; };

    in
    deepMerge [
      rec {
        darwinConfigurations =
          mapModules
            ./host
            (mkNixosSystem { modules = [ ./modules ]; });

        devInspect = {
          inherit darwinConfigurations;
          nixosModules = mapModulesRec ./modules import;
        };
      }

      (eachDefaultSystem (system:
        let
          pkgs = inputs.pkgs.legacyPackages.${system};
        in
        {
          devShells.default = pkgs.mkShell {
            name = "nixos-generic";
            packages = with pkgs; [ git hello ];
          };
        }
      ))
    ];
}
