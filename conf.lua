function love.conf(t)
    t.window.title = "Life Simulation"
    t.window.icon = "assets/icon.png" -- Set the window icon
    t.window.width = 800
    t.window.height = 600
    t.console = true           -- Enable console for debugging
    t.modules.joystick = false -- Disable joystick module if not needed
    t.modules.physics = false  -- Disable physics module if not needed
end
