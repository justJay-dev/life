local Button = require("ui.button")
local creatures = require("creatures.init")

local LeftMenu = {}
LeftMenu.__index = LeftMenu

function LeftMenu:new(x, y, width)
    local instance = setmetatable({}, LeftMenu)
    instance.x = x or 0
    instance.y = y or 0
    instance.width = width or 200
    instance.height = love.graphics.getHeight()
    instance.backgroundColor = { 0.1, 0.1, 0.1, 0.9 } -- Dark semi-transparent background
    instance.borderColor = { 0.4, 0.4, 0.4 }
    instance.textColor = { 1, 1, 1 }
    instance.visible = true
    instance.scrollOffset = 0
    instance.maxScrollOffset = 0
    instance.creatureButtons = {}
    instance.selectedCreature = nil
    instance.onCreatureSelect = nil -- Callback function when creature is selected

    -- Create header
    instance.headerHeight = 40
    instance.headerFont = love.graphics.newFont(18)
    instance.buttonFont = love.graphics.newFont(14)

    -- Initialize creature buttons
    instance:initializeCreatureButtons()

    return instance
end

function LeftMenu:initializeCreatureButtons()
    self.creatureButtons = {}
    local buttonHeight = 35
    local buttonMargin = 5
    local currentY = self.y + self.headerHeight + buttonMargin

    -- Dynamically scan creatures directory for groups
    local creatureGroups = {}
    local creaturesPath = "creatures"

    -- Get all items in the creatures directory
    local items = love.filesystem.getDirectoryItems(creaturesPath)

    for _, item in ipairs(items) do
        local itemPath = creaturesPath .. "/" .. item
        local info = love.filesystem.getInfo(itemPath)

        -- Only process directories (ignore .lua files and other files)
        if info and info.type == "directory" then
            local groupName = item:gsub("^%l", string.upper) -- Capitalize first letter
            local creatures_in_group = {}

            -- Get all .json files in this directory
            local groupItems = love.filesystem.getDirectoryItems(itemPath)
            for _, groupItem in ipairs(groupItems) do
                if groupItem:match("%.json$") then -- Only .json files
                    local creatureName = groupItem:gsub("%.json$", ""):gsub("-", "_")
                    table.insert(creatures_in_group, creatureName)
                end
            end

            -- Sort creatures alphabetically
            table.sort(creatures_in_group)

            if #creatures_in_group > 0 then
                table.insert(creatureGroups, {
                    name = groupName,
                    creatures = creatures_in_group
                })
            end
        end
    end

    -- Sort groups alphabetically by name
    table.sort(creatureGroups, function(a, b) return a.name < b.name end)

    -- Create buttons for each group
    for _, group in ipairs(creatureGroups) do
        if #group.creatures > 0 then
            -- Group header
            local groupHeader = {
                type = "header",
                text = group.name,
                y = currentY,
                height = 25
            }
            table.insert(self.creatureButtons, groupHeader)
            currentY = currentY + groupHeader.height + buttonMargin

            -- Creature buttons in this group
            for _, creatureName in ipairs(group.creatures) do
                local creature = creatures[creatureName]
                if creature then
                    local displayName = creature.name or creatureName:gsub("_", " "):gsub("^%l", string.upper)
                    local button = Button:new(
                        self.x + buttonMargin,
                        currentY,
                        self.width - (buttonMargin * 2),
                        buttonHeight,
                        displayName,
                        function() self:selectCreature(creatureName) end,
                        self.buttonFont
                    )
                    button.creatureName = creatureName
                    button.creature = creature
                    table.insert(self.creatureButtons, button)
                    currentY = currentY + buttonHeight + buttonMargin
                end
            end

            -- Add some spacing after each group
            currentY = currentY + buttonMargin
        end
    end

    -- Calculate max scroll offset
    local totalContentHeight = currentY - (self.y + self.headerHeight)
    local availableHeight = self.height - self.headerHeight
    self.maxScrollOffset = math.max(0, totalContentHeight - availableHeight)
end

function LeftMenu:selectCreature(creatureName)
    self.selectedCreature = creatureName
    if self.onCreatureSelect then
        local creature = creatures[creatureName]
        self.onCreatureSelect(creatureName, creature)
    end
end

function LeftMenu:setOnCreatureSelect(callback)
    self.onCreatureSelect = callback
end

function LeftMenu:update(dt)
    if not self.visible then return end

    -- Update creature buttons
    for _, item in ipairs(self.creatureButtons) do
        if item.update then
            item:update(dt)
        end
    end
end

