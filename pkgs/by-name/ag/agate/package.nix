{
  lib,
  stdenv,
  nixosTests,
  fetchFromGitHub,
  rustPlatform,
  openssl,
  pkg-config,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "agate";
  version = "3.3.16";

  src = fetchFromGitHub {
    owner = "mbrubeck";
    repo = "agate";
    tag = "v${version}";
    hash = "sha256-TLLmoQXrvgDskmH9sKxUi5AqYrCR0ZaJJdbOV03IbMc=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-HA1h06ZlWvq7z5hJFqKxGtXNk8/GHxUivigaVqWQCvA=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/agate --help
    $out/bin/agate --version 2>&1 | grep "agate ${version}"
    runHook postInstallCheck
  '';

  __darwinAllowLocalNetworking = true;

  passthru = {
    tests = {
      inherit (nixosTests) agate;
    };
    updateScript = nix-update-script { };
  };

  meta = {
    homepage = "https://github.com/mbrubeck/agate";
    changelog = "https://github.com/mbrubeck/agate/releases/tag/v${version}";
    description = "Very simple server for the Gemini hypertext protocol";
    mainProgram = "agate";
    longDescription = ''
      Agate is a server for the Gemini network protocol, built with the Rust
      programming language. Agate has very few features, and can only serve
      static files. It uses async I/O, and should be quite efficient even when
      running on low-end hardware and serving many concurrent requests.
    '';
    license = with lib.licenses; [
      asl20
      mit
    ];
    maintainers = with lib.maintainers; [ jk ];
  };
}
