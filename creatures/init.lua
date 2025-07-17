local Creature = require("engine/creature")
-- Creatures module - loads and manages all Game of Life patterns
local creatures = {}

-- Load all pattern modules (now they return Creature instances)
-- shapes
creatures.block = Creature.loadFromFile("creatures/block.json")
creatures.bee_hive = Creature.loadFromFile("creatures/bee-hive.json")
creatures.boat = Creature.loadFromFile("creatures/boat.json")
creatures.tub = Creature.loadFromFile("creatures/tub.json")
creatures.beacon = Creature.loadFromFile("creatures/beacon.json")
creatures.loaf = Creature.loadFromFile("creatures/loaf.json")
-- oscillators
creatures.blinker = Creature.loadFromFile("creatures/blinker.json")
creatures.toad = Creature.loadFromFile("creatures/toad.json")
creatures.pulsar = Creature.loadFromFile("creatures/pulsar.json")
-- -- space ships
creatures.glider = Creature.loadFromFile("creatures/glider.json")

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
function creatures.spawnRandom(grid, gridWidth, gridHeight, count)
    local creatureNames = creatures.getNames()
    if #creatureNames == 0 then return end

    count = count or math.random(3, 6) -- Default to 3-6 creatures
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

                -- Check if this area is clear (simple overlap prevention)
                local clear = true
                for checkX = x, math.min(x + size.width - 1, gridWidth) do
                    for checkY = y, math.min(y + size.height - 1, gridHeight) do
                        if grid[checkX] and grid[checkX][checkY] then
                            clear = false
                            break
                        end
                    end
                    if not clear then break end
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

return creatures
