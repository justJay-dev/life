-- Simulation Screen - Contains the actual Game of Life simulation
local Config = require("engine.config")
local State = require("engine.state")
local creatures = require("creatures.init")
local ScreenManager = require("engine.screen-manager")
local GameScreen = require("engine.game-screen")
local LeftMenu = require("ui.left-menu")

local SimulationScreen = GameScreen:new()

function SimulationScreen:enter()
    -- Set window title
    love.window.setTitle("Conway's Game of Life - Simulation")

    -- Initialize grids
    self:initializeGrid()
    -- Create left menu
    self.leftMenu = LeftMenu:new(0, 0, 220)
    self.leftMenu:setOnCreatureSelect(function(creatureName, creature)
        self:onCreatureSelected(creatureName, creature)
    end)

    -- Randomly spawn creatures
    math.randomseed(os.time()) -- Seed the random number generator
    creatures.spawnRandom(State.grid, Config.gridWidth, Config.gridHeight)
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
            State.grid[x][y] = false
            State.nextGrid[x][y] = false
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
    love.graphics.clear(0, 0, 0)

    -- Calculate grid offset based on left menu
    local gridOffsetX = self.leftMenu and self.leftMenu.width or 0

    -- Save current transform
    love.graphics.push()
    love.graphics.translate(gridOffsetX, 0)

    -- Draw grid using inherited method
    self:drawSimulationGrid(State.grid)

    -- Draw UI
    love.graphics.setColor(1, 1, 1)
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
            local alive = State.grid[x][y]

            -- Conway's Game of Life rules:
            -- 1. Any live cell with 2 or 3 neighbors survives
            -- 2. Any dead cell with exactly 3 neighbors becomes alive
            -- 3. All other cells die or stay dead
            if alive then
                State.nextGrid[x][y] = (neighbors == 2 or neighbors == 3)
            else
                State.nextGrid[x][y] = (neighbors == 3)
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
                    if State.grid[nx][ny] then
                        count = count + 1
                    end
                end
            end
        end
    end
    return count
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
            State.grid[gridX][gridY] = not State.grid[gridX][gridY]
        end
    end
end

function SimulationScreen:keypressed(key)
    if key == "space" then
        State.running = not State.running
    elseif key == "r" then
        self:initializeGrid()
        State.running = false
        -- Randomly spawn creatures again
        creatures.spawnRandom(State.grid, Config.gridWidth, Config.gridHeight)
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
    if creature and creature.pattern then
        self:spawnCreatureRandomly(creature)
    end
end

function SimulationScreen:spawnCreatureRandomly(creature)
    if not creature or not creature.pattern then return end

    -- Get pattern dimensions
    local patternHeight = #creature.pattern
    local patternWidth = patternHeight > 0 and #creature.pattern[1] or 0

    if patternWidth == 0 or patternHeight == 0 then return end

    -- Find a valid random position (with some margin from edges)
    local margin = 2
    local maxX = Config.gridWidth - patternWidth - margin
    local maxY = Config.gridHeight - patternHeight - margin

    if maxX < margin or maxY < margin then return end

    -- Place it at a random location
    local startX = math.random(margin + 1, maxX)
    local startY = math.random(margin + 1, maxY)

    -- Place the pattern
    for py = 1, patternHeight do
        for px = 1, patternWidth do
            if creature.pattern[py][px] then
                local gridX = startX + px - 1
                local gridY = startY + py - 1
                if gridX >= 1 and gridX <= Config.gridWidth and gridY >= 1 and gridY <= Config.gridHeight then
                    State.grid[gridX][gridY] = true
                end
            end
        end
    end
end

return SimulationScreen
