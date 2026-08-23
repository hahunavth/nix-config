-- Toast: a small notification card in the bottom-right corner.
--
-- Replaces hs.alert (a black lozenge in the middle of the screen, one line, no
-- hierarchy) for anything this config wants to say. An hs.canvas is used rather
-- than hs.alert because alert offers no way to draw the accent bar or set two
-- text tiers -- its style table is a single font/colour for the whole string.
--
--   Toast({ title = "ext_ssd", detail = "mounted at /Volumes", kind = "success" })
--
-- kind selects the accent colour: "success" | "error" | "info" (default "info").
-- Concurrent toasts stack upward from the bottom-right, newest nearest the
-- corner; each auto-dismisses, and a click dismisses early.

local FONTS = hs.styledtext.defaultFonts
local TITLE_FONT = { name = FONTS.boldSystem.name, size = 14 }
local DETAIL_FONT = { name = FONTS.userFixedPitch.name, size = 12 }

local OPACITY = 0.90 -- card opacity; text rides on top at full strength
local BG = { white = 0.04, alpha = OPACITY }
local BORDER = { white = 1.00, alpha = 0.08 }
local TITLE_COLOR = { white = 1.00, alpha = 1.00 }
local DETAIL_COLOR = { white = 1.00, alpha = 0.55 }

local ACCENTS = {
  success = { red = 0.19, green = 0.82, blue = 0.35, alpha = 1.0 },
  error = { red = 1.00, green = 0.27, blue = 0.23, alpha = 1.0 },
  info = { red = 0.04, green = 0.52, blue = 1.00, alpha = 1.0 },
}

-- No drop shadow: hs.canvas clips to its own bounds, so a shadow needs the card
-- inset inside a larger transparent canvas. That halo is dead space that still
-- swallows clicks, and against a dark desktop the shadow it buys is invisible.
local BAR = 3 -- accent bar width
local PAD_X = 14 -- text inset either side (from the bar, and from the right edge)
local PAD_Y = 11
local LINE_GAP = 3
-- Square corners in the drawing. Note macOS composites every window with its own
-- corner rounding, so on screen the card still reads slightly rounded no matter
-- what this is set to -- the system radius acts as a floor. Raising RADIUS above
-- it does show; lowering it below has no visible effect. hs.canvas exposes no
-- control over the window-level rounding (wantsLayer makes no difference).
local RADIUS = 0
local MIN_W, MAX_W = 210, 420
local MARGIN = 24 -- gap from the screen edge
local STACK_GAP = 10 -- gap between stacked toasts
local SLIDE_TIME = 0.18
local SLIDE_PX = 16 -- how far the card travels on the way in
local FADE_OUT = 0.15
local DEFAULT_DURATION = 2.2

-- Newest last. Position is derived from this list, so it is the single source
-- of truth for the stack.
local active = {}

local function styled(text, font, color)
  return hs.styledtext.new(text, { font = font, color = color })
end

local function measure(styledText)
  local size = hs.drawing.getTextDrawingSize(styledText)
  -- getTextDrawingSize measures the glyphs tightly; a little slack keeps
  -- descenders and the last character off the edge.
  return math.ceil(size.w) + 2, math.ceil(size.h) + 2
end

-- Recompute every toast's resting position: newest nearest the corner, older
-- ones pushed up by whatever is below them. Toasts still sliding in read
-- `target` on each animation tick, so they follow a relayout instead of
-- fighting it.
local function relayout()
  local offset = 0
  for i = #active, 1, -1 do
    local t = active[i]
    local f = t.screenFrame
    t.target = {
      x = f.x + f.w - t.w - MARGIN,
      y = f.y + f.h - t.h - MARGIN - offset,
    }
    if not t.anim then
      t.canvas:topLeft(t.target)
    end
    offset = offset + t.h + STACK_GAP
  end
end

local function dismiss(t)
  if t.dismissed then
    return
  end
  t.dismissed = true
  if t.timer then
    t.timer:stop()
  end
  if t.anim then
    t.anim:stop()
    t.anim = nil
  end
  t.canvas:hide(FADE_OUT)
  hs.timer.doAfter(FADE_OUT + 0.05, function()
    t.canvas:delete()
  end)
  for i, other in ipairs(active) do
    if other == t then
      table.remove(active, i)
      break
    end
  end
  relayout()
