-- Color management module for Game of Life
local Colors = {}
Colors.__index = Colors

-- Default color for manually placed cells and fallbacks
Colors.defaultCreatureColor = "red"

-- Creature colors (for spawned patterns)
Colors.creatures = {
    red = { 1, 0.2, 0.2 },
    yellow = { 1, 1, 0.2 },
    blue = { 0.2, 0.5, 1 },
    white = { 1, 1, 1 } -- For editor cells
}

-- ColorCollisions (red + yellow = orange, blue + red = purple, etc.)
Colors.creatureCombinations = {
    orange = { 1, 0.5, 0.2 }, -- red + yellow
    purple = { 0.5, 0.2, 1 }, -- blue + red
    green = { 0.2, 1, 0.2 },  -- yellow + blue
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
    border = { 0.4, 0.4, 0.4 },              -- UI border color

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
    local colorNames = {}
    for _, name in ipairs(Colors.getCreatureColorNames()) do
        if name ~= "white" then
            table.insert(colorNames, name)
        end
    end
    local randomName = colorNames[math.random(1, #colorNames)]
    return randomName, Colors.creatures[randomName]
end

-- Check if a color is a primary creature color
function Colors.isPrimaryColor(colorName)
    return Colors.creatures[colorName] ~= nil
end

-- Check if a color is a secondary (combination) color
function Colors.isSecondaryColor(colorName)
    return Colors.creatureCombinations[colorName] ~= nil
end

-- Get the collision result of two colors
function Colors.getColorCollision(color1, color2)
    -- If colors are the same, no collision
    if color1 == color2 then
        return color1
    end

    -- If either color is secondary, no collision (return the first color)
    if Colors.isSecondaryColor(color1) or Colors.isSecondaryColor(color2) then
        return color1
    end

    -- Check for specific combinations (order doesn't matter)
    if (color1 == "red" and color2 == "yellow") or (color1 == "yellow" and color2 == "red") then
        return "orange"
    elseif (color1 == "blue" and color2 == "red") or (color1 == "red" and color2 == "blue") then
        return "purple"
    elseif (color1 == "yellow" and color2 == "blue") or (color1 == "blue" and color2 == "yellow") then
        return "green"
    end

    -- No collision rule found, return first color
    return color1
end

-- Get color value (RGB) for any color name (creature or combination)
function Colors.getAnyColor(colorName)
    return Colors.creatures[colorName] or Colors.creatureCombinations[colorName] or Colors.creatures.red
end

return Colors
