local Creature = require("engine/creature")
local Config = require("engine.config")
-- Creatures module - loads and manages all Game of Life patterns
local creatures = {}

-- Load all pattern modules (now they return Creature instances)
-- shapes
creatures.beacon = Creature.loadFromFile("creatures/shapes/beacon.json")
creatures.bee_hive = Creature.loadFromFile("creatures/shapes/bee-hive.json")
creatures.block = Creature.loadFromFile("creatures/shapes/block.json")
creatures.boat = Creature.loadFromFile("creatures/shapes/boat.json")
creatures.loaf = Creature.loadFromFile("creatures/shapes/loaf.json")
creatures.tub = Creature.loadFromFile("creatures/shapes/tub.json")
-- oscillators
creatures.blinker = Creature.loadFromFile("creatures/oscillators/blinker.json")
creatures.toad = Creature.loadFromFile("creatures/oscillators/toad.json")
creatures.pulsar = Creature.loadFromFile("creatures/oscillators/pulsar.json")
-- space ships
creatures.glider = Creature.loadFromFile("creatures/ships/glider.json")

-- Function to load custom creatures from directory
local function loadCustomCreatures()
    local customDir = "creatures/custom"
    local files = love.filesystem.getDirectoryItems(customDir)

    for _, filename in ipairs(files) do
        -- Check if it's a JSON file
        if filename:match("%.json$") then
            local filepath = customDir .. "/" .. filename
            Config:debugPrint("Loading custom creature: " .. filepath)

            -- Extract creature name from filename (remove .json extension)
            local creatureName = filename:gsub("%.json$", "")

            -- Load the creature
            local creature = Creature.loadFromFile(filepath)
            if creature then
                creatures[creatureName] = creature
                Config:debugPrint("Successfully loaded custom creature: " .. creatureName)
            else
                Config:debugPrint("Failed to load custom creature: " .. filename)
            end
        end
    end
end

-- Load custom creatures
loadCustomCreatures()

-- Function to spawn a creature by name
function creatures.spawn(name, grid, x, y, gridWidth, gridHeight)
    local creature = creatures[name]
    if creature and creature.create then
        return creature:create(grid, x, y, gridWidth, gridHeight)
    end
    return false
end

-- Get list of all available creatures
function creatures.getAvailable()
    local available = {}
    for name, creature in pairs(creatures) do
        if type(creature) == "table" and creature.create then
            table.insert(available, {
                name = creature:getName(),
                size = creature:getSize(),
                description = creature:getDescription()
            })
        end
    end
    return available
end

-- Function to get a specific creature by name
function creatures.get(name)
    return creatures[name]
end

-- Function to get all creature names
function creatures.getNames()
    local names = {}
    for name, creature in pairs(creatures) do
        if type(creature) == "table" and creature.create then
            table.insert(names, name)
        end
    end
    return names
end

-- Function to randomly spawn creatures across the grid
function creatures.spawnRandom(grid, gridWidth, gridHeight, count, excludeZone)
    local creatureNames = creatures.getNames()
    if #creatureNames == 0 then return end

    count = count or math.random(6, 12) -- Default to 6-12 creatures
    local spawned = {}

    for i = 1, count do
        -- Pick a random creature
        local randomName = creatureNames[math.random(#creatureNames)]
        local creature = creatures[randomName]

        if creature then
            local size = creature:getSize()
            local attempts = 0
            local maxAttempts = 20

            -- Try to find a good spawn location
            repeat
                local x = math.random(1, math.max(1, gridWidth - size.width))
                local y = math.random(1, math.max(1, gridHeight - size.height))

                -- Check if this creature would overlap with the exclusion zone (spawning pool)
                local inExclusionZone = false
                if excludeZone then
                    local creatureEndX = x + size.width - 1
                    local creatureEndY = y + size.height - 1

                    -- Check if creature overlaps with exclusion zone
                    if not (creatureEndX < excludeZone.startX or x > excludeZone.endX or
                            creatureEndY < excludeZone.startY or y > excludeZone.endY) then
                        inExclusionZone = true
                    end
                end

                -- Check if this area is clear (simple overlap prevention)
                local clear = true
                if not inExclusionZone then
                    for checkX = x, math.min(x + size.width - 1, gridWidth) do
                        for checkY = y, math.min(y + size.height - 1, gridHeight) do
                            local cell = grid[checkX] and grid[checkX][checkY]
                            local isAlive = false

                            -- Handle object format
                            if type(cell) == "table" and cell.alive then
                                isAlive = true
                            end

                            if isAlive then
                                clear = false
                                break
                            end
                        end
                        if not clear then break end
                    end
                else
                    clear = false -- Force retry if in exclusion zone
                end

                if clear then
                    local success = creatures.spawn(randomName, grid, x, y, gridWidth, gridHeight)
                    if success then
                        table.insert(spawned, { name = randomName, x = x, y = y })
                        break
                    end
                end

                attempts = attempts + 1
            until attempts >= maxAttempts
        end
    end

    return spawned
end

-- Function to reload custom creatures (useful for development)
function creatures.reloadCustom()
    -- Remove existing custom creatures
    for name, creature in pairs(creatures) do
        if type(creature) == "table" and creature.create then
            -- Check if it's a custom creature (you might want to add a flag for this)
            local isBuiltIn = name == "beacon" or name == "bee_hive" or name == "block" or
                name == "boat" or name == "loaf" or name == "tub" or
                name == "blinker" or name == "toad" or name == "pulsar" or
                name == "glider"
            if not isBuiltIn then
                creatures[name] = nil
            end
        end
    end

    -- Reload custom creatures
    loadCustomCreatures()
end

return creatures
