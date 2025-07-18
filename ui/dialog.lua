local Button = require("ui.button")

local Dialog = {}
Dialog.__index = Dialog

function Dialog:new(title, initialText, onConfirm, onCancel)
    local instance = setmetatable({}, Dialog)
    instance.title = title or "Dialog"
    instance.inputText = initialText or ""
    instance.onConfirm = onConfirm or function() end
    instance.onCancel = onCancel or function() end
    instance.visible = false
    instance.okButton = nil
    instance.cancelButton = nil

    -- Dialog dimensions
    instance.width = 400
    instance.height = 150

    -- Cursor blinking
    instance.cursorTimer = 0
    instance.cursorVisible = true

    return instance
end

function Dialog:show()
    self.visible = true
    self:createButtons()
end

function Dialog:hide()
    self.visible = false
    self.okButton = nil
    self.cancelButton = nil
end

function Dialog:createButtons()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    local dialogX = (windowWidth - self.width) / 2
    local dialogY = (windowHeight - self.height) / 2
    local buttonFont = love.graphics.newFont(12)

    self.okButton = Button:new(dialogX + self.width - 140, dialogY + self.height - 40, 60, 25, "OK", function()
        self.onConfirm(self.inputText)
        self:hide()
    end, buttonFont)

    self.cancelButton = Button:new(dialogX + self.width - 70, dialogY + self.height - 40, 60, 25, "Cancel", function()
        self.onCancel()
        self:hide()
    end, buttonFont)
end

function Dialog:update(dt)
    if not self.visible then return end

    -- Update cursor blinking
    self.cursorTimer = self.cursorTimer + dt
    if self.cursorTimer >= 0.5 then -- Blink every 0.5 seconds
        self.cursorVisible = not self.cursorVisible
        self.cursorTimer = 0
    end

    if self.okButton then self.okButton:update(dt) end
    if self.cancelButton then self.cancelButton:update(dt) end
end

function Dialog:draw()
    if not self.visible then return end

    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    local dialogX = (windowWidth - self.width) / 2
    local dialogY = (windowHeight - self.height) / 2

    -- Dialog background
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", dialogX, dialogY, self.width, self.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", dialogX, dialogY, self.width, self.height)

    -- Dialog title
    love.graphics.setFont(love.graphics.newFont(16))
    local titleWidth = love.graphics.getFont():getWidth(self.title)
    local titleX = dialogX + (self.width - titleWidth) / 2
    local titleY = dialogY + 20
    love.graphics.print(self.title, titleX, titleY)

    -- Input field
    love.graphics.setFont(love.graphics.newFont(14))
    local inputX = dialogX + 20
    local inputY = dialogY + 60
    local inputWidth = self.width - 40
    local inputHeight = 25

    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", inputX, inputY, inputWidth, inputHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", inputX, inputY, inputWidth, inputHeight)
    love.graphics.print(self.inputText, inputX + 5, inputY + 5)

    -- Draw blinking cursor
    if self.cursorVisible then
        local textWidth = love.graphics.getFont():getWidth(self.inputText)
        local cursorX = inputX + 5 + textWidth
        local cursorY = inputY + 3
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", cursorX, cursorY, 1, inputHeight - 6)
    end

    -- Draw buttons
    if self.okButton then self.okButton:draw() end
    if self.cancelButton then self.cancelButton:draw() end
end

function Dialog:mousepressed(x, y, button)
    if not self.visible then return end

    if button == 1 then -- Left mouse button
        if self.okButton then self.okButton:mousepressed(button) end
        if self.cancelButton then self.cancelButton:mousepressed(button) end
    end
end

function Dialog:keypressed(key)
    if not self.visible then return end

    if key == "return" then
        -- Confirm input
        if self.okButton then
            self.okButton.callback()
        end
    elseif key == "escape" then
        -- Cancel input
        if self.cancelButton then
            self.cancelButton.callback()
        end
    elseif key == "backspace" then
        self.inputText = self.inputText:sub(1, -2)
        -- Reset cursor blink when deleting
        self.cursorTimer = 0
        self.cursorVisible = true
    end
end

function Dialog:textinput(text)
    if not self.visible then return end
    self.inputText = self.inputText .. text
    -- Reset cursor blink when typing
    self.cursorTimer = 0
    self.cursorVisible = true
end

function Dialog:setTitle(title)
    self.title = title
end

function Dialog:setText(text)
    self.inputText = text
end

function Dialog:isVisible()
    return self.visible
end

return Dialog
