-- Main Menu Screen
local Config = require("engine.config")
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
    local buttonY = windowHeight / 2 - 40

    -- Editor button
    local editorButtonY = buttonY + buttonHeight + 20

    -- Check if mouse is over buttons
    local mouseX, mouseY = love.mouse.getPosition()
    local playHovered = self:isPointInRect(mouseX, mouseY, buttonX, buttonY, buttonWidth, buttonHeight)
    local editorHovered = self:isPointInRect(mouseX, mouseY, buttonX, editorButtonY, buttonWidth, buttonHeight)

    -- Draw buttons using base class method
    local buttonFont = love.graphics.newFont(24)
    love.graphics.setFont(buttonFont)
    self:drawButton(buttonX, buttonY, buttonWidth, buttonHeight, "PLAY", playHovered, buttonFont)
    self:drawButton(buttonX, editorButtonY, buttonWidth, buttonHeight, "EDITOR", editorHovered, buttonFont)

    -- Store button coordinates for click detection
    self.playButton = { x = buttonX, y = buttonY, width = buttonWidth, height = buttonHeight }
    self.editorButton = { x = buttonX, y = editorButtonY, width = buttonWidth, height = buttonHeight }

    -- Instructions
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.setColor(0.7, 0.7, 0.7)
    local instructions = "Click PLAY to start the simulation\nClick EDITOR to create creatures\nPress ESC to quit"
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
    elseif key == "e" then
        -- E key opens editor
        ScreenManager:switchTo("creature_editor")
    end
end

function MainMenuScreen:mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        -- Check if click is on play button
        if self.playButton and self:isPointInRect(x, y, self.playButton.x, self.playButton.y,
                self.playButton.width, self.playButton.height) then
            ScreenManager:switchTo("simulation")
            -- Check if click is on editor button
        elseif self.editorButton and self:isPointInRect(x, y, self.editorButton.x, self.editorButton.y,
                self.editorButton.width, self.editorButton.height) then
            ScreenManager:switchTo("creature_editor")
        end
    end
end

return MainMenuScreen
