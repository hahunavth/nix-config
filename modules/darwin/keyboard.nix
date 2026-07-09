{ ... }:

{
  # Remap the top-left ISO key that types §/± so it types `/~ instead
  # (matches US-keyboard behavior). Applied via hidutil by nix-darwin.
  system.keyboard = {
    enableKeyMapping = true;
    nonUS.remapTilde = true;
  };
}
