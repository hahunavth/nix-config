# Reusable GUI layer for NixOS desktop hosts: XFCE on Xorg + VM guest tools.
# Imported by a host's per-host bundle (e.g. hosts/nixos-desktop/default.nix).
#
# XFCE (Xorg) rather than GNOME: GNOME 50 (nixpkgs 26.05) is Wayland-only, and an
# Xorg session is what works reliably under VMs and with xrdp.
# Option names verified against NixOS 26.05.
{ ... }:

{
  # X server + keymap.
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";

  # LightDM display manager + XFCE desktop (both Xorg).
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.displayManager.defaultSession = "xfce";

  # VM guest integration. Default = QEMU/KVM/SPICE (clipboard + display
  # auto-resize). For a different hypervisor swap these for
  # `virtualisation.vmware.guest.enable` or `virtualisation.virtualbox.guest.enable`.
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # Sound via PipeWire (replaces PulseAudio).
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

  # No browser here — each host picks its own (e.g. nixos-desktop installs Chrome).
}
