local Config = {}
Config.__index = Config

function Config:new()
    local instance = {
        gridWidth = 80,
        gridHeight = 60,
        cellSize = 10,
        updateRate = 0.1 -- seconds
    }
    setmetatable(instance, Config)
    return instance
end

function Config:gridWidth()
    return self.gridWidth
end

function Config:gridHeight()
    return self.gridHeight
end

function Config:cellSize()
    return self.cellSize
end

function Config:updateRate()
    return self.updateRate
end

return Config:new()
