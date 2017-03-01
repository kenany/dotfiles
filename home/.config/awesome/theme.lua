local theme = {}

theme.font = "Source Code Pro 8"

theme.base00 = "#151515"
theme.base01 = "#202020"
theme.base02 = "#303030"
theme.base03 = "#505050"
theme.base04 = "#b0b0b0"
theme.base05 = "#d0d0d0"
theme.base06 = "#e0e0e0"
theme.base07 = "#f5f5f5"
theme.base08 = "#fb9fb1"
theme.base09 = "#eda987"
theme.base0A = "#ddb26f"
theme.base0B = "#acc267"
theme.base0C = "#12cfc0"
theme.base0D = "#3182bd"
theme.base0E = "#e1a3ee"
theme.base0F = "#deaf8f"

theme.menu_bg_normal = theme.base00
theme.menu_bg_focus = theme.base00
theme.bg_normal = theme.base00
theme.bg_focus = theme.base00
theme.bg_urgent = theme.base00

theme.fg_normal = theme.base05
theme.fg_focus = theme.base07
theme.fg_urgent = theme.base00
theme.fg_minimize = theme.base00

theme.border_width = 1
theme.border_normal = "#1c2022"
theme.border_focus = "#606060"
theme.border_marked = "#3ca4d8"
theme.menu_width = 110
theme.menu_border_width = 0
theme.menu_fg_normal = "#d0d0d0"
theme.menu_fg_focus = "#e0e0e0"
theme.menu_bg_normal = "#151515"
theme.menu_bg_focus = "#151515"

-- Variables set for theming the menu
theme.menu_submenu_icon = "/usr/share/awesome/themes/default/submenu.png"
theme.menu_height = 15
theme.menu_width  = 100

-- spacing between tiled windows
theme.useless_gap_width = 20

-- Set the height of the lowest window of the second column to 72px; setting it
-- to zero makes all the slave windows the same height.
theme.lower_window_height = 72

-- Set your vertical resolution.
theme.vertical_resolution = 1080

-- Set the extra vertical spacing to 8px.
theme.vertical_border = 8

-- Set the extra outermost spacing to 18px.
theme.outer_padding = 18

theme.wallpaper = os.getenv("HOME") .. "/img/1.png"

theme.layout_fairh = "/usr/share/awesome/themes/default/layouts/fairhw.png"
theme.layout_fairv = "/usr/share/awesome/themes/default/layouts/fairvw.png"
theme.layout_floating  = "/usr/share/awesome/themes/default/layouts/floatingw.png"
theme.layout_magnifier = "/usr/share/awesome/themes/default/layouts/magnifierw.png"
theme.layout_max = "/usr/share/awesome/themes/default/layouts/maxw.png"
theme.layout_fullscreen = "/usr/share/awesome/themes/default/layouts/fullscreenw.png"
theme.layout_tilebottom = "/usr/share/awesome/themes/default/layouts/tilebottomw.png"
theme.layout_tileleft   = "/usr/share/awesome/themes/default/layouts/tileleftw.png"
theme.layout_tile = "/usr/share/awesome/themes/default/layouts/tilew.png"
theme.layout_uselesstile = "/usr/share/awesome/themes/default/layouts/tilew.png"
theme.layout_tiletop = "/usr/share/awesome/themes/default/layouts/tiletopw.png"
theme.layout_spiral  = "/usr/share/awesome/themes/default/layouts/spiralw.png"
theme.layout_dwindle = "/usr/share/awesome/themes/default/layouts/dwindlew.png"

theme.awesome_icon = "/usr/share/awesome/icons/awesome16.png"

theme.lain_icons = os.getenv("HOME") .. "/.config/awesome/lain/icons/layout/default/"
theme.layout_centerwork = theme.lain_icons .. "centerworkw.png"

theme.tasklist_fg_focus = theme.base05
theme.tasklist_fg_minimize = theme.base03

return theme
