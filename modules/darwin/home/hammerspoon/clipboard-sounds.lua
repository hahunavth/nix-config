-- Play a short sound on Cmd+C (copy) and Cmd+V (paste), using the copy/paste
-- blips borrowed from the Pasty clipboard app (vendored next to this file).
--
-- The keyDown event is watched passively and NOT consumed, so the real
-- copy/paste still happens as usual. Needs Accessibility permission.

local cfg = HN.clipboardSounds
if not cfg.enable then
  return
end

local copySound = hs.sound.getByFile(cfg.copyFile)
local pasteSound = hs.sound.getByFile(cfg.pasteFile)

local cKey = hs.keycodes.map["c"]
local vKey = hs.keycodes.map["v"]

-- Kept in a global so it isn't garbage-collected.
clipboardSoundTap = hs.eventtap
  .new({ hs.eventtap.event.types.keyDown }, function(e)
    local flags = e:getFlags()
    -- Require plain Cmd (not Cmd+Shift/Ctrl/Alt), so we don't fire on unrelated
    -- combos like Cmd+Shift+C.
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
  :start()
