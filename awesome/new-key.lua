    -- ALSA volume control
    -- keycode 121 = XF86AudioMute
    -- keycode 122 = XF86AudioLowerVolume
    -- keycode 123 = XF86AudioRaiseVolume
    awful.key({}, "XF86AudioRaiseVolume", function ()
        os.execute(string.format("amixer -q set %s %s+", volume.channel, volume.step))
        volume.mynotify()
    end),
    awful.key({}, "XF86AudioLowerVolume", function ()
        os.execute(string.format("amixer -q set %s %s-", volume.channel, volume.step))
        volume.mynotify()
    end),
    awful.key({}, "XF86AudioMute", function ()
        --awful.util.spawn("ponymix toggle")
        os.execute(string.format("amixer -q set %s playback toggle", volume.channel))
        volume.mynotify()
    end),
    -- keycode 198 = XF86AudioMicMute
    awful.key({}, "XF86AudioMicMute", function ()
        awful.util.spawn("amixer sset Capture toggle")
    end),
    -- keycode 235 = XF86Display
    awful.key({ }, "XF86Display", function ()
        --naughty.notify({ title = "Oops, Key XF86Display not set" })
        awful.util.spawn("arandr")
    end),
    -- keycode 179 = XF86Tools, --> Hide / show wibox
    awful.key({ }, "XF86Tools", function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
    end),
    -- keycode 225 = XF86Search
    awful.key({ }, "XF86Search", function ()
        naughty.notify({ title = "Oops, Key XF86Search not set" })
    end),
    -- keycode 128 = XF86LaunchA
    awful.key({ }, "XF86LaunchA", function() menubar.show() end),
    -- keycode 152 = XF86Explorer
    awful.key({ }, "XF86Explorer", revelation),
    -- Brightness
    awful.key({ }, "XF86MonBrightnessDown", function ()
        os.execute(string.format("volnoti-show -s %s `xbacklight -dec %s; xbacklight`",
            "/usr/share/pixmaps/volnoti/display-brightness-symbolic.svg", 5))
    end),
    awful.key({ }, "XF86MonBrightnessUp", function ()
        os.execute(string.format("volnoti-show -s %s `xbacklight -inc %s; xbacklight`",
            "/usr/share/pixmaps/volnoti/display-brightness-symbolic.svg", 5))
    end),
    -- Display
    awful.key({ modkey, "Control" }, "p", function () awful.util.spawn("arandr") end),
    --休眠
    awful.key({ modkey, "Control" }, "s", function ()
        awful.util.spawn("systemctl suspend")
    end),
    --锁屏
    awful.key({ modkey, "Control" }, "l", function () awful.util.spawn("slock") end),
    -- 截屏
    awful.key({ }, "Print", function() awful.util.spawn("deepin-scrot") end),
    -- Hide / show wibox
    awful.key({ modkey }, "b", function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
    end),
