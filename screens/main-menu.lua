-- Main Menu Screen
local Config = require("engine/config")
local ScreenManager = require("engine.screen-manager")
local GameScreen = require("engine.game-screen")

local MainMenuScreen = GameScreen:new()

function MainMenuScreen:enter()
    -- Reset any game state when entering menu
    love.window.setTitle("Conway's Game of Life - Main Menu")
end

function MainMenuScreen:leave()
    -- Cleanup when leaving menu
end

function MainMenuScreen:update(dt)
    -- Menu doesn't need updates, but we could add animations here
end

function MainMenuScreen:draw()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    -- Set background color to dark blue
    love.graphics.clear(0.1, 0.1, 0.3)

    -- Title
    love.graphics.setColor(1, 1, 1)
    local titleFont = love.graphics.newFont(48)
    love.graphics.setFont(titleFont)
    local title = "Conway's Game of Life"
    local titleX, titleY = self:centerText(title, titleFont, windowHeight / 4)
    love.graphics.print(title, titleX, titleY)

    -- Subtitle
    local subtitleFont = love.graphics.newFont(20)
    love.graphics.setFont(subtitleFont)
    local subtitle = "Explore the fascinating world of cellular automata"
    love.graphics.setColor(0.8, 0.8, 0.8)
    local subtitleX, subtitleY = self:centerText(subtitle, subtitleFont, windowHeight / 4 + 80)
    love.graphics.print(subtitle, subtitleX, subtitleY)

    -- Play button
    local buttonWidth = 200
    local buttonHeight = 60
    local buttonX = (windowWidth - buttonWidth) / 2
    local buttonY = windowHeight / 2

    -- Check if mouse is over button
    local mouseX, mouseY = love.mouse.getPosition()
    local isHovered = self:isPointInRect(mouseX, mouseY, buttonX, buttonY, buttonWidth, buttonHeight)

    -- Draw button using base class method
    local buttonFont = love.graphics.newFont(24)
    love.graphics.setFont(buttonFont)
    self:drawButton(buttonX, buttonY, buttonWidth, buttonHeight, "PLAY", isHovered, buttonFont)

    -- Instructions
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.setColor(0.7, 0.7, 0.7)
    local instructions = "Click PLAY to start the simulation\nPress ESC to quit"
    local instrFont = love.graphics.getFont()
    local instrX, instrY = self:centerText("Click PLAY to start the simulation", instrFont, windowHeight * 3 / 4)
    love.graphics.print(instructions, instrX, instrY)
end

function MainMenuScreen:keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "return" or key == "space" then
        -- Enter or Space can also start the game
        ScreenManager:switchTo("simulation")
    end
end

function MainMenuScreen:mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        local windowWidth = love.graphics.getWidth()
        local windowHeight = love.graphics.getHeight()

        -- Check if click is on play button
        local buttonWidth = 200
        local buttonHeight = 60
        local buttonX = (windowWidth - buttonWidth) / 2
        local buttonY = windowHeight / 2

        if self:isPointInRect(x, y, buttonX, buttonY, buttonWidth, buttonHeight) then
            ScreenManager:switchTo("simulation")
        end
    end
end

return MainMenuScreen
