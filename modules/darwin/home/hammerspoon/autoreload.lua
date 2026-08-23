-- Reload Hammerspoon when its config changes on disk.
--
-- Why this is needed here specifically: ~/.hammerspoon/*.lua are home-manager
-- symlinks into the nix store, and Hammerspoon reads them exactly once, at
-- launch. A `darwin-rebuild switch` repoints the symlinks at new store paths but
-- the running app keeps executing the OLD Lua until someone clicks Reload Config
-- in the menu bar -- so an edit to the nix module silently appears to do nothing.
-- FSEvents reports the symlink swap as a change to the file path, which is what
-- this watches.
--
-- Kept in a global so the watcher isn't garbage-collected.

local pending = nil

local function touchedLua(paths)
  for _, p in ipairs(paths) do
    if p:sub(-4) == ".lua" then
      return true
    end
  end
  return false
end

hnConfigWatcher = hs.pathwatcher
  .new(hs.configdir, function(paths)
    -- The watch is recursive, so sounds/ and any other asset also report here;
    -- only Lua changes are worth a reload.
    if not touchedLua(paths) then
      return
    end
    -- A switch rewrites several symlinks in quick succession; coalesce them into
    -- one reload instead of reloading once per file.
    if pending then
      pending:stop()
    end
    pending = hs.timer.doAfter(1.0, hs.reload)
  end)
  :start()
