{ stdenv, fetchurl }:

# Atlassian Plugin SDK pinned to an exact version. Homebrew's tap is unreliable
# (several versioned formulae have mismatched Ruby class names and the atlas-*
# binaries collide on link), so we fetch and unpack the official tarball
# ourselves. atlas-* scripts land in $out/bin. Instantiate per version with
# { version, url, hash }. Needs a JDK on PATH at runtime (per-project via mise).
{
  version,
  url,
  hash,
}:

stdenv.mkDerivation {
  pname = "atlassian-plugin-sdk";
  inherit version;

  src = fetchurl { inherit url hash; };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -R . $out/
    rm -f $out/bin/*.bat
    runHook postInstall
  '';
}
