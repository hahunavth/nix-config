# OpenCode Desktop for Linux — repackaged from the upstream .deb.
#
# Not in nixpkgs, and the desktop app is only published as .deb/.rpm/AppImage,
# none of which NixOS can consume directly. So: fetch the pinned amd64 .deb,
# unpack it, autoPatchelf the bundled Electron binary under /opt/OpenCode against
# the Nix equivalents of what it links, and wrap the launcher. The JS bundle is
# used as shipped — nothing is rebuilt from source.
#
# Same shape as ../claude-desktop, and the same trade: a binary repack tracks
# upstream releases by hand rather than being built reproducibly.
#
# The terminal CLI is unrelated and comes from nixpkgs (`opencode`).
#
# Update: bump `version`, rebuild, paste the hash Nix reports in the error.
# Assets: https://github.com/anomalyco/opencode/releases
# (opencode-desktop-linux-amd64.deb).
#
# x86_64-linux only (for the nixos-desktop VM); guarded in pkgs/default.nix so
# it never evaluates on the Mac.
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
  pname = "opencode-desktop";
  version = "1.17.18";

  src = fetchurl {
    url = "https://github.com/anomalyco/opencode/releases/download/v${finalAttrs.version}/opencode-desktop-linux-amd64.deb";
    hash = "sha256-wwHZgER2W2rW2/ZQpsHT23PulRyBcfxrtA3qp7mkWoM=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
    makeWrapper
  ];

  # Debian `Depends` + the standard Electron/Chromium runtime the bundled binary
  # DT_NEEDEDs. autoPatchelfHook rewrites the ELF rpaths to these.
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

  # dlopen'd at runtime (GPU/video) — not in DT_NEEDED.
  runtimeDependencies = [
    libGL
    vulkan-loader
    libnotify
  ];

  # The .deb bundles musl builds of some optional node addons (@parcel/watcher,
  # @msgpackr-extract) alongside their glibc builds. On glibc NixOS the musl ones
  # are never loaded, so ignore their unresolvable musl libc rather than failing.
  autoPatchelfIgnoreMissingDeps = [ "libc.musl-x86_64.so.1" ];

  # We wrap ourselves (below) to also inject --no-sandbox.
  dontWrapGApps = true;

  unpackCmd = "dpkg-deb -x $curSrc source";
  sourceRoot = "source";

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r opt $out/opt
    cp -r usr/share $out/share

    # --no-sandbox: the bundled setuid chrome-sandbox can't be setuid in the
    # read-only Nix store.
    makeWrapper $out/opt/OpenCode/ai.opencode.desktop $out/bin/opencode-desktop \
      "''${gappsWrapperArgs[@]}" \
      --add-flags "--no-sandbox" \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libGL
          vulkan-loader
        ]
      }" \
      --prefix PATH : "${lib.makeBinPath [ xdg-utils ]}"

    # Point the .desktop entries at the wrapped launcher instead of /opt.
    substituteInPlace $out/share/applications/*.desktop \
      --replace-warn "/opt/OpenCode/ai.opencode.desktop" "$out/bin/opencode-desktop"

    runHook postInstall
  '';

  meta = {
    description = "OpenCode Desktop — open-source AI coding agent (repackaged from the upstream .deb)";
    homepage = "https://opencode.ai";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "opencode-desktop";
  };
})
