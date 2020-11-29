{pkgs  ? import <nixpkgs> {}}:
  pkgs.haskellPackages.callPackage ./bahriye.nix {}
