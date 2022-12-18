#
#   __ _       _                _
#  / _| | __ _| | _____   _ __ (_)_  __
# | |_| |/ _` | |/ / _ \ | '_ \| \ \/ /
# |  _| | (_| |   <  __/_| | | | |>  <
# |_| |_|\__,_|_|\_\___(_)_| |_|_/_/\_\
#
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    #
    devshell.url = "github:numtide/devshell";
    emacs-overlay.url = "github:Nix-Community/emacs-overlay";
    emacs-src.url = "github:emacs-mirror/emacs/emacs-29";
    flake-utils.url = "github:numtide/flake-utils";
    sheldon.url = "github:jasonjckn/sheldon-flake";
    clojure-lsp.url = "github:clojure-lsp/clojure-lsp";
    #
    emacs-src.flake = false;
  };

  outputs = { self, ... }@inputs:
    let
      lib = import ./lib { inherit inputs; };
      inherit (lib._) mapModules eachDefaultSystem;

    in
      with lib;
      eachDefaultSystem ( system:
        let
          pkgs = self.legacyPackages."${system}";

          mkPkgs = p: overlays: import p {
            inherit overlays system;
            config = {
              allowUnfree = true;
            };
          };

          overlayModules =
            mapModules
              ./overlays
              (o: import o { inherit system inputs pkgs; });

          overlays = [
            (final: prev: {
              # This overlay binds packages defined above available via ‹pkgs._›
              # and unstable packages via ‹pkgs.unstable›
              _ = mapModules ./extra (p: pkgs.callPackage p {});
              unstable = mkPkgs inputs.nixpkgs-unstable [];
            })
          ] ++ lists.flatten (lib.attrValues overlayModules);


        in {
          inherit lib;
          legacyPackages = mkPkgs inputs.nixpkgs overlays;
          devInspect = { inherit overlayModules; };
        } );
}


  #
  # DEVELOPER NOTES
  #
  # nixdarwin.inputs.nixpkgs.follows = "nixpkgs";
  # nixdarwin.url = "github:lnl7/nix-darwin/master";
  #
