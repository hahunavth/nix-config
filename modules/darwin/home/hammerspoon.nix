# Hammerspoon: play a short sound on Cmd+C / Cmd+V, using the copy/paste
# blips borrowed from the Pasty clipboard app (vendored under ./hammerspoon/).
#
# The app itself is installed via Homebrew (see modules/darwin/homebrew/
# casks/system.nix). On first launch, grant Hammerspoon Accessibility
# permission (System Settings → Privacy & Security → Accessibility) — the key
# watcher needs it, and it can't be granted declaratively.
{ config, lib, ... }:

lib.mkIf config.hn.hammerspoon.enable {
  # Vendored sound assets, placed next to the config.
  home.file.".hammerspoon/sounds/copy.mp3".source = ./hammerspoon/copy.mp3;
  home.file.".hammerspoon/sounds/paste.mp3".source = ./hammerspoon/paste.mp3;

  home.file.".hammerspoon/init.lua".text = ''
    -- Play a sound on Cmd+C (copy) and Cmd+V (paste).
    -- The keyDown event is watched passively and NOT consumed, so the real
    -- copy/paste still happens as usual.
    local soundsDir  = os.getenv("HOME") .. "/.hammerspoon/sounds/"
    local copySound  = hs.sound.getByFile(soundsDir .. "copy.mp3")
    local pasteSound = hs.sound.getByFile(soundsDir .. "paste.mp3")

    local cKey = hs.keycodes.map["c"]
    local vKey = hs.keycodes.map["v"]

    -- Kept in a global so it isn't garbage-collected.
    clipboardSoundTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
      local flags = e:getFlags()
      -- Require plain Cmd (not Cmd+Shift/Ctrl/Alt), so we don't fire on
      -- unrelated combos like Cmd+Shift+C.
      if flags.cmd and not (flags.shift or flags.ctrl or flags.alt) then
        local code = e:getKeyCode()
        if code == cKey and copySound then
          copySound:stop():play()
        elseif code == vKey and pasteSound then
          pasteSound:stop():play()
        end
      end
      return false -- pass the event through
    end)
    clipboardSoundTap:start()
  '';
}
