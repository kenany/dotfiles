local gears = require("gears")

-- Widgets
local wibox = require("wibox")
local lain = require("lain")
local awful = require("awful")
awful.rules = require("awful.rules")
awful.autofocus = require("awful.autofocus")

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
  lain.layout.uselesstile,
  lain.layout.centerwork
}

-- Themes define colours, icons, and wallpapers
beautiful.init("/home/kenan/.config/awesome/theme.lua")

-- Wallpaper
if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end

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

local mylauncher = awful.widget.launcher({
  image = beautiful.awesome_icon,
  menu = mymainmenu
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
local bat0 = lain.widgets.bat({
  battery = "BAT0",
  settings = function()
    widget:set_markup(markup("#eda987", "&#xf240; " .. bat_now.perc .. "% "))
  end
})
local bat1 = lain.widgets.bat({
  battery = "BAT1",
  settings = function()
    widget:set_markup(markup("#ddb26f", "&#xf240; " .. bat_now.perc .. "% "))
  end
})

-- cpu
local cpuwidget = lain.widgets.cpu({
  settings = function()
    widget:set_markup(markup("#fb9fb1", "&#xf0e4; " .. cpu_now.usage .. "% "))
  end
})

-- mpd
local mpdwidget = lain.widgets.mpd({
  settings = function()
    mpd_notification_preset = {
      text = string.format("%s [%s] - %s\n%s", mpd_now.artist, mpd_now.album,
        mpd_now.date, mpd_now.title)
    }

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
lain.widgets.calendar.attach(mytextclock, { font_size = 10 })

-- Create a wibox for each screen and add it
local mywibox = {}
local mypromptbox = {}
local mylayoutbox = {}
local mytaglist = {}
mytaglist.buttons = awful.util.table.join(
  awful.button({}, 1, awful.tag.viewonly),
  awful.button({modkey}, 1, awful.client.movetotag),
  awful.button({}, 3, awful.tag.viewtoggle),
  awful.button({modkey}, 3, awful.client.toggletag),
  awful.button({}, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
  awful.button({}, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
local mytasklist = {}
mytasklist.buttons = awful.util.table.join(
  awful.button({}, 1, function(c)
    if c == client.focus then
      c.minimized = true
    else

      -- Without this, the following `:isvisible()` makes no sense.
      c.minimized = false
      if not c:isvisible() then
        awful.tag.viewonly(c:tags()[1])
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

for s = 1, screen.count() do

  -- Create a promptbox for each screen.
  mypromptbox[s] = awful.widget.prompt()

  -- Create an imagebox widget which will contains an icon indicating which
  -- layout we're using. We need one layoutbox per screen.
  mylayoutbox[s] = awful.widget.layoutbox(s)
  mylayoutbox[s]:buttons(awful.util.table.join(
    awful.button({}, 1, function() awful.layout.inc(layouts, 1) end),
    awful.button({}, 3, function() awful.layout.inc(layouts, -1) end),
    awful.button({}, 4, function() awful.layout.inc(layouts, 1) end),
    awful.button({}, 5, function() awful.layout.inc(layouts, -1) end)
  ))

  -- Create a taglist widget.
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

  -- Create a tasklist widget.
  mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

  -- Create the top wibox.
  mywibox[s] = awful.wibox({position = "top", screen = s})

  -- Widgets that are aligned to the left.
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(mylauncher)
  left_layout:add(mytaglist[s])
  left_layout:add(mypromptbox[s])

  -- Widgets that are aligned to the right.
  local right_layout = wibox.layout.fixed.horizontal()
  right_layout:add(space)
  right_layout:add(mpdwidget)
  right_layout:add(cpuwidget)
  right_layout:add(bat0)
  right_layout:add(bat1)
  right_layout:add(mytextclock)
  right_layout:add(mylayoutbox[s])

  -- Now bring it all together (with the tasklist in the middle).
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_middle(mytasklist[s])
  layout:set_right(right_layout)

  mywibox[s]:set_widget(layout)

  -- Create the bottom wibox
  mywibox[s] = awful.wibox({position = "bottom", screen = s})

  -- Widgets that are aligned to the right.
  local right_layout = wibox.layout.fixed.horizontal()
  if s == 1 then right_layout:add(wibox.widget.systray()) end

  -- Now bring it all together.
  local layout = wibox.layout.align.horizontal()
  layout:set_right(right_layout)

  mywibox[s]:set_widget(layout)
end

-- Mouse bindings
root.buttons(awful.util.table.join(
  awful.button({}, 3, function() mymainmenu:toggle() end),
  awful.button({}, 4, awful.tag.viewnext),
  awful.button({}, 5, awful.tag.viewprev)
))

-- Key bindings
local globalkeys = awful.util.table.join(
  awful.key({modkey}, "Left", awful.tag.viewprev),
  awful.key({modkey}, "Right", awful.tag.viewnext),
  awful.key({modkey}, "Escape", awful.tag.history.restore),

  awful.key({modkey}, "j",
    function()
      awful.client.focus.byidx(1)
      if client.focus then
        client.focus:raise()
      end
    end),
  awful.key({modkey}, "k",
    function()
      awful.client.focus.byidx(-1)
      if client.focus then
        client.focus:raise()
      end
    end),

  awful.key({modkey}, "w", function() mymainmenu:show() end),

  -- Layout manipulation
  awful.key({modkey, "Shift"}, "j", function() awful.client.swap.byidx(1) end),
  awful.key({modkey, "Shift"}, "k", function() awful.client.swap.byidx(-1) end),
  awful.key({modkey, "Control"}, "j", function() awful.screen.focus_relative( 1) end),
  awful.key({modkey, "Control"}, "k", function() awful.screen.focus_relative(-1) end),
  awful.key({modkey}, "u", awful.client.urgent.jumpto),
  awful.key({modkey}, "Tab",
    function()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end),

  -- Standard program
  awful.key({modkey}, "Return", function() awful.util.spawn(terminal) end),
  awful.key({modkey, "Control"}, "r", awesome.restart),
  awful.key({modkey, "Shift"}, "q", awesome.quit),

  awful.key({modkey}, "l", function() awful.tag.incmwfact(0.05) end),
  awful.key({modkey}, "h", function() awful.tag.incmwfact(-0.05) end),
  awful.key({modkey, "Shift"}, "h", function() awful.tag.incnmaster(1) end),
  awful.key({modkey, "Shift"}, "l", function() awful.tag.incnmaster(-1) end),
  awful.key({modkey, "Control"}, "h", function() awful.tag.incncol(1) end),
  awful.key({modkey, "Control"}, "l", function() awful.tag.incncol(-1) end),
  awful.key({modkey}, "space", function() awful.layout.inc(layouts,1) end),
  awful.key({modkey, "Shift"}, "space", function() awful.layout.inc(layouts, -1) end),

  awful.key({modkey, "Control"}, "n", awful.client.restore),

  -- Prompt
  awful.key({modkey}, "r", function() mypromptbox[mouse.screen]:run() end),

  awful.key({modkey}, "x",
    function()
      awful.prompt.run({prompt = "Run Lua code: "},
        mypromptbox[mouse.screen].widget,
        awful.util.eval,
        nil,
        awful.util.getdir("cache") .. "/history_eval"
      )
    end),

  -- Menubar
  awful.key({modkey}, "p", function() menubar.show() end)
)

local clientkeys = awful.util.table.join(
  awful.key({modkey}, "f", function(c) c.fullscreen = not c.fullscreen end),
  awful.key({modkey}, "c", function(c) c:kill() end),
  awful.key({modkey, "Control"}, "space",  awful.client.floating.toggle),
  awful.key({modkey, "Control"}, "Return", function(c) c:swap(awful.client.getmaster()) end),
  awful.key({modkey}, "o", awful.client.movetoscreen),
  awful.key({modkey}, "t", function(c) c.ontop = not c.ontop end),
  awful.key({modkey}, "n",
    function (c)

      -- The client currently has the input focus, so it cannot be minimized,
      -- since minimized clients can't have the focus.
      c.minimized = true
    end),
  awful.key({modkey}, "m",
    function(c)
      c.maximized_horizontal = not c.maximized_horizontal
      c.maximized_vertical = not c.maximized_vertical
    end)
)

-- Bind all key numbers to tags.
--
-- Be careful: we use keycodes to make it works on any keyboard layout. This
-- should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = awful.util.table.join(globalkeys,
    awful.key({ modkey }, "#" .. i + 9,
      function ()
        local screen = mouse.screen
        local tag = awful.tag.gettags(screen)[i]
        if tag then
          awful.tag.viewonly(tag)
        end
      end),
    awful.key({ modkey, "Control" }, "#" .. i + 9,
      function ()
          local screen = mouse.screen
          local tag = awful.tag.gettags(screen)[i]
          if tag then
             awful.tag.viewtoggle(tag)
          end
      end),
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
      function ()
          local tag = awful.tag.gettags(client.focus.screen)[i]
          if client.focus and tag then
              awful.client.movetotag(tag)
         end
      end),
    awful.key({modkey, "Control", "Shift"}, "#" .. i + 9,
      function()
        local tag = awful.tag.gettags(client.focus.screen)[i]
        if client.focus and tag then
          awful.client.toggletag(tag)
        end
      end
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
-- }}}

-- {{{ Rules
awful.rules.rules = {

  -- All clients will match this rule.
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = true,
      keys = clientkeys,
      buttons = clientbuttons
    }
  }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
  -- Enable sloppy focus
  c:connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
    and awful.client.focus.filter(c) then
      client.focus = c
    end
  end)

  if not startup then

    -- Set the windows at the slave, i.e. put it at the end of others instead of
    -- setting it master.
    -- awful.client.setslave(c)

    -- Put windows in a smart way, only if they does not set an initial position.
    if not c.size_hints.user_position and not c.size_hints.program_position then
      awful.placement.no_overlap(c)
      awful.placement.no_offscreen(c)
    end
  end

  local titlebars_enabled = false
  if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then

    -- Buttons for the titlebar
    local buttons = awful.util.table.join(
      awful.button({ }, 1, function()
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

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(awful.titlebar.widget.iconwidget(c))
    left_layout:buttons(buttons)

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(awful.titlebar.widget.floatingbutton(c))
    right_layout:add(awful.titlebar.widget.maximizedbutton(c))
    right_layout:add(awful.titlebar.widget.stickybutton(c))
    right_layout:add(awful.titlebar.widget.ontopbutton(c))
    right_layout:add(awful.titlebar.widget.closebutton(c))

    -- The title goes in the middle
    local middle_layout = wibox.layout.flex.horizontal()
    local title = awful.titlebar.widget.titlewidget(c)
    title:set_align("center")
    middle_layout:add(title)
    middle_layout:buttons(buttons)

    -- Now bring it all together
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_right(right_layout)
    layout:set_middle(middle_layout)

    awful.titlebar(c):set_widget(layout)
  end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
