{pkgs  ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/2335e7354f8a9c34d4842aa107af14e268a27f07.tar.gz") {}}:
  pkgs.haskellPackages.callPackage ./bahriye.nix {}
