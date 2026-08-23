-- Route opened links to a browser chosen by hostname.
--
-- macOS only has one default browser, so a link is all-or-nothing. Making
-- Hammerspoon the registered http/https handler (done in nix, via
-- hn.defaultBrowser.handler = "hammerspoon") turns that single choice into a
-- dispatch point: every link lands here first and is forwarded to a real browser
-- by rule, falling back to HN.urlRouter.fallback.
--
-- Consequence worth knowing: while Hammerspoon is the system handler, links only
-- open if Hammerspoon is running. setRestoreHandler below covers a clean quit
-- (macOS hands the handler back to the fallback browser); init.lua turns on
-- launch-at-login to cover the reboot case.

local cfg = HN.urlRouter
if not cfg.enable then
  return
end

-- Give the handler back to the real browser when Hammerspoon exits, so quitting
-- it doesn't leave every link dead.
hs.urlevent.setRestoreHandler("http", cfg.fallback)

-- Rules are matched in declaration order; `hosts` entries are Lua patterns
-- tested against the lowercased hostname (no port, no scheme).
local function pick(host)
  host = (host or ""):lower()
  for _, rule in ipairs(cfg.rules) do
    for _, pattern in ipairs(rule.hosts) do
      if host:match(pattern) then
        return rule.bundleId
      end
    end
  end
  return cfg.fallback
end

hs.urlevent.httpCallback = function(_scheme, host, _params, fullURL)
  local bundleId = pick(host)
  if not hs.urlevent.openURLWithBundle(fullURL, bundleId) then
    -- Target browser missing or refused the open: never drop the link.
    hs.printf("url-router: %s could not open %s, falling back", bundleId, fullURL)
    hs.urlevent.openURLWithBundle(fullURL, cfg.fallback)
  end
end
