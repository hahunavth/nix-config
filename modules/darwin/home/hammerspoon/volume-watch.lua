-- React to a watched external volume mounting / unmounting.
--
-- Unplugging an external drive is a silent event on macOS: nothing tells you the
-- volume went away, you just start getting errors (see stale-cwd.nix for what it
-- does to a shell). hs.fs.volume delivers the mount/unmount event directly, with
-- the mount point, so a replug can announce itself and re-run whatever needs
-- re-binding to the fresh mount.
--
-- The classic consumer is Service Station's Finder extension, whose sandbox
-- bookmark is tied to a mount *instance* and goes stale on replug; onMount
-- reloads it via pluginkit (see hosts/macbook/home.nix). This replaced a
-- launchd WatchPaths agent that did the same job -- one volume event, one
-- place, no agent.
--
-- What this canNOT do is repair a shell whose cwd died with the volume: a cwd
-- is a live per-process reference and only that process's own chdir(2)
-- re-resolves it. That half is hn.staleCwdRecovery (stale-cwd.nix).
--
-- Kept in a global so the watcher isn't garbage-collected.

local cfg = HN.volumeWatch
if not cfg.enable then
  return
end

-- Only the configured mount points; unrelated .dmg / network / USB mounts are
-- ignored, so nothing fires when a random disk image is opened.
local watched = {}
for _, path in ipairs(cfg.volumes) do
  watched[path] = true
end

local function announce(title, detail, kind)
  if cfg.notify then
    -- A drawn canvas rather than hs.notify: it needs no notification
    -- permission and shows up even in Do Not Disturb.
    Toast({ title = title, detail = detail, kind = kind })
  end
end

local function run(command, label)
  if command == "" then
    return
  end
  hs.task
    .new("/bin/sh", function(exitCode, _, stderr)
      if exitCode ~= 0 then
        hs.printf("volume-watch: %s exited %d: %s", label, exitCode, stderr or "")
      end
    end, { "-c", command })
    :start()
end

hnVolumeWatcher = hs.fs.volume
  .new(function(event, info)
    local path = info and (info.path or info.NSDevicePath)
    if not path or not watched[path] then
      return
    end
    local name = path:match("([^/]+)$") or path

    if event == hs.fs.volume.didMount then
      announce(name, "mounted at " .. path, "success")
      run(cfg.onMount, "onMount")
    elseif event == hs.fs.volume.didUnmount then
      announce(name, "ejected", "error")
      run(cfg.onUnmount, "onUnmount")
    end
  end)
  :start()
