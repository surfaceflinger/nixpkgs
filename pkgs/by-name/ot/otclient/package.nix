{
  boost,
  cmake,
  fetchurl,
  fetchFromGitHub,
  glew,
  gmp,
  innoextract,
  lib,
  libGL,
  libvorbis,
  libX11,
  luajit,
  openal,
  physfs,
  qt6,
  stdenv,
  zlib,
  protobuf_26,
  xz,
  nlohmann_json,
  asio,
  stduuid,
  pugixml,
  httplib,
  openssl,
  parallel-hashmap,
  tibiaUrl ? "https://ots.me/downloads/data/tibia-clients/windows/exe/Tibia760.exe",
  tibiaHash ? "sha256-RcqJQdaXJPcHVHZSyXuQhlyiYdiT+rpJfhjirHdWuiI=",
  tibiaVer ? "760",
}:

let
  tibiaInstaller = fetchurl {
    url = tibiaUrl;
    hash = tibiaHash;
  };
in
stdenv.mkDerivation (_finalAttrs: {
  pname = "otclient";
  version = "0-unstable-2024-10-13";

  src = fetchFromGitHub {
    owner = "mehah";
    repo = "otclient";
    rev = "22db98ea35a0d4098422d2c7d690931c4c3c2fe9";
    hash = "sha256-okWscd54FEUzXgMb4G9dQ0pW8Pm4NMGq7k9e2XZAiLU=";
  };

  patches = [ ./vorbisfix.patch ./stduuidfix.patch ];

  nativeBuildInputs = [
    cmake
    protobuf_26
  ];

  buildInputs = [
    asio
    #boost
    glew
    #gmp
    #libGL
    libvorbis
    libX11
    luajit
    nlohmann_json
    openal
    physfs
    stduuid
    xz
    zlib
    pugixml
    httplib
    openssl
    parallel-hashmap
  ];

  cmakeFlags = [
  #  "-DUSE_STATIC_LIBS=OFF"
  #  "-DLUAJIT=ON"
  ];

  postPatch = ''
    #runHook prePatch
    pushd src/protobuf
      #chmod +x ./generate.sh && ./generate.sh
      protoc --cpp_out=. *.proto
    popd
    #runHook postPatch
  '';

  installPhase = ''
    
  '';

  postInstall = ''
    ${lib.getExe innoextract} -d $out/share/otclient/data/things/ ${tibiaInstaller} 
    mv $out/share/otclient/data/things/{app,${tibiaVer}}
  '';

  #passthru.tests.version = testers.testVersion {
  #  package = finalAttrs.finalPackage;
  #  command = ''
  #    QT_QPA_PLATFORM=minimal ${finalAttrs.finalPackage.meta.mainProgram} --version
  #  '';
  #};

  meta = with lib; {
    #description = "Free Monero desktop wallet";
    #homepage = "https://featherwallet.org/";
    #changelog = "https://featherwallet.org/changelog/#${finalAttrs.version}%20changelog";
    platforms = platforms.linux;
    license = licenses.mit;
    mainProgram = "otclient";
    maintainers = with maintainers; [ surfaceflinger ];
  };
})
