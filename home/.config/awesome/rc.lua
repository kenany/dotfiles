local gears = require("gears")

-- Widgets
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
awful.rules = require("awful.rules")
awful.autofocus = require("awful.autofocus")
local hotkeys_popup = require("awful.hotkeys_popup").widget

-- themes
local beautiful = require("beautiful")

-- notifications
local naughty = require("naughty")
local menubar = require("menubar")

-- locale
os.setlocale("en_US.UTF-8")

-- Error handling
--
-- Check if awesome encountered an error during startup and fell back to
-- another config (this code will only ever execute for the fallback config).
if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors
  })
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error", function(err)

    -- Make sure we don't go into an endless error loop
    if in_error then
      return
    end

    in_error = true

    naughty.notify({
      preset = naughty.config.presets.critical,
      title = "Oops, an error happened!",
      text = err
    })

    in_error = false
  end)
end

-- This is used later as the default terminal and editor to run.
local terminal = "urxvt"
local browser = os.getenv("BROWSER") or "chromium"
local editor = os.getenv("EDITOR") or "nano"
local editor_cmd = terminal .. " -e " .. editor

-- Default modkey
--
-- Usually, Mod4 is the key with a logo between Control and Alt. If you do not
-- like this or do not have such a key, I suggest you to remap Mod4 to another
-- key using xmodmap or other tools. However, you can use another modifier like
-- Mod1, but it may interact with others.
local modkey = "Mod4"

-- Table of layouts to cover with `awful.layout.inc`; order matters.
local layouts = {
  awful.layout.suit.floating,
  awful.layout.suit.tile,
  lain.layout.centerwork
}

-- Themes define colours, icons, and wallpapers
beautiful.init("/home/kenan/.config/awesome/theme.lua")

-- Wallpaper
local function set_wallpaper(s)
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper

    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

-- Define a tag table which hold all screen tags.
local tags = {
  names = {" 1 ", " 2 ", " 3 ", " 4 ", " 5 "},
  layout = {layouts[2], layouts[2], layouts[2], layouts[2], layouts[2]}
}

for s = 1, screen.count() do

  -- Each screen has its own tag table.
  tags[s] = awful.tag(tags.names, s, tags.layout)
end

-- Create a laucher widget and a main menu
local myawesomemenu = {
  {"manual", terminal .. " -e man awesome"},
  {"edit config", editor_cmd .. " " .. awesome.conffile},
  {"restart", awesome.restart },
  {"quit", awesome.quit}
}

local mymainmenu = awful.menu({
  items = {
    {"awesome", myawesomemenu, beautiful.awesome_icon},
    {"terminal", terminal},
    {"chromium", browser}
  }
})

-- Set the terminal for applications that require it.
menubar.utils.terminal = terminal

-- Widget separators
local separator = wibox.widget.textbox()
separator:set_markup("<span color=\"#A9D7F2\"> || </span>")
local space = wibox.widget.textbox()
space:set_text("  ")

-- batteries
local markup = lain.util.markup
local batteryWidget = lain.widgets.bat({
  batteries = {"BAT0", "BAT1"},
  settings = function()
    widget:set_markup(markup("#d0d0d0", "&#xf240; " .. bat_now.n_perc[1] .. "% "
      .. bat_now.n_perc[2] .. "% "))
  end
})

-- brightness
local brightnessWidget = lain.widgets.abase({
  cmd = "xbacklight",
  settings = function()
    widget:set_markup(markup("#d0d0d0", "☀ "
      .. math.floor(tonumber(output)) .. "% "))
  end
})

-- cpu
local cpuwidget = lain.widgets.cpu({
  settings = function()
    widget:set_markup(markup("#d0d0d0", "&#xf0e4; " .. cpu_now.usage .. "% "))
  end
})

-- mpd
local mpdwidget = lain.widgets.mpd({
  settings = function()
    mpd_notification_preset = {
      text = string.format("%s [%s] - %s\n%s", mpd_now.artist, mpd_now.album,
        mpd_now.date, mpd_now.title)
    }

    local artist, title
    if mpd_now.state == "play" then
      artist = mpd_now.artist .. " > "
      title  = mpd_now.title .. " "
    elseif mpd_now.state == "pause" then
      artist = "mpd "
      title  = "paused "
    else
      artist = ""
      title  = ""
    end

    widget:set_markup(markup("#e54c62", artist) .. markup("#b2b2b2", title))
  end
})

