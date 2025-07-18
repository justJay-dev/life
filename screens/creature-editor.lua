-- Creature Editor Screen - Create and edit custom Game of Life patterns
local Config = require("engine.config")
local State = require("engine.state")
local ScreenManager = require("engine.screen-manager")
local GameScreen = require("engine.game-screen")
local Button = require("ui.button")
local Dialog = require("ui.dialog")
local LeftMenu = require("ui.left-menu")

local CreatureEditorScreen = GameScreen:new()

function CreatureEditorScreen:enter()
    love.window.setTitle("Conway's Game of Life - Creature Editor")

    -- Initialize editor state
    self.editorGrid = {}
    self.creatureName = ""
    self.creatureDescription = ""

    -- Initialize drag state
    self.isDragging = false

    -- Initialize empty grid
    self:clearGrid()

    -- Create left menu
    self.leftMenu = LeftMenu:new(0, 0, 220)
    self.leftMenu:setOnCreatureSelect(function(creatureName, creature)
        self:onCreatureSelected(creatureName, creature)
    end)

    -- Create buttons
    self:createButtons()

    -- Create dialogs
    self:createDialogs()
end

function CreatureEditorScreen:createButtons()
    local windowWidth = love.graphics.getWidth()
    local buttonY = Config.gridHeight * Config.cellSize + 30
    local buttonHeight = 25
    local buttonSpacing = 10
    local buttonFont = love.graphics.newFont(12)

    -- Create main UI buttons
    self.clearButton = Button:new(10, buttonY, 60, buttonHeight, "Clear", function()
        self:clearGrid()
    end, buttonFont)

    self.nameButton = Button:new(80, buttonY, 80, buttonHeight, "Set Name", function()
        self.nameDialog:setText(self.creatureName)
        self.nameDialog:show()
    end, buttonFont)

    self.descButton = Button:new(170, buttonY, 100, buttonHeight, "Set Description", function()
        self.descDialog:setText(self.creatureDescription)
        self.descDialog:show()
    end, buttonFont)

    self.saveButton = Button:new(280, buttonY, 60, buttonHeight, "Save", function()
        if self.creatureName ~= "" and self:hasPattern() then
            local success, message = self:saveCreature()
            print(message) -- You could show this in a popup later
        end
    end, buttonFont)

    self.backButton = Button:new(windowWidth - 70, buttonY, 60, buttonHeight, "Back", function()
        ScreenManager:switchTo("main_menu")
    end, buttonFont)
end

function CreatureEditorScreen:createDialogs()
    -- Create name input dialog
    self.nameDialog = Dialog:new("Enter Creature Name", "", function(text)
        self.creatureName = text
    end, function()
        -- Cancel callback - do nothing
    end)

    -- Create description input dialog
    self.descDialog = Dialog:new("Enter Creature Description", "", function(text)
        self.creatureDescription = text
    end, function()
        -- Cancel callback - do nothing
    end)
end

function CreatureEditorScreen:clearGrid()
    for x = 1, Config.gridWidth do
        self.editorGrid[x] = {}
        for y = 1, Config.gridHeight do
            self.editorGrid[x][y] = false
        end
    end
end

function CreatureEditorScreen:leave()
    -- Cleanup when leaving editor
end

function CreatureEditorScreen:update(dt)
    -- Update left menu
    if self.leftMenu then
        self.leftMenu:update(dt)
    end

    -- Update button hover states
    if self.clearButton then self.clearButton:update(dt) end
    if self.nameButton then self.nameButton:update(dt) end
    if self.descButton then self.descButton:update(dt) end
    if self.saveButton then
        -- Update save button enabled state
        local canSave = self.creatureName ~= "" and self:hasPattern()
        self.saveButton:setEnabled(canSave)
        self.saveButton:update(dt)
    end
    if self.backButton then self.backButton:update(dt) end

    -- Update dialogs
    if self.nameDialog then self.nameDialog:update(dt) end
    if self.descDialog then self.descDialog:update(dt) end
