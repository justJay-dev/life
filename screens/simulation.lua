-- Simulation Screen - Contains the actual Game of Life simulation
local Config = require("engine.config")
local State = require("engine.state")
local creatures = require("creatures.init")
local ScreenManager = require("engine.screen-manager")
local GameScreen = require("engine.game-screen")
local LeftMenu = require("ui.left-menu")
local Colors = require("engine.colors")

local SimulationScreen = GameScreen:new()

function SimulationScreen:enter()
    -- Initialize grids
    self:initializeGrid()
    -- Create left menu
    self.leftMenu = LeftMenu:new(0, 0, 220)
    self.leftMenu:setOnCreatureSelect(function(creatureName, creature)
        self:onCreatureSelected(creatureName, creature)
    end)

    -- Randomly spawn creatures (avoiding the spawning pool)
    math.randomseed(os.time()) -- Seed the random number generator
    local poolStartX, poolStartY, poolEndX, poolEndY = self:getSpawningPoolBounds()
    local excludeZone = {
        startX = poolStartX,
        startY = poolStartY,
        endX = poolEndX,
        endY = poolEndY
    }
    creatures.spawnRandom(State.grid, Config.gridWidth, Config.gridHeight, nil, excludeZone)
    Config:debugPrint("Randomly spawned creatures in the grid (avoiding spawning pool)")
end

function SimulationScreen:leave()
    -- Pause the simulation when leaving
    State.running = false
end

function SimulationScreen:initializeGrid()
    -- Initialize both grids as empty
    for x = 1, Config.gridWidth do
        State.grid[x] = {}
        State.nextGrid[x] = {}
        for y = 1, Config.gridHeight do
            State.grid[x][y] = { alive = false, color = Colors.defaultCreatureColor }
            State.nextGrid[x][y] = { alive = false, color = Colors.defaultCreatureColor }
        end
    end
end

function SimulationScreen:update(dt)
    State.timer = State.timer + dt

    if State.running and State.timer >= Config.updateRate then
        self:updateGrid()
        State.timer = 0
    end

    -- Update left menu
    if self.leftMenu then
        self.leftMenu:update(dt)
    end
end

function SimulationScreen:draw()
    -- Clear background
    local bgColor = Colors.ui.mainBackground
    love.graphics.clear(bgColor[1], bgColor[2], bgColor[3])

    -- Calculate grid offset based on left menu
    local gridOffsetX = self.leftMenu and self.leftMenu.width or 0

    -- Save current transform
    love.graphics.push()
    love.graphics.translate(gridOffsetX, 0)

    -- Draw grid with spawning pool
    self:drawSimulationGridWithPool(State.grid)

    -- Draw UI
    local textColor = Colors.ui.textDefault
    love.graphics.setColor(textColor[1], textColor[2], textColor[3])
    local statusText = State.running and "Running (SPACE to pause)" or "Paused (SPACE to start)"
    love.graphics.print(statusText, 10, Config.gridHeight * Config.cellSize + 10)
    love.graphics.print("Click to toggle cells | R to reset | M for menu | ESC to quit", 10,
        Config.gridHeight * Config.cellSize + 25)



    -- Restore transform
    love.graphics.pop()

    -- Draw left menu on top
    if self.leftMenu then
        self.leftMenu:draw()
    end
end

function SimulationScreen:updateGrid()
    -- Calculate next generation
    for x = 1, Config.gridWidth do
        for y = 1, Config.gridHeight do
            local neighbors = self:countNeighbors(x, y)
            local currentCell = State.grid[x][y]
            local alive = false
            local cellColor = Colors.defaultCreatureColor -- default color for new cells

            -- Handle object format with color information
            if type(currentCell) == "table" and currentCell.alive then
                alive = true
                cellColor = currentCell.color or Colors.defaultCreatureColor
            end

            -- Conway's Game of Life rules:
            -- 1. Any live cell with 2 or 3 neighbors survives
            -- 2. Any dead cell with exactly 3 neighbors becomes alive
            -- 3. All other cells die or stay dead
            local willSurvive = false
            if alive then
                willSurvive = (neighbors == 2 or neighbors == 3)
            else
                willSurvive = (neighbors == 3)
            end

            if willSurvive then
                -- Preserve color when cell survives or gets born
                -- For birth, inherit color from a random neighbor or use default
                if not alive then
                    cellColor = self:getNeighborColor(x, y) or Colors.defaultCreatureColor
                end
                State.nextGrid[x][y] = {
                    alive = true,
                    color = cellColor
                }
            else
                State.nextGrid[x][y] = { alive = false, color = Colors.defaultCreatureColor }
            end
        end
    end

    -- Swap grids
    State.grid, State.nextGrid = State.nextGrid, State.grid
