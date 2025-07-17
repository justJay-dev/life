local State = {}
State.__index = State

function State:new()
    local instance = setmetatable({}, State)
    instance.grid = {}
    instance.nextGrid = {}
    instance.running = false
    instance.timer = 0
    return instance
end

function State:getGrid()
    return self.grid
end

function State:getNextGrid()
    return self.nextGrid
end

function State:isRunning()
    return self.running
end

function State:getTimer()
    return self.timer
end

return State:new()
