# React Native / Expo mobile shell: `nix develop .#mobile`, or via direnv from a
# project's .envrc (`use flake /etc/nix-darwin#mobile`).
#
# This exists because the Android SDK used to be a hand-installed Homebrew cask
# on this machine, which homebrew.onActivation.cleanup = "zap" removes on every
# switch (it is not declared in modules/darwin/homebrew/). A dev shell keeps the
# whole mobile toolchain pinned by flake.lock and scoped to the project that
# needs it, instead of installed globally.
{ pkgs }:
let
  inherit (pkgs) lib;

  # androidenv needs unfree + an accepted SDK licence, and flake.nix hands the
  # shells a plain legacyPackages. Re-import the SAME locked nixpkgs (pkgs.path)
  # with only that config flipped — still pure, no --impure, no second input.
  androidPkgs = import pkgs.path {
    inherit (pkgs.stdenv.hostPlatform) system;
    config = {
      allowUnfree = true;
      android_sdk.accept_license = true;
    };
  };

  # Versions are NOT a preference — they are what the app pins. react-native
  # 0.86's gradle/libs.versions.toml asks for compileSdk 36, build-tools 36.0.0
  # and NDK 27.1.12297006; apps/expo/android/gradle.properties sets minSdk 24.
  # Bump these when the RN/Expo upgrade does, or Gradle downloads nothing and
  # simply fails (the SDK here is read-only — sdkmanager cannot fill gaps in).
  buildToolsVersion = "36.0.0";
  ndkVersion = "27.1.12297006";

  # The Mac drives a physical device over adb, so no emulator there. The
  # x86_64 Linux hosts (nixos-wsl has /dev/kvm; the window shows through WSLg)
  # also get the emulator + one API 36 image, roughly another 2 GB. Create the
  # AVD once (it lives in ~/.android/avd, outside the store):
  #   avdmanager create avd -n pixel -d pixel_7 \
  #     -k "system-images;android-36;google_apis_playstore;x86_64"
  #   emulator -avd pixel
  withEmulator = pkgs.stdenv.hostPlatform.system == "x86_64-linux";

  androidComposition = androidPkgs.androidenv.composeAndroidPackages {
    platformVersions = [
      "36"
      "35"
    ];
    buildToolsVersions = [ buildToolsVersion ];
    ndkVersions = [ ndkVersion ];
    includeNDK = true;
    includeEmulator = withEmulator;
    includeSystemImages = withEmulator;
    systemImageTypes = [ "google_apis_playstore" ];
    abiVersions = [ "x86_64" ];
    includeSources = false;
  };

  androidSdk = androidComposition.androidsdk;
  sdkRoot = "${androidSdk}/libexec/android-sdk";
in
pkgs.mkShell {
  packages = [
    androidSdk # cmdline-tools, platform-tools (adb), build-tools, NDK
    pkgs.jdk17 # Gradle 9.x / AGP: JDK 17, not the mise global (Java 25/8)
    pkgs.maestro # mobile E2E test runner
    pkgs.jadx # APK -> Java, for reading decompiled reference apps
    pkgs.apktool # APK unpack/repack
    pkgs.p7zip # 7z, occasionally needed to crack open bundles
  ]
  ++ lib.optionals pkgs.stdenv.isDarwin [
    pkgs.cocoapods # `pod install` for apps/expo/ios (system ruby 2.6 is too old)
  ];

  JAVA_HOME = pkgs.jdk17.home;
  ANDROID_HOME = sdkRoot;
  ANDROID_SDK_ROOT = sdkRoot; # deprecated by Google, still read by older tooling
  ANDROID_NDK_ROOT = "${sdkRoot}/ndk/${ndkVersion}";

  # AGP normally fetches aapt2 from Maven and runs it out of a writable dir;
  # point it at the one in the (read-only) nix SDK instead. Standard androidenv
  # workaround — without it the build fails on a sandboxed/immutable SDK.
  GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${sdkRoot}/build-tools/${buildToolsVersion}/aapt2";

  # Xcode 27 ships its own clang with libc++ bundled for SDK 27. The Nix
  # clang-wrapper that mkShell auto-injects into PATH hardcodes
  # `-cxx-isystem /nix/store/.../libcxx-21.1.6+apple-sdk-26.4/include/c++/v1`
  # and `-isysroot .../apple-sdk-14.4/.../MacOSX.sdk` — wrong SDK pairing,
  # which is what produces "undeclared FP_NAN / uint8_t" in MMKVCore's
  # OpenSSL TUs. Put Xcode's toolchain bin ahead of the wrapper in PATH so
  # xcodebuild's clang lookup finds the matching toolchain.
  # macOS only — /usr/bin/xcrun does not exist on Linux, where this hook would
  # abort the shell.
  shellHook = lib.optionalString pkgs.stdenv.isDarwin ''
    # Nix's pkgs.clang-wrapper (auto-added by mkShell) and pkgs.apple-sdk set
    # DEVELOPER_DIR / SDKROOT to point at the Nix apple-sdk 14.4 and force the
    # wrapper bin first in PATH. The wrapper hardcodes -cxx-isystem to libcxx
    # 21.1.6+apple-sdk-26.4 and -isysroot to SDK 14.4 — the wrong pairing for
    # Xcode 27.0 (SDK 27). Clear the developer/SDK vars FIRST so xcrun falls
    # back to the active Xcode, then prepend that toolchain bin ahead of the
    # Nix wrapper so `clang` (and xcrun clang) resolve to a toolchain whose
    # SDK matches what xcodebuild is targeting.
    unset DEVELOPER_DIR SDKROOT TOOLCHAINS
    export PATH="$(/usr/bin/xcrun --find clang | xargs dirname):$PATH"
  '';
}
