local Colors = require("engine.colors")
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

    aliveColor = aliveColor or Colors.ui.aliveDefault
    deadColor = deadColor or Colors.ui.deadDefault

    for x = 1, Config.gridWidth do
        for y = 1, Config.gridHeight do
            local screenX = (x - 1) * Config.cellSize
            local screenY = (y - 1) * Config.cellSize

            local cell = grid[x][y]
            local isAlive = false
            local cellColor = aliveColor

            -- Handle both new object format and legacy boolean format
            if type(cell) == "table" then
                isAlive = cell.alive
                if cell.color then
                    cellColor = Colors.getCreatureColor(cell.color)
                end
            elseif cell then
                isAlive = true
            end

            if isAlive then
                love.graphics.setColor(cellColor[1], cellColor[2], cellColor[3])
                love.graphics.rectangle("fill", screenX, screenY, Config.cellSize, Config.cellSize)
            else
                love.graphics.setColor(deadColor[1], deadColor[2], deadColor[3])
                love.graphics.rectangle("line", screenX, screenY, Config.cellSize, Config.cellSize)
            end
        end
    end
end

function GameScreen:drawSimulationGrid(grid)
    self:drawGrid(grid, Colors.ui.aliveDefault, Colors.ui.deadDefault)
end

function GameScreen:drawEditorGrid(grid)
    self:drawGrid(grid, Colors.ui.editorAlive, Colors.ui.editorDead)
end

return GameScreen
