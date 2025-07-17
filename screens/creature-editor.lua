-- Creature Editor Screen - Create and edit custom Game of Life patterns
local Config = require("engine.config")
local State = require("engine.state")
local ScreenManager = require("engine.screen-manager")
local GameScreen = require("engine.game-screen")

local CreatureEditorScreen = GameScreen:new()

function CreatureEditorScreen:enter()
    love.window.setTitle("Conway's Game of Life - Creature Editor")

    -- Initialize editor state
    self.editorGrid = {}
    self.creatureName = ""
    self.creatureDescription = ""
    self.showNameInput = false
    self.inputText = ""
    self.inputMode = "name" -- "name" or "description"

    -- Initialize empty grid
    self:clearGrid()
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
    -- Editor doesn't need continuous updates
end

function CreatureEditorScreen:draw()
    -- Clear background
    love.graphics.clear(0.05, 0.05, 0.15)

    -- Draw grid
    self:drawGrid()

    -- Draw UI
    self:drawUI()

    -- Draw input dialog if active
    if self.showNameInput then
        self:drawInputDialog()
    end
end

function CreatureEditorScreen:drawGrid()
    for x = 1, Config.gridWidth do
        for y = 1, Config.gridHeight do
            local screenX = (x - 1) * Config.cellSize
            local screenY = (y - 1) * Config.cellSize

            if self.editorGrid[x][y] then
                love.graphics.setColor(0.9, 0.9, 0.9) -- Light gray for alive cells
                love.graphics.rectangle("fill", screenX, screenY, Config.cellSize, Config.cellSize)
            else
                love.graphics.setColor(0.2, 0.2, 0.2) -- Dark gray for dead cells
                love.graphics.rectangle("line", screenX, screenY, Config.cellSize, Config.cellSize)
            end
        end
    end
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
    love.graphics.print("Click to toggle cells | Name: " .. self.creatureName, 10, uiY)

    -- Buttons
    local buttonY = uiY
    local buttonHeight = 25
    local buttonSpacing = 10

    -- Clear button
    local clearButton = { x = 10, y = buttonY + 20, width = 60, height = buttonHeight }
    local mouseX, mouseY = love.mouse.getPosition()
    local clearHovered = self:isPointInRect(mouseX, mouseY, clearButton.x, clearButton.y, clearButton.width,
        clearButton.height)

    love.graphics.setFont(love.graphics.newFont(12))
    self:drawButton(clearButton.x, clearButton.y, clearButton.width, clearButton.height, "Clear", clearHovered)

    -- Set Name button
    local nameButton = {
        x = clearButton.x + clearButton.width + buttonSpacing,
        y = buttonY + 20,
        width = 80,
        height =
            buttonHeight
    }
    local nameHovered = self:isPointInRect(mouseX, mouseY, nameButton.x, nameButton.y, nameButton.width,
        nameButton.height)
    self:drawButton(nameButton.x, nameButton.y, nameButton.width, nameButton.height, "Set Name", nameHovered)

    -- Set Description button
    local descButton = {
        x = nameButton.x + nameButton.width + buttonSpacing,
        y = buttonY + 20,
        width = 100,
        height =
            buttonHeight
    }
    local descHovered = self:isPointInRect(mouseX, mouseY, descButton.x, descButton.y, descButton.width,
        descButton.height)
    self:drawButton(descButton.x, descButton.y, descButton.width, descButton.height, "Set Description", descHovered)

    -- Save button
    local saveButton = {
        x = descButton.x + descButton.width + buttonSpacing,
        y = buttonY + 20,
        width = 60,
        height =
            buttonHeight
    }
    local saveHovered = self:isPointInRect(mouseX, mouseY, saveButton.x, saveButton.y, saveButton.width,
        saveButton.height)
    local canSave = self.creatureName ~= "" and self:hasPattern()

    if canSave then
        self:drawButton(saveButton.x, saveButton.y, saveButton.width, saveButton.height, "Save", saveHovered)
    else
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", saveButton.x, saveButton.y, saveButton.width, saveButton.height)
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.rectangle("line", saveButton.x, saveButton.y, saveButton.width, saveButton.height)
        love.graphics.print("Save", saveButton.x + 20, saveButton.y + 6)
    end

    -- Back button
    local backButton = { x = windowWidth - 70, y = buttonY + 20, width = 60, height = buttonHeight }
    local backHovered = self:isPointInRect(mouseX, mouseY, backButton.x, backButton.y, backButton.width,
        backButton.height)
    self:drawButton(backButton.x, backButton.y, backButton.width, backButton.height, "Back", backHovered)

    -- Store button coordinates for click detection
    self.buttons = {
        clear = clearButton,
        name = nameButton,
        description = descButton,
        save = saveButton,
        back = backButton
    }
end