-- clock and date
local mytextclock = lain.widgets.abase({
  cmd = "date +'%I:%M %p - %Y-%m-%d (%A)'",
  settings = function()
    local t_output = ""
    local o_it = string.gmatch(output, "%S+")

    for i = 1, 3 do
      t_output = t_output .. " " .. o_it(i)
    end

    widget:set_markup(markup("#d0d0d0", output))
  end
})

-- display calendar when hovering over date
lain.widgets.calendar.attach(mytextclock, {font_size = 10})

local taglist_buttons = awful.util.table.join(
  awful.button({}, 1, function(t) t:view_only() end),
  awful.button({modkey}, 1, function(t)
    if client.focus then
      client.focus:move_to_tag(t)
    end
  end),
  awful.button({}, 3, awful.tag.viewtoggle),
  awful.button({modkey}, 3, function(t)
    if client.focus then
      client.focus:toggle_tag(t)
    end
  end),
  awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
  awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = awful.util.table.join(
  awful.button({}, 1, function(c)
    if c == client.focus then
      c.minimized = true
    else
      -- Without this, the following `:isvisible()` makes no sense.
      c.minimized = false
      if not c:isvisible() and c.first_tag then
        c.first_tag:view_only();
      end

      -- This will also un-minimize the client, if needed.
      client.focus = c
      c:raise()
    end
  end),

  awful.button({}, 3, function()
    if instance then
      instance:hide()
      instance = nil
    else
      instance = awful.menu.clients({ width=250 })
    end
  end),

  awful.button({}, 4, function()
    awful.client.focus.byidx(1)
    if client.focus then
      client.focus:raise()
    end
  end),

  awful.button({}, 5, function()
    awful.client.focus.byidx(-1)
    if client.focus then
      client.focus:raise()
    end
  end)
)

awful.screen.connect_for_each_screen(function(s)
  set_wallpaper(s)

  -- Create a promptbox for each screen.
  s.mypromptbox = awful.widget.prompt()

  -- Create an imagebox widget which will contains an icon indicating which
  -- layout we're using. We need one layoutbox per screen.
  s.mylayoutbox = awful.widget.layoutbox(s)
  s.mylayoutbox:buttons(awful.util.table.join(
    awful.button({}, 1, function() awful.layout.inc(layouts, 1) end),
    awful.button({}, 3, function() awful.layout.inc(layouts, -1) end),
    awful.button({}, 4, function() awful.layout.inc(layouts, 1) end),
    awful.button({}, 5, function() awful.layout.inc(layouts, -1) end)
  ))

  -- Create a taglist widget.
  s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all,
    taglist_buttons)

  -- Create a tasklist widget.
  s.mytasklist = awful.widget.tasklist(s,
    awful.widget.tasklist.filter.currenttags, tasklist_buttons)

  -- Create the top wibox.
  s.mywibox = awful.wibar({ position = "top", screen = s })

  -- Widgets that are aligned to the left.
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(s.mytaglist)
  left_layout:add(s.mypromptbox)

  -- Widgets that are aligned to the right.
  local right_layout = wibox.layout.fixed.horizontal()
  right_layout:add(space)
  right_layout:add(mpdwidget)
  right_layout:add(cpuwidget)
  right_layout:add(brightnessWidget)
  right_layout:add(batteryWidget)
  right_layout:add(mytextclock)
  right_layout:add(s.mylayoutbox)

  -- Now bring it all together (with the tasklist in the middle).
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_middle(s.mytasklist)
  layout:set_right(right_layout)

  s.mywibox:set_widget(layout)

  -- Create the bottom wibox
  s.mywibox = awful.wibox({position = "bottom", screen = s})

  -- Widgets that are aligned to the right.
  local right_layout = wibox.layout.fixed.horizontal()
  if s == 1 then right_layout:add(wibox.widget.systray()) end

  -- Now bring it all together.
  local layout = wibox.layout.align.horizontal()
  layout:set_right(right_layout)

  s.mywibox:set_widget(layout)
end)

-- Mouse bindings
root.buttons(awful.util.table.join(
  awful.button({}, 3, function() mymainmenu:toggle() end),
  awful.button({}, 4, awful.tag.viewnext),
  awful.button({}, 5, awful.tag.viewprev)
))