end

function SimulationScreen:countNeighbors(x, y)
    local count = 0
    for dx = -1, 1 do
        for dy = -1, 1 do
            if dx ~= 0 or dy ~= 0 then -- Don't count the cell itself
                local nx, ny = x + dx, y + dy
                if nx >= 1 and nx <= Config.gridWidth and ny >= 1 and ny <= Config.gridHeight then
                    local cell = State.grid[nx][ny]
                    local isAlive = false

                    -- Handle object format
                    if type(cell) == "table" and cell.alive then
                        isAlive = true
                    end

                    if isAlive then
                        count = count + 1
                    end
                end
            end
        end
    end
    return count
end

function SimulationScreen:getNeighborColor(x, y)
    -- Get colors from all neighboring alive cells for new births
    local neighborColors = {}

    for dx = -1, 1 do
        for dy = -1, 1 do
            if dx ~= 0 or dy ~= 0 then -- Don't count the cell itself
                local nx, ny = x + dx, y + dy
                if nx >= 1 and nx <= Config.gridWidth and ny >= 1 and ny <= Config.gridHeight then
                    local cell = State.grid[nx][ny]
                    if type(cell) == "table" and cell.alive and cell.color then
                        table.insert(neighborColors, cell.color)
                    end
                end
            end
        end
    end

    -- If no colored neighbors, use default
    if #neighborColors == 0 then
        return Colors.defaultCreatureColor
    end

    -- If only one neighbor color, use that
    if #neighborColors == 1 then
        return neighborColors[1]
    end

    -- Multiple neighbors - check for color collisions
    local resultColor = neighborColors[1]
    for i = 2, #neighborColors do
        resultColor = Colors.getColorCollision(resultColor, neighborColors[i])
    end

    return resultColor
end

function SimulationScreen:mousepressed(x, y, button)
    -- Check if left menu handled the click first
    if self.leftMenu and self.leftMenu:mousepressed(x, y, button) then
        return
    end

    if button == 1 then -- Left mouse button
        -- Adjust for grid offset
        local gridOffsetX = self.leftMenu and self.leftMenu.width or 0
        local adjustedX = x - gridOffsetX

        local gridX = math.floor(adjustedX / Config.cellSize) + 1
        local gridY = math.floor(y / Config.cellSize) + 1

        if gridX >= 1 and gridX <= Config.gridWidth and gridY >= 1 and gridY <= Config.gridHeight then
            local currentCell = State.grid[gridX][gridY]
            local isAlive = false

            -- Handle object format
            if type(currentCell) == "table" and currentCell.alive then
                isAlive = true
            end

            if isAlive then
                State.grid[gridX][gridY] = { alive = false, color = Colors.defaultCreatureColor }
            else
                State.grid[gridX][gridY] = {
                    alive = true,
                    color = Colors.defaultCreatureColor -- default color for manually placed cells
                }
            end
        end
    end
end

function SimulationScreen:keypressed(key)
    if key == "space" then
        State.running = not State.running
    elseif key == "r" then
        self:initializeGrid()
        State.running = false
        -- Randomly spawn creatures again (avoiding the spawning pool)
        local poolStartX, poolStartY, poolEndX, poolEndY = self:getSpawningPoolBounds()
        local excludeZone = {
            startX = poolStartX,
            startY = poolStartY,
            endX = poolEndX,
            endY = poolEndY
        }
        creatures.spawnRandom(State.grid, Config.gridWidth, Config.gridHeight, nil, excludeZone)
    elseif key == "m" then
        -- Go back to main menu
        ScreenManager:switchTo("main_menu")
    elseif key == "escape" then
        love.event.quit()
    end
end

function SimulationScreen:mousemoved(x, y)
    if self.leftMenu then
        self.leftMenu:mousemoved(x, y)
    end
end

function SimulationScreen:wheelmoved(x, y)
    if self.leftMenu and self.leftMenu:wheelmoved(x, y) then
        return
    end
    -- Handle other wheel events here if needed
end

function SimulationScreen:onCreatureSelected(creatureName, creature)
    Config:debugPrint("=== onCreatureSelected called ===")
    Config:debugPrint("creatureName:", creatureName)
    Config:debugPrint("creature:", creature)
    if creature then
        Config:debugPrint("creature.pattern:", creature.pattern)
        if creature.pattern then
            Config:debugPrint("Pattern found, calling spawnCreatureInCenter")
            self:spawnCreatureInCenter(creature)
        else
            Config:debugPrint("No pattern in creature")
        end
    else
        Config:debugPrint("No creature object")
    end