function CreatureEditorScreen:drawInputDialog()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    -- Dialog background
    local dialogWidth = 400
    local dialogHeight = 150
    local dialogX = (windowWidth - dialogWidth) / 2
    local dialogY = (windowHeight - dialogHeight) / 2

    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", dialogX, dialogY, dialogWidth, dialogHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", dialogX, dialogY, dialogWidth, dialogHeight)

    -- Dialog title
    love.graphics.setFont(love.graphics.newFont(16))
    local title = self.inputMode == "name" and "Enter Creature Name" or "Enter Creature Description"
    local titleX, titleY = self:centerText(title, love.graphics.getFont(), dialogY + 20)
    love.graphics.print(title, titleX, titleY)

    -- Input field
    love.graphics.setFont(love.graphics.newFont(14))
    local inputX = dialogX + 20
    local inputY = dialogY + 60
    local inputWidth = dialogWidth - 40
    local inputHeight = 25

    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", inputX, inputY, inputWidth, inputHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", inputX, inputY, inputWidth, inputHeight)
    love.graphics.print(self.inputText, inputX + 5, inputY + 5)

    -- Buttons
    local okButton = { x = dialogX + dialogWidth - 140, y = dialogY + dialogHeight - 40, width = 60, height = 25 }
    local cancelButton = { x = dialogX + dialogWidth - 70, y = dialogY + dialogHeight - 40, width = 60, height = 25 }

    local mouseX, mouseY = love.mouse.getPosition()
    local okHovered = self:isPointInRect(mouseX, mouseY, okButton.x, okButton.y, okButton.width, okButton.height)
    local cancelHovered = self:isPointInRect(mouseX, mouseY, cancelButton.x, cancelButton.y, cancelButton.width,
        cancelButton.height)

    love.graphics.setFont(love.graphics.newFont(12))
    self:drawButton(okButton.x, okButton.y, okButton.width, okButton.height, "OK", okHovered)
    self:drawButton(cancelButton.x, cancelButton.y, cancelButton.width, cancelButton.height, "Cancel", cancelHovered)

    -- Store dialog button coordinates
    self.dialogButtons = {
        ok = okButton,
        cancel = cancelButton
    }
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
        if self.showNameInput then
            -- Handle dialog clicks
            if self.dialogButtons then
                if self:isPointInRect(x, y, self.dialogButtons.ok.x, self.dialogButtons.ok.y,
                        self.dialogButtons.ok.width, self.dialogButtons.ok.height) then
                    -- OK button
                    if self.inputMode == "name" then
                        self.creatureName = self.inputText
                    else
                        self.creatureDescription = self.inputText
                    end
                    self.showNameInput = false
                    self.inputText = ""
                elseif self:isPointInRect(x, y, self.dialogButtons.cancel.x, self.dialogButtons.cancel.y,
                        self.dialogButtons.cancel.width, self.dialogButtons.cancel.height) then
                    -- Cancel button
                    self.showNameInput = false
                    self.inputText = ""
                end
            end
        else
            -- Handle main screen clicks
            if self.buttons then
                if self:isPointInRect(x, y, self.buttons.clear.x, self.buttons.clear.y,
                        self.buttons.clear.width, self.buttons.clear.height) then
                    self:clearGrid()
                elseif self:isPointInRect(x, y, self.buttons.name.x, self.buttons.name.y,
                        self.buttons.name.width, self.buttons.name.height) then
                    self.inputMode = "name"
                    self.inputText = self.creatureName
                    self.showNameInput = true
                elseif self:isPointInRect(x, y, self.buttons.description.x, self.buttons.description.y,
                        self.buttons.description.width, self.buttons.description.height) then
                    self.inputMode = "description"
                    self.inputText = self.creatureDescription
                    self.showNameInput = true
                elseif self:isPointInRect(x, y, self.buttons.save.x, self.buttons.save.y,
                        self.buttons.save.width, self.buttons.save.height) then
                    if self.creatureName ~= "" and self:hasPattern() then
                        local success, message = self:saveCreature()
                        print(message) -- You could show this in a popup later
                    end
                elseif self:isPointInRect(x, y, self.buttons.back.x, self.buttons.back.y,
                        self.buttons.back.width, self.buttons.back.height) then
                    ScreenManager:switchTo("main_menu")
                end
            end

            -- Handle grid clicks
            if not self.showNameInput then
                local gridX = math.floor(x / Config.cellSize) + 1
                local gridY = math.floor(y / Config.cellSize) + 1

                if gridX >= 1 and gridX <= Config.gridWidth and gridY >= 1 and gridY <= Config.gridHeight then
                    self.editorGrid[gridX][gridY] = not self.editorGrid[gridX][gridY]
                end
            end
        end
    end
end

function CreatureEditorScreen:keypressed(key)
    if self.showNameInput then
        if key == "return" then
            -- Confirm input
            if self.inputMode == "name" then
                self.creatureName = self.inputText
            else
                self.creatureDescription = self.inputText
            end
            self.showNameInput = false
            self.inputText = ""
        elseif key == "escape" then
            -- Cancel input
            self.showNameInput = false
            self.inputText = ""
        elseif key == "backspace" then
            self.inputText = self.inputText:sub(1, -2)
        end
    else
        if key == "escape" or key == "m" then
            ScreenManager:switchTo("main_menu")
        elseif key == "c" then
            self:clearGrid()
        end
    end
end

function CreatureEditorScreen:textinput(text)
    if self.showNameInput then
        self.inputText = self.inputText .. text
    end
end

return CreatureEditorScreen
