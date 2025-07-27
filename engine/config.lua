local Config = {}
Config.__index = Config

function Config:new()
    local instance = {
        gridWidth = 80,
        gridHeight = 60,
        cellSize = 10,
        updateRate = 0.1, -- seconds
        debug = false     -- Set to true to enable debug print statements
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

function Config:isDebug()
    return self.debug
end

-- Debug print function - only prints if debug mode is enabled
function Config:debugPrint(...)
    if self.debug then
        print(...)
    end
end

return Config:new()
