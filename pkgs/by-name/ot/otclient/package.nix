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
  tibiaUrl ? "https://tibiaclient.otslist.eu/getfile/y9syx7ajy6/tibia76.exe",
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
  version = "0-unstable-2024-09-14";

  src = fetchFromGitHub {
    owner = "edubart";
    repo = "otclient";
    rev = "dab86e610991092fe8b2471f7de55a7c986b3cd2";
    hash = "sha256-v7caLBz2DLgLKV4TNbbvtSIvbSW79RwT9GqRTl5chqo=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    boost
    glew
    gmp
    libGL
    libvorbis
    libX11
    luajit
    openal
    physfs
    zlib
  ];

  cmakeFlags = [
    "-DUSE_STATIC_LIBS=OFF"
    "-DLUAJIT=ON"
  ];

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