-- Key bindings
local globalkeys = awful.util.table.join(
  awful.key({modkey}, "s", hotkeys_popup.show_help, {
    description = "show help",
    group = "awesome"
  }),
  awful.key({modkey}, "Left", awful.tag.viewprev, {
    description = "view previous",
    group = "tag"
  }),
  awful.key({modkey}, "Right", awful.tag.viewnext, {
    description = "view next",
    group = "tag"
  }),
  awful.key({modkey}, "Escape", awful.tag.history.restore, {
    description = "go back",
    group = "tag"
  }),

  awful.key({modkey}, "j", function() awful.client.focus.byidx(1) end, {
    description = "focus next by index",
    group = "client"
  }),
  awful.key({modkey}, "k", function() awful.client.focus.byidx(-1) end, {
    description = "focus previous by index",
    group = "client"
  }),
  awful.key({modkey}, "w", function() mymainmenu:show() end, {
    description = "show main menu",
    group = "awesome"
  }),

  -- Layout manipulation
  awful.key({modkey, "Shift"}, "j", function() awful.client.swap.byidx(1) end, {
    description = "swap with next client by index",
    group = "client"
  }),
  awful.key({modkey, "Shift"}, "k", function() awful.client.swap.byidx(-1) end,
    {description = "swap with previous client by index", group = "client"}
  ),
  awful.key({modkey, "Control"}, "j",
    function()
      awful.screen.focus_relative(1)
    end,
    {description = "focus the next screen", group = "screen"}
  ),
  awful.key({modkey, "Control"}, "k",
    function()
      awful.screen.focus_relative(-1)
    end,
    {description = "focus the previous screen", group = "screen"}
  ),
  awful.key({modkey}, "u", awful.client.urgent.jumpto, {
    description = "jump to urgent client",
    group = "client"
  }),
  awful.key({modkey}, "Tab",
    function ()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end,
    {description = "go back", group = "client"}
  ),

  -- Standard program
  awful.key({modkey}, "Return", function() awful.spawn(terminal) end, {
    description = "open a terminal",
    group = "launcher"
  }),
  awful.key({modkey, "Control"}, "r", awesome.restart, {
    description = "reload awesome",
    group = "awesome"
  }),
  awful.key({modkey, "Shift"}, "q", awesome.quit, {
    description = "quit awesome",
    group = "awesome"
  }),

  awful.key({modkey}, "l", function() awful.tag.incmwfact(0.05) end, {
    description = "increase master width factor",
    group = "layout"
  }),
  awful.key({modkey}, "h", function() awful.tag.incmwfact(-0.05) end, {
    description = "decrease master width factor",
    group = "layout"
  }),
  awful.key({modkey, "Shift"}, "h",
    function()
      awful.tag.incnmaster(1, nil, true)
    end,
    {description = "increase the number of master clients", group = "layout"}
  ),
  awful.key({modkey, "Shift"}, "l",
    function()
      awful.tag.incnmaster(-1, nil, true)
    end,
    {description = "decrease the number of master clients", group = "layout"}
  ),
  awful.key({modkey, "Control"}, "h",
    function()
      awful.tag.incncol(1, nil, true)
    end,
    {description = "increase the number of columns", group = "layout"}
  ),
  awful.key({modkey, "Control"}, "l",
    function()
      awful.tag.incncol(-1, nil, true)
    end,
    {description = "decrease the number of columns", group = "layout"}
  ),
  awful.key({modkey}, "space", function() awful.layout.inc(1) end, {
    description = "select next",
    group = "layout"
  }),
  awful.key({modkey, "Shift"}, "space", function() awful.layout.inc(-1) end, {
    description = "select previous",
    group = "layout"
  }),

  awful.key({modkey, "Control"}, "n",
    function()
      local c = awful.client.restore()
      -- Focus restored client
      if c then
          client.focus = c
          c:raise()
      end
    end,
    {description = "restore minimized", group = "client"}
  ),

  -- Prompt
  awful.key({modkey}, "r",
    function()
      awful.screen.focused().mypromptbox:run()
    end,
    {description = "run prompt", group = "launcher"}
  ),

  awful.key({modkey}, "x",
    function ()
      awful.prompt.run {
        prompt       = "Run Lua code: ",
        textbox      = awful.screen.focused().mypromptbox.widget,
        exe_callback = awful.util.eval,
        history_path = awful.util.get_cache_dir() .. "/history_eval"
      }
    end,
    {description = "lua execute prompt", group = "awesome"}
  ),
  -- Menubar
  awful.key({modkey}, "p", function() menubar.show() end, {
    description = "show the menubar",
    group = "launcher"
  })
)

