-- Color management module for Game of Life
local Colors = {}
Colors.__index = Colors

-- Default color for manually placed cells and fallbacks
Colors.defaultCreatureColor = "red"

-- Creature colors (for spawned patterns)
Colors.creatures = {
    red = { 1, 0.2, 0.2 },
    yellow = { 1, 1, 0.2 },
    blue = { 0.2, 0.5, 1 }
}

-- UI and grid colors
Colors.ui = {
    -- Grid colors
    aliveDefault = { 1, 1, 1 },      -- Default white for alive cells
    deadDefault = { 0.1, 0.1, 0.1 }, -- Default dark gray for dead cells

    -- Editor specific colors
    editorAlive = { 0.9, 0.9, 0.9 }, -- Light gray for editor alive cells
    editorDead = { 0.2, 0.2, 0.2 },  -- Darker gray for editor dead cells

    -- Spawning pool colors
    poolBackground = { 0.1, 0.3, 0.1, 0.3 }, -- Semi-transparent green
    poolBorder = { 0.2, 0.6, 0.2, 0.8 },     -- More opaque green border

    -- Background colors
    mainBackground = { 0, 0, 0 },            -- Black
    menuBackground = { 0.1, 0.1, 0.3 },      -- Dark blue for main menu
    editorBackground = { 0.05, 0.05, 0.15 }, -- Dark blue for editor
    uiBackground = { 0.1, 0.1, 0.2 },        -- UI area background

    -- Text colors
    textDefault = { 1, 1, 1 }, -- White text
}

-- Get available creature color names
function Colors.getCreatureColorNames()
    local names = {}
    for colorName, _ in pairs(Colors.creatures) do
        table.insert(names, colorName)
    end
    table.sort(names) -- Consistent ordering
    return names
end

-- Get a creature color by name, with fallback
function Colors.getCreatureColor(colorName)
    return Colors.creatures[colorName] or Colors.creatures.red
end

-- Get a random creature color
function Colors.getRandomCreatureColor()
    local colorNames = Colors.getCreatureColorNames()
    local randomName = colorNames[math.random(1, #colorNames)]
    return randomName, Colors.creatures[randomName]
end

return Colors
