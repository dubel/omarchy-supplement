-- Hyprland Lua configuration overrides for Omarchy 4.x
-- Uses the Omarchy Lua API: hl.config(), o.bind(), o.rebind(), o.window(), hl.gesture()

-- Keyboard + touchpad input configuration
hl.config({
  input = {
    -- Use Polish keyboard layout
    kb_layout = "pl",
    kb_options = "compose:caps",

    -- Keyboard repeat speed
    repeat_rate = 40,
    repeat_delay = 600,

    -- Touchpad settings
    touchpad = {
      -- Use natural (inverse) scrolling
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner
      clickfinger_behavior = true,

      -- Control the speed of your scrolling
      scroll_factor = 0.4,
    },
  },
})

-- Enable touchpad gestures for changing workspaces (3-finger horizontal swipe)
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Scroll faster in the terminal (Foot is default, keep Alacritty as fallback)
o.window("(foot)", { scroll_touchpad = 1.5 })
o.window("(Alacritty)", { scroll_touchpad = 1.5 })

-- ==============================================================================
-- macOS-style browser tab shortcuts for Chromium & Google Chrome
-- ==============================================================================
local function send_keys(mods, key)
  hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))
  hl.timer(function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
  end, { timeout = 50, type = "oneshot" })
end

local function is_browser()
  local window = hl.get_active_window()
  local class = ((window and window.class) or ""):lower()
  return class:match("chromium") or class:match("chrome")
end

-- SUPER + T -> New tab in browser (Ctrl+T) or toggle floating elsewhere
o.rebind("SUPER + T", "Browser new tab or toggle float", function()
  if is_browser() then
    send_keys("CTRL", "T")
  else
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
  end
end)

-- SUPER + W -> Close tab in browser (Ctrl+W) or close window elsewhere
-- (Note: SUPER + Q still closes the whole browser window, matching macOS Cmd+Q)
o.rebind("SUPER + W", "Browser close tab or close window", function()
  if is_browser() then
    send_keys("CTRL", "W")
  else
    hl.dispatch(hl.dsp.window.close())
  end
end)

-- SUPER + SHIFT + T -> Reopen closed tab in browser (Ctrl+Shift+T)
o.rebind("SUPER + SHIFT + T", "Browser reopen closed tab", function()
  if is_browser() then
    send_keys("CTRL SHIFT", "T")
  end
end)

-- SUPER + F -> Find (Ctrl+F) in any app, like macOS Cmd+F
-- (foot uses Ctrl+Shift+R for scrollback search; Ctrl+F there is forward-char)
o.rebind("SUPER + F", "Find (Ctrl+F)", function()
  local window = hl.get_active_window()
  local class = ((window and window.class) or ""):lower()
  if class:match("foot") then
    send_keys("CTRL SHIFT", "R")
  else
    send_keys("CTRL", "F")
  end
end)

-- SUPER + CTRL + F -> Full screen in any app, like macOS Cmd+Ctrl+F
o.rebind("SUPER + CTRL + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- SUPER + CTRL + SHIFT + F -> Tiled full screen (moved off SUPER + CTRL + F)
o.rebind("SUPER + CTRL + SHIFT + F", "Tiled full screen", "omarchy-hyprland-window-tiled-fullscreen-toggle")