local clientkeys = awful.util.table.join(
  awful.key({modkey}, "f", function (c)
      c.fullscreen = not c.fullscreen
      c:raise()
    end,
    {description = "toggle fullscreen", group = "client"}
  ),
  awful.key({modkey}, "c", function (c) c:kill() end,
    {description = "close", group = "client"}
  ),
  awful.key({modkey, "Control"}, "space", awful.client.floating.toggle,
    {description = "toggle floating", group = "client"}
  ),
  awful.key({modkey, "Control"}, "Return", function(c)
      c:swap(awful.client.getmaster())
    end,
    {description = "move to master", group = "client"}
  ),
  awful.key({modkey}, "o", function(c) c:move_to_screen() end,
    {description = "move to screen", group = "client"}
  ),
  awful.key({modkey}, "t", function(c) c.ontop = not c.ontop end,
    {description = "toggle keep on top", group = "client"}
  ),
  awful.key({modkey}, "n", function (c)
      -- The client currently has the input focus, so it cannot be minimized,
      -- since minimized clients can't have the focus.
      c.minimized = true
    end,
    {description = "minimize", group = "client"}
  ),
  awful.key({modkey}, "m", function (c)
      c.maximized = not c.maximized
      c:raise()
    end,
    {description = "maximize", group = "client"}
  )
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout. This
-- should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = awful.util.table.join(globalkeys,
    -- View tag only.
    awful.key({modkey}, "#" .. i + 9, function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          tag:view_only()
        end
      end,
      {description = "view tag #"..i, group = "tag"}
    ),
    -- Toggle tag display.
    awful.key({modkey, "Control"}, "#" .. i + 9, function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end,
      {description = "toggle tag #" .. i, group = "tag"}
    ),
    -- Move client to tag.
    awful.key({modkey, "Shift"}, "#" .. i + 9, function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:move_to_tag(tag)
          end
        end
      end,
      {description = "move focused client to tag #"..i, group = "tag"}
    ),
    -- Toggle tag on focused client.
    awful.key({modkey, "Control", "Shift"}, "#" .. i + 9, function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:toggle_tag(tag)
          end
        end
      end,
      {description = "toggle focused client on tag #" .. i, group = "tag"}
    )
  )
end

local clientbuttons = awful.util.table.join(
  awful.button({}, 1, function(c) client.focus = c; c:raise() end),
  awful.button({modkey}, 1, awful.mouse.client.move),
  awful.button({modkey}, 3, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)

-- Rules
awful.rules.rules = {
  -- All clients will match this rule.
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      keys = clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placment = awful.placement.no_overlap + awful.placement.no_offscreen
    }
  }
}

-- Signal function to execute when a new client appears
client.connect_signal("manage", function (c)
  if awesome.startup
    and not c.size_hints.user_position
    and not c.size_hints.program_position then
    -- Prevent clients from being unreachable after screen count changes.
    awful.placement.no_offscreen(c)
  end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
  -- buttons for the titlebar
  local buttons = awful.util.table.join(
    awful.button({}, 1, function()
      client.focus = c
      c:raise()
      awful.mouse.client.move(c)
    end),
    awful.button({ }, 3, function()
      client.focus = c
      c:raise()
      awful.mouse.client.resize(c)
    end)
  )

  awful.titlebar(c) : setup {
    { -- Left
      awful.titlebar.widget.iconwidget(c),
      buttons = buttons,
      layout  = wibox.layout.fixed.horizontal
    },
    { -- Middle
      { -- Title
        align  = "center",
        widget = awful.titlebar.widget.titlewidget(c)
      },
      buttons = buttons,
      layout  = wibox.layout.flex.horizontal
    },
    { -- Right
      awful.titlebar.widget.floatingbutton (c),
      awful.titlebar.widget.maximizedbutton(c),
      awful.titlebar.widget.stickybutton   (c),
      awful.titlebar.widget.ontopbutton    (c),
      awful.titlebar.widget.closebutton    (c),
      layout = wibox.layout.fixed.horizontal()
    },
    layout = wibox.layout.align.horizontal
  }
end)

-- Enable sloppy focus, so that focus follows mouse
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c)
  c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
  c.border_color = beautiful.border_normal
end)
