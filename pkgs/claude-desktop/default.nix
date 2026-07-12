# Claude Desktop for Linux — repackaged from Anthropic's OFFICIAL .deb.
#
# Anthropic ships a first-party Linux beta (amd64/arm64) via their APT repo
# (https://downloads.claude.ai/claude-desktop/apt/stable). NixOS can't consume a
# .deb directly, so we fetch the pinned amd64 .deb, unpack it, autoPatchelf the
# bundled Electron binary against the Nix runtime libs its Debian `Depends` name,
# and wrap the launcher. The app.asar is used byte-identical — nothing is rebuilt.
#
# Update: bump `version`, refetch, and paste the new hash Nix reports. The
# pool/ index lives at .../apt/stable/dists/stable/main/binary-amd64/Packages.
#
# x86_64-linux only (matches the VirtualBox nixos-desktop VM); guarded in
# pkgs/default.nix behind `pkgs.stdenv.isLinux`.
{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  makeWrapper,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  ffmpeg,
  glib,
  gtk3,
  libayatana-appindicator,
  libdrm,
  libGL,
  libgbm,
  libnotify,
  libsecret,
  libuuid,
  libxkbcommon,
  nspr,
  nss,
  pango,
  systemd,
  vulkan-loader,
  xdg-utils,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libxscrnsaver,
  libxshmfence,
  libxtst,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "claude-desktop";
  version = "1.19367.0";

  src = fetchurl {
    url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${finalAttrs.version}_amd64.deb";
    hash = "sha256-dvVwcwwRhZJOJCPF+IonvsF8HnrbBV7NCUAaDpOpKZs=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
    makeWrapper
  ];

  # Debian `Depends`/`Recommends`, mapped to nixpkgs. autoPatchelfHook rewrites the
  # bundled ELF's rpath to these.
  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libayatana-appindicator
    libdrm
    libgbm
    libnotify
    libsecret
    libuuid
    libxkbcommon
    nspr
    nss
    pango
    (lib.getLib systemd)
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxscrnsaver
    libxshmfence
    libxtst
  ];

  # Libraries Electron/Chromium dlopen at runtime (not in DT_NEEDED) — added to
  # the rpath so GPU/video/notifications work.
  runtimeDependencies = [
    libGL
    vulkan-loader
    ffmpeg
    libnotify
  ];

  # We drive the GApps wrapping ourselves (below) to also inject --no-sandbox.
  dontWrapGApps = true;

  unpackCmd = "dpkg-deb -x $curSrc source";
  sourceRoot = "source";

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/lib usr/share $out/

    # The raw /usr/bin/claude-desktop ELF can't find its resources/; launch the
    # canonical binary under lib/. --no-sandbox: the bundled setuid chrome-sandbox
    # can't be setuid in the read-only Nix store.
    makeWrapper $out/lib/claude-desktop/claude-desktop $out/bin/claude-desktop \
      "''${gappsWrapperArgs[@]}" \
      --add-flags "--no-sandbox" \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libGL
          vulkan-loader
        ]
      }" \
      --prefix PATH : "${lib.makeBinPath [ xdg-utils ]}"

    runHook postInstall
  '';

  meta = {
    description = "Desktop application for Claude.ai (repackaged from Anthropic's official Linux .deb)";
    homepage = "https://claude.ai";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "claude-desktop";
  };
})