function LeftMenu:draw()
    if not self.visible then return end

    -- Save current graphics state
    local previousColor = { love.graphics.getColor() }
    local previousFont = love.graphics.getFont()

    -- Enable scissor test for scrolling
    love.graphics.setScissor(self.x, self.y, self.width, self.height)

    -- Draw background
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Draw border
    love.graphics.setColor(self.borderColor)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    -- Draw header
    love.graphics.setColor(self.textColor)
    love.graphics.setFont(self.headerFont)
    love.graphics.print("Creatures", self.x + 10, self.y + 10)

    -- Draw header separator
    love.graphics.setColor(self.borderColor)
    love.graphics.line(self.x + 5, self.y + self.headerHeight, self.x + self.width - 5, self.y + self.headerHeight)

    -- Draw creature buttons with scroll offset
    love.graphics.push()
    love.graphics.translate(0, -self.scrollOffset)

    for _, item in ipairs(self.creatureButtons) do
        if item.type == "header" then
            -- Draw group header
            love.graphics.setColor(0.6, 0.6, 0.6)
            love.graphics.setFont(self.buttonFont)
            love.graphics.print(item.text, self.x + 10, item.y)
        else
            -- Highlight selected creature
            if item.creatureName == self.selectedCreature then
                love.graphics.setColor(0.2, 0.6, 0.2, 0.3) -- Green highlight
                love.graphics.rectangle("fill", item.x, item.y, item.width, item.height)
            end

            -- Draw creature button
            item:draw()
        end
    end

    love.graphics.pop()

    -- Disable scissor test
    love.graphics.setScissor()

    -- Draw scroll indicators if needed
    if self.maxScrollOffset > 0 then
        local scrollbarWidth = 8
        local scrollbarX = self.x + self.width - scrollbarWidth - 2
        local scrollbarY = self.y + self.headerHeight + 2
        local scrollbarHeight = self.height - self.headerHeight - 4

        -- Scrollbar background
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", scrollbarX, scrollbarY, scrollbarWidth, scrollbarHeight)

        -- Scrollbar thumb
        local thumbHeight = math.max(20, scrollbarHeight * (scrollbarHeight / (scrollbarHeight + self.maxScrollOffset)))
        local thumbY = scrollbarY + (self.scrollOffset / self.maxScrollOffset) * (scrollbarHeight - thumbHeight)
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.rectangle("fill", scrollbarX, thumbY, scrollbarWidth, thumbHeight)
    end

    -- Restore graphics state
    love.graphics.setColor(previousColor)
    love.graphics.setFont(previousFont)
end

function LeftMenu:mousepressed(x, y, button)
    if not self.visible then return false end

    -- Check if click is within menu bounds
    if x < self.x or x > self.x + self.width or y < self.y or y > self.y + self.height then
        return false
    end

    -- Check creature button clicks
    for _, item in ipairs(self.creatureButtons) do
        if item.mousepressed then
            local adjustedY = y + self.scrollOffset
            if x >= item.x and x <= item.x + item.width and
                adjustedY >= item.y and adjustedY <= item.y + item.height then
                item:mousepressed(x, adjustedY, button)
                return true
            end
        end
    end

    return true -- Consume the click even if no button was pressed
end

function LeftMenu:mousemoved(x, y)
    if not self.visible then return end

    -- Update hover states for creature buttons
    for _, item in ipairs(self.creatureButtons) do
        if item.mousemoved then
            local adjustedY = y + self.scrollOffset
            local wasHovered = item.hovered
            item.hovered = (x >= item.x and x <= item.x + item.width and
                adjustedY >= item.y and adjustedY <= item.y + item.height and
                x >= self.x and x <= self.x + self.width and
                y >= self.y and y <= self.y + self.height)
        end
    end
end

function LeftMenu:wheelmoved(x, y)
    if not self.visible then return false end

    -- Get mouse position to check if it's over the menu
    local mouseX, mouseY = love.mouse.getPosition()
    if mouseX < self.x or mouseX > self.x + self.width or mouseY < self.y or mouseY > self.y + self.height then
        return false
    end

    -- Scroll the menu
    local scrollSpeed = 30
    self.scrollOffset = self.scrollOffset - (y * scrollSpeed)
    self.scrollOffset = math.max(0, math.min(self.scrollOffset, self.maxScrollOffset))

    return true
end

function LeftMenu:toggle()
    self.visible = not self.visible
end

function LeftMenu:show()
    self.visible = true
end

function LeftMenu:hide()
    self.visible = false
end

function LeftMenu:refresh()
    -- Refresh the creature list (useful when custom creatures are added/removed)
    self:initializeCreatureButtons()
end

function LeftMenu:getSelectedCreature()
    return self.selectedCreature
end

function LeftMenu:getSelectedCreatureObject()
    if self.selectedCreature then
        return creatures[self.selectedCreature]
    end
    return nil
end

return LeftMenu
