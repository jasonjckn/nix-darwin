{ system, inputs, ... }:

[
  inputs.clojure-lsp.overlays.default

  inputs.emacs-overlay.overlays.default

  (final : prev: {
    sheldon = inputs.sheldon.defaultPackage.${system};

    mkShell = inputs.devshell.legacyPackages.${system}.mkShell;

    babashka = prev.unstable.babashka;
  })
]
