{
  cmake,
  enableGUI ? false,
  fetchFromSourcehut,
  gitUpdater,
  lib,
  libusb1,
  pkg-config,
  qt5,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "heimdall";
  version = "2.1.1";

  src = fetchFromSourcehut {
    owner = "~grimler";
    repo = "Heimdall";
    rev = "v${finalAttrs.version}";
    hash = "sha256-zKZ80hm2d/SktnAlEIZCD+cfj2/ZlRKiVPVsfHVth+M=";
  };

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ] ++ lib.optional enableGUI qt5.wrapQtAppsHook;

  buildInputs = [
    (libusb1.override { withStatic = stdenv.hostPlatform.isWindows; })
  ] ++ lib.optional enableGUI qt5.qtbase;

  cmakeFlags = [
    "-DDISABLE_FRONTEND=${if enableGUI then "OFF" else "ON"}"
  ];

  meta = {
    broken = enableGUI && (stdenv.hostPlatform.isDarwin || stdenv.hostPlatform.isWindows);
    description = "Cross-platform open-source tool suite used to flash firmware onto Samsung mobile devices";
    homepage = "https://git.sr.ht/~grimler/Heimdall";
    license = lib.licenses.mit;
    mainProgram = if enableGUI then "heimdall-frontend" else "heimdall";
    maintainers = with lib.maintainers; [
      peterhoeg
      surfaceflinger
    ];
    platforms = with lib.platforms; unix ++ windows;
  };
})
