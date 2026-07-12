# Reusable GUI layer for NixOS desktop hosts: GNOME on Wayland + VM guest tools.
# Imported by a host's per-host bundle (e.g. hosts/nixos-desktop/default.nix).
# Option names verified against NixOS 25.11/26.05.
{ ... }:

{
  # X server is still the umbrella for keymap/GNOME even on Wayland.
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";

  # GDM display manager + GNOME desktop.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

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
