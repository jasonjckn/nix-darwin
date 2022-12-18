#
# Base NixOS module, included by default
#

{ config, inputs, lib, pkgs, ... }:

let
  inherit (lib._) mapModulesRec' filterSelf;
in {
  imports = mapModulesRec' ./. import;

  nix = let
    registry = lib.mapAttrs (_: v: { flake = v; }) (filterSelf inputs);
  in {
    package = pkgs.unstable.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes repl-flake
      download-attempts = 3
      keep-outputs = true
      keep-derivations = true
    '';
    registry = registry;

    settings = {
      auto-optimise-store = lib.mkDefault false;
      substituters = [
        "https://cachix.org/api/v1/cache/emacs"
        "https://cachix.org/api/v1/cache/nix-community"
        # "https://nix-emacs-flake.cachix.org"
      ];

      trusted-public-keys = [
        "emacs.cachix.org-1:b1SMJNLY/mZF6GxQE+eDBeps7WnkT0Po55TAyzwOxTY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        # "nix-emacs-flake.cachix.org-1:QJO+T5k/OJXqw805uI14qsoQeLVqpS5Gwv0r8GraD5M="
      ];
    };
  };

  # Recreate /run/current-system symlink after boot
  services.activate-system.enable = true;

  environment.systemPackages = with pkgs; [
    rnix-lsp
    nixfmt
    cacert
    cachix
    nix-index
  ];


  system.stateVersion = 4;
}
