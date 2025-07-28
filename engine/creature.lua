local Colors = require("engine.colors")
-- Base Creature class for Game of Life patterns
local Creature = {}
Creature.__index = Creature

function Creature:new(name, description, pattern)
    -- Randomly select a color from available options
    local selectedColor = Colors.getRandomCreatureColor()

    local instance = {
        name = name,
        description = description,
        pattern = pattern or {},
        color = selectedColor,
        width = 0,
        height = 0
    }
    setmetatable(instance, Creature)

    -- Calculate dimensions from pattern
    if #pattern > 0 then
        instance.height = #pattern
        instance.width = #pattern[1] or 0
    end

    return instance
end

function Creature:create(grid, x, y, gridWidth, gridHeight)
    -- Check if the pattern fits within the grid boundaries
    if x + self.width - 1 > gridWidth or y + self.height - 1 > gridHeight then
        return false
    end

    -- Apply the pattern to the grid
    for row = 1, self.height do
        for col = 1, self.width do
            if self.pattern[row] and self.pattern[row][col] then
                local gridX = x + col - 1
                local gridY = y + row - 1
                if gridX >= 1 and gridX <= gridWidth and gridY >= 1 and gridY <= gridHeight then
                    grid[gridX][gridY] = {
                        alive = true,
                        color = self.color
                    }
                end
            end
        end
    end

    return true
end

function Creature:getSize()
    return { width = self.width, height = self.height }
end

function Creature:getDescription()
    return self.description
end

function Creature:getName()
    return self.name
end

function Creature:getColor()
    return self.color
end

function Creature.loadFromFile(filename)
    local parsing = require("engine.parsing")
    local data, err = parsing.loadCreature(filename)
    if not data then
        return nil, err
    end

    return Creature:new(
        data.id,
        data.description,
        data.pattern
    )
end

return Creature
