-- Conway's Game of Life in LÖVE 2D
local Config = require("engine.config")
local ScreenManager = require("engine.screen-manager")

-- Load screens
local MainMenuScreen = require("screens.main-menu")
local SimulationScreen = require("screens.simulation")
local CreatureEditorScreen = require("screens.creature-editor")

function love.load()
    -- Set window size
    love.window.setMode(Config.gridWidth * Config.cellSize, Config.gridHeight * Config.cellSize + 40)

    -- Initialize screen manager
    ScreenManager:addScreen("main_menu", MainMenuScreen)
    ScreenManager:addScreen("simulation", SimulationScreen)
    ScreenManager:addScreen("creature_editor", CreatureEditorScreen)

    -- Start with main menu
    ScreenManager:switchTo("main_menu")
end

function love.update(dt)
    ScreenManager:update(dt)
end

function love.draw()
    ScreenManager:draw()
end

function love.keypressed(key)
    ScreenManager:keypressed(key)
end

function love.mousepressed(x, y, button)
    ScreenManager:mousepressed(x, y, button)
end

function love.textinput(text)
    if ScreenManager.currentScreen and ScreenManager.currentScreen.textinput then
        ScreenManager.currentScreen:textinput(text)
    end
end
