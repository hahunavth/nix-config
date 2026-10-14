# Orca — IDE for orchestrating AI coding agents (stablyai/orca), from the
# upstream AppImage. The Mac gets it as a Homebrew cask; Linux has no nixpkgs
# package (nixpkgs `orca` is the unrelated GNOME screen reader — hence the
# `orca-ide` pname, matching upstream's .deb name).
#
# appimageTools.wrapType2 runs the AppImage inside an FHS env that already
# carries the usual Electron runtime libraries, so nothing is patchelf'd.
#
# Update: bump `version`, then take the new sha256 from the release asset's
# digest on GitHub (or paste the hash Nix reports on mismatch).
{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "orca-ide";
  version = "1.4.224";

  src = fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v${version}/orca-linux.AppImage";
    hash = "sha256-sf6RAtmH012X622cJ0qT2elRqtvoZPwiUaMVAj9gx0Y=";
  };

  contents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # Desktop entry + icons, so WSLg adds Orca to the Windows Start menu.
  extraInstallCommands = ''
    desktop=$(find ${contents} -maxdepth 1 -name '*.desktop' | head -1)
    if [ -n "$desktop" ]; then
      install -Dm644 "$desktop" $out/share/applications/${pname}.desktop
      sed -i -E 's|^Exec=[^ ]+|Exec=${pname}|' $out/share/applications/${pname}.desktop
    fi
    if [ -d ${contents}/usr/share/icons ]; then
      cp -r ${contents}/usr/share/icons $out/share/
    fi
  '';

  meta = {
    description = "IDE for orchestrating AI coding agents across terminals and worktrees";
    homepage = "https://github.com/stablyai/orca";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
