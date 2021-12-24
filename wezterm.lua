local wezterm = require 'wezterm';
local DevSrv = "devbig038.cln2.facebook.com"

-- Enable config tab title with a user var
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local pane_title = tab.active_pane.title
  local user_title = tab.active_pane.user_vars.panetitle

  if user_title ~= nil and #user_title > 0 then
    pane_title = user_title
  end

  return {
    {Text="  " .. pane_title .. "  "},
  }
end)

return {
  enable_scroll_bar = true,
  exit_behavior = "Close",
  hide_tab_bar_if_only_one_tab = false,
  window_decorations = "RESIZE",

  audible_bell = "Disabled",
  visual_bell = {
    fade_in_duration_ms = 150,
    fade_out_duration_ms = 150,
    target = "CursorColor",
  },
  colors = {
    visual_bell = "#822"
  },

  keys = {
    {key="k", mods="CTRL|CMD", action=wezterm.action{ClearScrollback="ScrollbackAndViewport"}},
    {key="-", mods="CTRL|CMD", action="DecreaseFontSize"},
    {key="=", mods="CTRL|CMD", action="IncreaseFontSize"},

    {key="s", mods="CTRL|CMD", action=wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}},
    {key="h", mods="CTRL|CMD", action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}},
    {key="t", mods="CTRL|CMD", action=wezterm.action{SpawnTab="CurrentPaneDomain"}},

    {key="PageUp",   mods="CTRL|CMD", action=wezterm.action{ActivateTabRelative=-1}},
    {key="PageDown", mods="CTRL|CMD", action=wezterm.action{ActivateTabRelative=1}},
    {key="PageUp",   mods="CTRL|CMD|SHIFT", action=wezterm.action{MoveTabRelative=-1}},
    {key="PageDown", mods="CTRL|CMD|SHIFT", action=wezterm.action{MoveTabRelative=1}},

    {key="LeftArrow",  mods="CTRL|CMD", action=wezterm.action{ActivatePaneDirection="Left"}},
    {key="RightArrow", mods="CTRL|CMD", action=wezterm.action{ActivatePaneDirection="Right"}},
    {key="UpArrow",    mods="CTRL|CMD", action=wezterm.action{ActivatePaneDirection="Up"}},
    {key="DownArrow",  mods="CTRL|CMD", action=wezterm.action{ActivatePaneDirection="Down"}},

    {key="LeftArrow",  mods="CTRL|CMD|SHIFT", action=wezterm.action{AdjustPaneSize={"Left", 3}}},
    {key="RightArrow", mods="CTRL|CMD|SHIFT", action=wezterm.action{AdjustPaneSize={"Right", 3}}},
    {key="UpArrow",    mods="CTRL|CMD|SHIFT", action=wezterm.action{AdjustPaneSize={"Up", 3}}},
    {key="DownArrow",  mods="CTRL|CMD|SHIFT", action=wezterm.action{AdjustPaneSize={"Down", 3}}},

    -- Disable default bindings so Vim can intercept them instead
    {key="LeftArrow",  mods="CTRL|SHIFT", action="DisableDefaultAssignment"},
    {key="RightArrow", mods="CTRL|SHIFT", action="DisableDefaultAssignment"},
    {key="UpArrow",    mods="CTRL|SHIFT", action="DisableDefaultAssignment"},
    {key="DownArrow",  mods="CTRL|SHIFT", action="DisableDefaultAssignment"},
    {key="t",          mods="CTRL|SHIFT", action="DisableDefaultAssignment"},
  },

  hyperlink_rules = {
    {
      -- Linkify things that look like URLs
      -- This is actually the default if you don't specify any hyperlink_rules
      regex = "\\b\\w+://(?:[\\w.-]+)\\.[a-z]{2,15}\\S*\\b",
      format = "$0",
    },
    {
      -- Make task, diff and paste numbers clickable
      regex = "\\b([tTdDpP]\\d+)\\b",
      format = "https://fburl.com/b/$1",
    },
  },

  -- See: https://wezfurlong.org/wezterm/quickselect.html
  quick_select_patterns = {
    -- Make task, diff and paste numbers quick-selectable
    "\\b([tTdDpP]\\d+)\\b",
  },

  unix_domains = {
    {
      name = "local",
      connect_automatically = true,
    }
  },

  tls_clients = {
    {
      name = "devsrv",
      remote_address = DevSrv .. ":8098",
      bootstrap_via_ssh = DevSrv,
    },
  },
}