end

function SimulationScreen:spawnCreatureInCenter(creature)
    Config:debugPrint("=== spawnCreatureInCenter called ===")
    if not creature or not creature.pattern then
        Config:debugPrint("Early return: no creature or pattern")
        return
    end

    -- Get a random color for this spawn
    local spawnColor = Colors.getRandomCreatureColor()

    -- Get pattern dimensions
    local patternHeight = #creature.pattern
    local patternWidth = patternHeight > 0 and #creature.pattern[1] or 0
    Config:debugPrint("Pattern dimensions:", patternWidth, "x", patternHeight)

    if patternWidth == 0 or patternHeight == 0 then
        Config:debugPrint("Early return: zero dimensions")
        return
    end

    -- Get spawning pool bounds
    local poolStartX, poolStartY, poolEndX, poolEndY = self:getSpawningPoolBounds()
    local poolWidth = poolEndX - poolStartX + 1
    local poolHeight = poolEndY - poolStartY + 1

    -- Check if pattern fits in the spawning pool
    if patternWidth > poolWidth or patternHeight > poolHeight then
        Config:debugPrint("Early return: pattern too large for spawning pool")
        return
    end

    -- Calculate random position within the spawning pool
    local maxStartX = poolEndX - patternWidth + 1
    local maxStartY = poolEndY - patternHeight + 1
    local startX = math.random(poolStartX, maxStartX)
    local startY = math.random(poolStartY, maxStartY)
    Config:debugPrint("Spawning in pool at:", startX, startY)

    -- Clear the spawning area first to avoid overlap
    for py = 1, patternHeight do
        for px = 1, patternWidth do
            local gridX = startX + px - 1
            local gridY = startY + py - 1
            if gridX >= 1 and gridX <= Config.gridWidth and gridY >= 1 and gridY <= Config.gridHeight then
                State.grid[gridX][gridY] = { alive = false, color = Colors.defaultCreatureColor }
            end
        end
    end

    -- Place the pattern
    local cellsSet = 0
    for py = 1, patternHeight do
        for px = 1, patternWidth do
            if creature.pattern[py][px] then
                local gridX = startX + px - 1
                local gridY = startY + py - 1
                if gridX >= 1 and gridX <= Config.gridWidth and gridY >= 1 and gridY <= Config.gridHeight then
                    State.grid[gridX][gridY] = {
                        alive = true,
                        color = spawnColor
                    }
                    cellsSet = cellsSet + 1
                    Config:debugPrint("Set cell at", gridX, gridY, "with color", spawnColor)
                end
            end
        end
    end
    Config:debugPrint("Total cells set:", cellsSet)
end

function SimulationScreen:getSpawningPoolBounds()
    -- Define spawning pool as a region in the center of the grid
    -- Make it large enough to accommodate most creatures
    local poolWidth = math.min(20, math.floor(Config.gridWidth * 0.4))
    local poolHeight = math.min(20, math.floor(Config.gridHeight * 0.4))

    local startX = math.floor((Config.gridWidth - poolWidth) / 2) + 1
    local startY = math.floor((Config.gridHeight - poolHeight) / 2) + 1
    local endX = startX + poolWidth - 1
    local endY = startY + poolHeight - 1

    return startX, startY, endX, endY, poolWidth, poolHeight
end

function SimulationScreen:drawSpawningPool()
    local startX, startY, endX, endY = self:getSpawningPoolBounds()

    -- Draw the spawning pool background
    local bgColor = Colors.ui.poolBackground
    love.graphics.setColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
    local screenX = (startX - 1) * Config.cellSize
    local screenY = (startY - 1) * Config.cellSize
    local poolScreenWidth = (endX - startX + 1) * Config.cellSize
    local poolScreenHeight = (endY - startY + 1) * Config.cellSize

    love.graphics.rectangle("fill", screenX, screenY, poolScreenWidth, poolScreenHeight)

    -- Draw a border around the spawning pool
    local borderColor = Colors.ui.poolBorder
    love.graphics.setColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4])
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", screenX, screenY, poolScreenWidth, poolScreenHeight)
    love.graphics.setLineWidth(1) -- Reset line width
end

function SimulationScreen:drawSimulationGridWithPool(grid)
    -- First draw the spawning pool
    self:drawSpawningPool()

    -- Then draw the regular grid on top using the inherited method that handles colors
    self:drawGrid(grid, Colors.ui.aliveDefault, Colors.ui.deadDefault)
end

return SimulationScreen
