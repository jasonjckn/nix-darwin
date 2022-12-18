{ inputs, lib, pkgs, ... }:

{
  services.nix-daemon.enable = true;

  environment.systemPackages = with pkgs; [
    hello
    emacsGit
    emacs-29
    babashka
    # clojure-lsp
    # sheldon
  ];

  # modules = {
  # };
}
