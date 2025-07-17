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

function GameScreen:drawButton(x, y, width, height, text, isHovered, font)
    font = font or love.graphics.getFont()

    -- Draw button background
    if isHovered then
        love.graphics.setColor(0.3, 0.6, 0.9) -- Light blue when hovered
    else
        love.graphics.setColor(0.2, 0.4, 0.7) -- Dark blue normally
    end
    love.graphics.rectangle("fill", x, y, width, height)

    -- Draw button border
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)

    -- Draw button text
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight()
    love.graphics.print(text,
        x + (width - textWidth) / 2,
        y + (height - textHeight) / 2)
end

function GameScreen:isPointInRect(px, py, x, y, width, height)
    return px >= x and px <= x + width and py >= y and py <= y + height
end

return GameScreen
