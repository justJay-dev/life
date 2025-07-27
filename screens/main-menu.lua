-- Main Menu Screen
local Config = require("engine.config")
local ScreenManager = require("engine.screen-manager")
local GameScreen = require("engine.game-screen")
local Button = require("ui.button")

local MainMenuScreen = GameScreen:new()

function MainMenuScreen:enter()
    -- Create buttons
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    local buttonWidth = 200
    local buttonHeight = 60
    local buttonX = (windowWidth - buttonWidth) / 2
    local buttonY = windowHeight / 2 - 40
    local editorButtonY = buttonY + buttonHeight + 20

    self.playButton = Button:new(buttonX, buttonY, buttonWidth, buttonHeight, "PLAY", function()
        ScreenManager:switchTo("simulation")
    end)

    self.editorButton = Button:new(buttonX, editorButtonY, buttonWidth, buttonHeight, "EDITOR", function()
        ScreenManager:switchTo("creature_editor")
    end)
end

function MainMenuScreen:leave()
    -- Cleanup when leaving menu
end

function MainMenuScreen:update(dt)
    -- Update buttons
    if self.playButton then
        self.playButton:update(dt)
    end
    if self.editorButton then
        self.editorButton:update(dt)
    end
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

    -- Draw buttons
    if self.playButton and self.editorButton then
        self.playButton:draw()
        self.editorButton:draw()
    end

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
        if self.playButton then
            self.playButton:mousepressed(x, y, button)
        end
        if self.editorButton then
            self.editorButton:mousepressed(x, y, button)
        end
    end
end

return MainMenuScreen
