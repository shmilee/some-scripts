    -- ALSA volume control
    -- keycode 121 = XF86AudioMute
    -- keycode 122 = XF86AudioLowerVolume
    -- keycode 123 = XF86AudioRaiseVolume
    awful.key({}, "XF86AudioRaiseVolume",
        function ()
            awful.util.spawn("amixer -q set " .. volume.channel .. " " .. volume.step .. "+")
            volume.notify()
        end),
    awful.key({}, "XF86AudioLowerVolume",
        function ()
            awful.util.spawn("amixer -q set " .. volume.channel .. " " .. volume.step .. "-")
            volume.notify()
        end),
    awful.key({}, "XF86AudioMute",
        function ()
            awful.util.spawn("amixer -q set " .. volume.channel .. " playback toggle")
            volume.notify()
        end),
    --休眠
    awful.key({ modkey, "Control" }, "s", function () awful.util.spawn("systemctl suspend") end),
    -- 截屏
    awful.key({ }, "Print", function() awful.util.spawn("deepin-scrot") end),