end

function CreatureEditorScreen:draw()
    -- Clear background
    love.graphics.clear(0.05, 0.05, 0.15)

    -- Calculate grid offset based on left menu
    local gridOffsetX = self.leftMenu and self.leftMenu.visible and self.leftMenu.width or 0

    -- Save current transform
    love.graphics.push()
    love.graphics.translate(gridOffsetX, 0)

    -- Draw grid using inherited method
    self:drawEditorGrid(self.editorGrid)

    -- Draw UI
    self:drawUI()

    -- Restore transform
    love.graphics.pop()

    -- Draw left menu on top
    if self.leftMenu then
        self.leftMenu:draw()
    end

    -- Draw dialogs on top of everything
    if self.nameDialog then self.nameDialog:draw() end
    if self.descDialog then self.descDialog:draw() end
end

function CreatureEditorScreen:drawUI()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    local uiY = Config.gridHeight * Config.cellSize + 10

    -- Background for UI area
    love.graphics.setColor(0.1, 0.1, 0.2)
    love.graphics.rectangle("fill", 0, uiY - 5, windowWidth, 40)

    -- Instructions
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("Click or drag to draw/erase cells | Name: " .. self.creatureName, 10, uiY)

    -- Draw buttons
    if self.clearButton then self.clearButton:draw() end
    if self.nameButton then self.nameButton:draw() end
    if self.descButton then self.descButton:draw() end
    if self.saveButton then self.saveButton:draw() end
    if self.backButton then self.backButton:draw() end
end

function CreatureEditorScreen:hasPattern()
    for x = 1, Config.gridWidth do
        for y = 1, Config.gridHeight do
            if self.editorGrid[x][y] then
                return true
            end
        end
    end
    return false
end

function CreatureEditorScreen:saveCreature()
    if self.creatureName == "" then
        return false, "Creature name is required"
    end

    if not self:hasPattern() then
        return false, "Creature must have at least one alive cell"
    end

    -- Find the bounding box of the pattern
    local minX, maxX = Config.gridWidth, 1
    local minY, maxY = Config.gridHeight, 1

    for x = 1, Config.gridWidth do
        for y = 1, Config.gridHeight do
            if self.editorGrid[x][y] then
                minX = math.min(minX, x)
                maxX = math.max(maxX, x)
                minY = math.min(minY, y)
                maxY = math.max(maxY, y)
            end
        end
    end

    -- Extract the pattern
    local pattern = {}
    for y = minY, maxY do
        local row = {}
        for x = minX, maxX do
            table.insert(row, self.editorGrid[x][y])
        end
        table.insert(pattern, row)
    end

    -- Create creature data
    local creatureData = {
        id = self.creatureName:lower():gsub(" ", "_"),
        name = self.creatureName,
        description = self.creatureDescription ~= "" and self.creatureDescription or "Custom creature",
        pattern = pattern,
        category = "custom"
    }

    -- Save to file
    local parsing = require("engine.parsing")
    local filename = "creatures/custom/" .. creatureData.id .. ".json"

    local success, err = parsing.saveCreature(filename, creatureData)
    if not success then
        return false, err or "Failed to save creature"
    end

    return true, "Creature saved successfully!"
end

