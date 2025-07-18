-- Base GameScreen class - provides common functionality for all screens
local GameScreen = {}
GameScreen.__index = GameScreen

function GameScreen:new()
    local instance = {}
    setmetatable(instance, GameScreen)
    return instance
end

-- Default implementations that can be overridden by subclasses
function GameScreen:enter()
    -- Called when entering this screen
end

function GameScreen:leave()
    -- Called when leaving this screen
end

function GameScreen:update(dt)
    -- Called every frame with delta time
end

function GameScreen:draw()
    -- Called every frame for rendering
end

function GameScreen:keypressed(key)
    -- Called when a key is pressed
end

function GameScreen:mousepressed(x, y, button)
    -- Called when mouse is pressed
end

function GameScreen:mousereleased(x, y, button)
    -- Called when mouse is released
end

function GameScreen:mousemoved(x, y, dx, dy)
    -- Called when mouse is moved
end

function GameScreen:textinput(text)
    -- Called when text is input
end

function GameScreen:resize(w, h)
    -- Called when window is resized
end

-- Utility methods that can be used by subclasses
function GameScreen:centerText(text, font, y)
    local windowWidth = love.graphics.getWidth()
    local textWidth = font:getWidth(text)
    return (windowWidth - textWidth) / 2, y
end

-- Grid drawing methods
function GameScreen:drawGrid(grid, aliveColor, deadColor)
    local Config = require("engine.config")
    aliveColor = aliveColor or { 1, 1, 1 }     -- Default white
    deadColor = deadColor or { 0.1, 0.1, 0.1 } -- Default dark gray

    for x = 1, Config.gridWidth do
        for y = 1, Config.gridHeight do
            local screenX = (x - 1) * Config.cellSize
            local screenY = (y - 1) * Config.cellSize

            if grid[x][y] then
                love.graphics.setColor(aliveColor[1], aliveColor[2], aliveColor[3])
                love.graphics.rectangle("fill", screenX, screenY, Config.cellSize, Config.cellSize)
            else
                love.graphics.setColor(deadColor[1], deadColor[2], deadColor[3])
                love.graphics.rectangle("line", screenX, screenY, Config.cellSize, Config.cellSize)
            end
        end
    end
end

function GameScreen:drawSimulationGrid(grid)
    self:drawGrid(grid, { 1, 1, 1 }, { 0.1, 0.1, 0.1 }) -- White alive, dark gray dead
end

function GameScreen:drawEditorGrid(grid)
    self:drawGrid(grid, { 0.9, 0.9, 0.9 }, { 0.2, 0.2, 0.2 }) -- Light gray alive, darker gray dead
end

return GameScreen
