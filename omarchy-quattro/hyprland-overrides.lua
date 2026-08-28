-- Hyprland Lua configuration overrides for Omarchy Quattro
-- Uses the Quattro Lua API: hl.config(), o.bind(), o.window(), hl.gesture()

-- Keyboard + touchpad input configuration
hl.config({
  input = {
    -- Use Polish keyboard layout
    -- To use multiple layouts with Alt switching, uncomment and adjust:
    -- kb_layout = "us,dk,eu",
    -- kb_options = "compose:caps,grp:alts_toggle",
    kb_layout = "pl",
    kb_options = "compose:caps",

    -- Keyboard repeat speed
    repeat_rate = 40,
    repeat_delay = 600,

    -- Increase sensitivity for mouse/trackpad (default: 0)
    -- sensitivity = 0.35,

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

-- Scroll faster in the terminal (Foot is the new default in Quattro)
o.window("(foot)", { scroll_touchpad = 1.5 })
-- Keep Alacritty rule too in case it's still installed
o.window("(Alacritty)", { scroll_touchpad = 1.5 })
