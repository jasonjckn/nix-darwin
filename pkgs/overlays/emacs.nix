{ system, inputs, ... }:

[

    inputs.emacs-overlay.overlays.default

    (final : prev: {

        emacsGit = throw "foo";

        emacs-29 = prev.emacsGit.overrideAttrs (old:
            {
                name = "emacs-29";
                version = inputs.emacs-src.shortRev;
                src = inputs.emacs-src;

                patches = [
                    ../patches/emacs/system-appearance.patch
                    ../patches/emacs/no-frame-refocus-cocoa.patch
                    ../patches/emacs/round-undecorated-frame.patch
                    ../patches/emacs/fix-window-role.patch
                ];

                stdenv = prev.addAttrsToDerivation {
                    NIX_CFLAGS_COMPILE = "-O3 -pipe -ftree-vectorize -fomit-frame-pointer";
                    BYTE_COMPILE_EXTRA_FLAGS = '' \
                 --eval '(setq native-comp-speed 3)' \
                 --eval '(setq native-comp-compiler-options '("-O3"))'
                  '';
                } (prev.impureUseNativeOptimizations final.llvmPackages_14.stdenv);
            }
        );
    })


]



    #
    # DEVELOPER NOTES
    #


    # libgccjit =
    #   (import "${inputs.nixpkgs-unstable}/pkgs/development/compilers/gcc/12")
    #     (with prev;
    #       rec {
    #         # stdenv = final.llvmPackages_14.stdenv;
    #         # stdenv = final.gcc.stdenv;
    #         inherit stdenv;
    #         langJit = true;
    #         langObjC = false;
    #         langObjCpp = false;
    #         noSysDirs = false;
    #         inherit lib fetchurl fetchpatch;
    #         inherit gmp mpfr libmpc gettext which patchelf;
    #         inherit cloog;
    #         targetPackages = {
    #           inherit stdenv;
    #           # stdenv = final.gcc.stdenv;
    #         };
    #         buildPackages = {
    #           inherit stdenv;
    #           # stdenv = final.gcc.stdenv;
    #         };
    #         inherit libxcrypt  gnused;
    #         threadsCross = {};
    #       }) ;
