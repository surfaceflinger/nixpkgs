{ lib
, stdenv
, fetchFromGitHub
, fetchYarnDeps
, fetchzip
, makeWrapper
, makeDesktopItem
, mkYarnPackage
, electron
, desktopToDarwinBundle
, copyDesktopItems
, yarn
, prefetch-yarn-deps
, nodejs-slim
}:

mkYarnPackage rec {
  pname = "ente-desktop";
  version = "0-unstable-2024-03-02";

  src = fetchFromGitHub {
    owner = "ente-io";
    repo = "ente";
    sparseCheckout = [ "desktop" ];
    fetchSubmodules = true;
    rev = "6f7a47f04ef3b82db25a473e82019b2985d3c406";
    hash = "sha256-1xjrQLIB+uoCzBRj78iXtvfGu/j2J2ayKciFJePvMGA=";
  };
  sourceRoot = "${src.name}/desktop";
  packageJSON = ./package.json;

  nativeBuildInputs = [ copyDesktopItems makeWrapper ];

  offlineCache = fetchYarnDeps {
    yarnLock = "${src}/desktop/yarn.lock";
    hash = "sha256-XyP8vzMf9mBvxSZExwCES3sRnB9PRH44YouhQOd0YFc=";
  };

  buildPhase = ''
#    runHook preBuild
#      yarn --offline build
#    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # resources
    #mkdir -p "$out/share/"
    #cp -r './deps/micropad' "$out/share/micropad"
    #rm "$out/share/micropad/node_modules"
    #cp -r './node_modules' "$out/share/micropad"

    # icons
    #for icon in $out/share/micropad/build/icons/*.png; do
    #  mkdir -p "$out/share/icons/hicolor/$(basename $icon .png | sed -e 's/^icon-//')/apps"
    #  ln -s "$icon" "$out/share/icons/hicolor/$(basename $icon .png | sed -e 's/^icon-//')/apps/micropad.png"
    #done

    # executable wrapper
    #makeWrapper '${electron}/bin/electron' "$out/bin/name" \
    #  --add-flags "$out/share/micropad" \
    #  --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"

    runHook postInstall
  '';

  ## Do not attempt generating a tarball for micropad again.
  #doDist = false;

  # The desktop item properties should be kept in sync with data from upstream:
  # https://github.com/MicroPad/MicroPad-Electron/blob/master/package.json
  desktopItems = [
    (makeDesktopItem {
      name = "ente";
      exec = "ente %u";
      icon = "ente";
      desktopName = "ente";
      startupWMClass = "ente";
      comment = meta.description;
      categories = [ "Office" ];
    })
  ];

  meta = with lib; {
    description = "The sweetness of Ente Photos, right on your computer.";
    homepage = "https://ente.io/";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ surfaceflinger ];
    mainProgram = "ente";
    platforms = platforms.linux;
  };
}