end

local function slideIn(t)
  t.canvas:topLeft({ x = t.target.x, y = t.target.y + SLIDE_PX })
  t.canvas:show(SLIDE_TIME)

  local steps, step = 12, 0
  t.anim = hs.timer.doEvery(SLIDE_TIME / steps, function()
    step = step + 1
    local p = math.min(step / steps, 1)
    local eased = 1 - (1 - p) ^ 3 -- easeOutCubic: fast start, soft landing
    t.canvas:topLeft({
      x = t.target.x,
      y = t.target.y + SLIDE_PX * (1 - eased),
    })
    if p >= 1 and t.anim then
      t.anim:stop()
      t.anim = nil
      t.canvas:topLeft(t.target) -- settle exactly on target
    end
  end)
end

function Toast(opts)
  opts = opts or {}
  local title = opts.title or ""
  local detail = opts.detail
  local accent = ACCENTS[opts.kind or "info"] or ACCENTS.info
  local duration = opts.duration or DEFAULT_DURATION

  local titleText = styled(title, TITLE_FONT, TITLE_COLOR)
  local titleW, titleH = measure(titleText)

  local detailText, detailW, detailH
  if detail and detail ~= "" then
    detailText = styled(detail, DETAIL_FONT, DETAIL_COLOR)
    detailW, detailH = measure(detailText)
  end

  local maxTextW = MAX_W - BAR - PAD_X * 2
  local textW = math.min(math.max(titleW, detailW or 0), maxTextW)
  local w = math.max(BAR + PAD_X * 2 + textW, MIN_W)
  local h = PAD_Y * 2 + titleH + (detailText and (LINE_GAP + detailH) or 0)

  -- mainScreen is the one with keyboard focus, so the toast lands on the
  -- display being worked on rather than always the primary.
  local screenFrame = hs.screen.mainScreen():frame()

  local c = hs.canvas.new({ x = 0, y = 0, w = w, h = h })
  local rounded = { xRadius = RADIUS, yRadius = RADIUS }
  local ox, oy = 0, 0
  local card = { x = ox, y = oy, w = w, h = h }

  local elements = {
    {
      type = "rectangle",
      action = "fill",
      fillColor = BG,
      frame = card,
      roundedRectRadii = rounded,
    },
    -- Clip to the card so the accent bar can't spill past its edges.
    { type = "rectangle", action = "clip", frame = card, roundedRectRadii = rounded },
    { type = "rectangle", action = "fill", fillColor = accent, frame = { x = ox, y = oy, w = BAR, h = h } },
    { type = "resetClip" },
    {
      type = "rectangle",
      action = "stroke",
      strokeColor = BORDER,
      strokeWidth = 1,
      frame = card,
      roundedRectRadii = rounded,
    },
    {
      type = "text",
      text = titleText,
      frame = { x = ox + BAR + PAD_X, y = oy + PAD_Y, w = textW, h = titleH },
    },
  }
  if detailText then
    elements[#elements + 1] = {
      type = "text",
      text = detailText,
      frame = { x = ox + BAR + PAD_X, y = oy + PAD_Y + titleH + LINE_GAP, w = textW, h = detailH },
    }
  end
  c:replaceElements(table.unpack(elements))

  c:level(hs.canvas.windowLevels.overlay)
  c:behaviorAsLabels({ "canJoinAllSpaces", "stationary" })
  c:clickActivating(false) -- dismissing a toast shouldn't focus Hammerspoon

  local t = { canvas = c, w = w, h = h, screenFrame = screenFrame }

  c:canvasMouseEvents(false, true) -- mouseUp only
  c:mouseCallback(function()
    dismiss(t)
  end)

  active[#active + 1] = t
  relayout()
  slideIn(t)
  t.timer = hs.timer.doAfter(duration, function()
    dismiss(t)
  end)

  return t
end

return Toast
