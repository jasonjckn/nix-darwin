{ inputs, lib, ... }:

with lib;
let
  inherit (lib._) mergeWithConcat;
  inherit (inputs.darwin.lib) darwinSystem;
in
{
  mkNixosSystem = args: path:
    darwinSystem (mergeWithConcat [
      rec {
        system = import (path + "/system.nix");

        pkgs = inputs.pkgs.legacyPackages."${system}";

        specialArgs = { inherit system lib inputs pkgs; };

        modules = [
          {
            environment.variables.HOSTNAME = (baseNameOf path);
            environment.variables.NIX_SYSTEM = system;
          }
          (import path)
        ];
      }

      args
    ]);
}