function CreatureEditorScreen:mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        -- Handle dialog clicks first
        if self.nameDialog then self.nameDialog:mousepressed(x, y, button) end
        if self.descDialog then self.descDialog:mousepressed(x, y, button) end

        -- Check if left menu handled the click
        if self.leftMenu and self.leftMenu:mousepressed(x, y, button) then
            return
        end

        -- Only handle main UI if no dialogs are visible
        if not (self.nameDialog and self.nameDialog:isVisible()) and
            not (self.descDialog and self.descDialog:isVisible()) then
            -- Handle main UI button clicks
            if self.clearButton then self.clearButton:mousepressed(button) end
            if self.nameButton then self.nameButton:mousepressed(button) end
            if self.descButton then self.descButton:mousepressed(button) end
            if self.saveButton then self.saveButton:mousepressed(button) end
            if self.backButton then self.backButton:mousepressed(button) end

            -- Handle grid clicks and start dragging
            -- Adjust for grid offset
            local gridOffsetX = self.leftMenu and self.leftMenu.visible and self.leftMenu.width or 0
            local adjustedX = x - gridOffsetX

            local gridX = math.floor(adjustedX / Config.cellSize) + 1
            local gridY = math.floor(y / Config.cellSize) + 1

            if gridX >= 1 and gridX <= Config.gridWidth and gridY >= 1 and gridY <= Config.gridHeight then
                -- Start dragging and toggle the cell
                self.isDragging = true
                self:toggleCell(gridX, gridY)
            end
        end
    end
end

function CreatureEditorScreen:mousereleased(x, y, button)
    if button == 1 then -- Left mouse button
        -- Stop dragging
        self.isDragging = false
    end
end

function CreatureEditorScreen:mousemoved(x, y, dx, dy)
    -- Update left menu hover states
    if self.leftMenu then
        self.leftMenu:mousemoved(x, y)
    end

    -- Handle dragging - simply fill the cell under the mouse
    if self.isDragging and not (self.nameDialog and self.nameDialog:isVisible()) and
        not (self.descDialog and self.descDialog:isVisible()) then
        -- Adjust for grid offset
        local gridOffsetX = self.leftMenu and self.leftMenu.visible and self.leftMenu.width or 0
        local adjustedX = x - gridOffsetX

        local gridX = math.floor(adjustedX / Config.cellSize) + 1
        local gridY = math.floor(y / Config.cellSize) + 1

        if gridX >= 1 and gridX <= Config.gridWidth and gridY >= 1 and gridY <= Config.gridHeight then
            -- Simply set the cell to alive (true)
            self.editorGrid[gridX][gridY] = true
        end
    end
end

-- Simple function to toggle a cell's state
function CreatureEditorScreen:toggleCell(x, y)
    self.editorGrid[x][y] = not self.editorGrid[x][y]
end

function CreatureEditorScreen:keypressed(key)
    -- Handle dialog key presses first
    if self.nameDialog then self.nameDialog:keypressed(key) end
    if self.descDialog then self.descDialog:keypressed(key) end

    -- Only handle main UI keys if no dialogs are visible
    if not (self.nameDialog and self.nameDialog:isVisible()) and
        not (self.descDialog and self.descDialog:isVisible()) then
        if key == "escape" or key == "m" then
            ScreenManager:switchTo("main_menu")
        elseif key == "r" or key == "c" then
            self:clearGrid()
        elseif key == "l" then
            -- Toggle left menu visibility
            if self.leftMenu then
                self.leftMenu:toggle()
            end
        end
    end
end

function CreatureEditorScreen:wheelmoved(x, y)
    if self.leftMenu and self.leftMenu:wheelmoved(x, y) then
        return
    end
    -- Handle other wheel events here if needed
end

function CreatureEditorScreen:onCreatureSelected(creatureName, creature)
    -- Load the selected creature into the editor
    if creature and creature.pattern then
        -- Clear the current grid
        self:clearGrid()

        -- Load the creature pattern
        for y, row in ipairs(creature.pattern) do
            for x, cell in ipairs(row) do
                if x <= Config.gridWidth and y <= Config.gridHeight then
                    self.editorGrid[x][y] = cell
                end
            end
        end

        -- Set the creature name and description
        self.creatureName = creature.name or creatureName
        self.creatureDescription = creature.description or ""

        print("Loaded creature: " .. self.creatureName)
    end
end

function CreatureEditorScreen:textinput(text)
    -- Handle dialog text input
    if self.nameDialog then self.nameDialog:textinput(text) end
    if self.descDialog then self.descDialog:textinput(text) end
end

return CreatureEditorScreen
