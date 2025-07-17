-- Screen Manager - handles switching between different game screens
local ScreenManager = {}
ScreenManager.__index = ScreenManager

ScreenManager.currentScreen = nil
ScreenManager.screens = {}

function ScreenManager:addScreen(name, screen)
    self.screens[name] = screen
end

function ScreenManager:switchTo(screenName)
    local newScreen = self.screens[screenName]
    if not newScreen then
        error("Screen '" .. screenName .. "' not found!")
    end

    -- Call leave on current screen if it exists
    if self.currentScreen and self.currentScreen.leave then
        self.currentScreen:leave()
    end

    -- Switch to new screen
    self.currentScreen = newScreen

    -- Call enter on new screen
    if self.currentScreen.enter then
        self.currentScreen:enter()
    end
end

function ScreenManager:getCurrentScreen()
    return self.currentScreen
end

-- Delegate Love2D callbacks to current screen
function ScreenManager:update(dt)
    if self.currentScreen and self.currentScreen.update then
        self.currentScreen:update(dt)
    end
end

function ScreenManager:draw()
    if self.currentScreen and self.currentScreen.draw then
        self.currentScreen:draw()
    end
end

function ScreenManager:keypressed(key)
    if self.currentScreen and self.currentScreen.keypressed then
        self.currentScreen:keypressed(key)
    end
end

function ScreenManager:mousepressed(x, y, button)
    if self.currentScreen and self.currentScreen.mousepressed then
        self.currentScreen:mousepressed(x, y, button)
    end
end

return ScreenManager
