{mkDerivation,stdenv,base,wai,wai-extra,scotty,zlib,text,aeson,bytestring,directory,strict,filelock,process,filepath,time,pkgs}:
mkDerivation {
  pname = "bahriye";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base wai wai-extra scotty zlib text aeson bytestring directory strict filelock process filepath time
  ];
  homepage = "http://emre.xyz/bahriye";
  description = "Bahriye";
  license = with stdenv.lib.licenses; [gpl3Plus];
  patchPhase = ''
    substituteInPlace src/Main.hs \
      --replace '@@notify-send@@' '${pkgs.libnotify}/bin/notify-send' \
      --replace '@@aplay@@' '${pkgs.alsaUtils}/bin/aplay' \
      --replace '@@SIREN@@' '${./siren.wav}'
    '';
}
