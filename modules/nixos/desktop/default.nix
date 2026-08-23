# Reusable GUI layer for NixOS desktop hosts: XFCE on Xorg, plus sound,
# printing and VM guest integration.
#
# Not in modules/nixos (which every Linux host gets) because the OrbStack VM is
# headless — a host opts in by importing this, e.g.
# hosts/nixos-desktop/default.nix.
#
# XFCE on Xorg, NOT GNOME, and both halves of that matter: GNOME 50 in nixpkgs
# 26.05 is Wayland-only, and Wayland is the wrong choice here because these are
# VMs reached over xrdp — which serves an X session. Anything expecting GNOME
# will find xfce4-session instead.
#
# Option names verified against NixOS 26.05 (several moved out of
# services.xserver in recent releases).
{ ... }:

{
  # Xorg, not Wayland — see the header: xrdp serves an X session.
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";

  # LightDM + XFCE. defaultSession has to be set explicitly, or the greeter
  # picks one and a remote xrdp login can land in a different session than a
  # local one.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.displayManager.defaultSession = "xfce";

  # VM guest integration for QEMU/KVM/SPICE (clipboard + display auto-resize).
  # Harmless where unused: nixos-desktop runs under VirtualBox and gets
  # `virtualisation.virtualbox.guest.enable` from its GENERATED
  # hardware-configuration.nix, so these two just sit inert there. Add
  # `virtualisation.vmware.guest.enable` per host if a VMware host ever shows up.
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # PipeWire, with PulseAudio explicitly off — they claim the same devices, so
  # leaving both enabled gives whichever won the race. rtkit lets PipeWire get
  # realtime priority, without which audio crackles under load.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Printing.
  services.printing.enable = true;

  # No browser and no apps here on purpose: this layer is the desktop, and what
  # runs on it is the host's choice (nixos-desktop installs Chrome and the rest
  # in its own home.nix).
}
