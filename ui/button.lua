local Button = {}
Button.__index = Button

function Button:new(x, y, width, height, text, callback, font)
    local instance = setmetatable({}, Button)
    instance.x = x
    instance.y = y
    instance.width = width
    instance.height = height
    instance.text = text or ""
    instance.callback = callback or function() end
    instance.font = font or love.graphics.newFont(24)
    instance.hovered = false
    instance.enabled = true
    return instance
end

function Button:draw()
    local previousFont = love.graphics.getFont()
    love.graphics.setFont(self.font)

    -- Draw button background
    if not self.enabled then
        love.graphics.setColor(0.3, 0.3, 0.3) -- Gray when disabled
    elseif self.hovered and self.enabled then
        love.graphics.setColor(0.3, 0.6, 0.9) -- Light blue when hovered
    else
        love.graphics.setColor(0.2, 0.4, 0.7) -- Dark blue normally
    end
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Draw button border
    if not self.enabled then
        love.graphics.setColor(0.6, 0.6, 0.6) -- Gray border when disabled
    else
        love.graphics.setColor(1, 1, 1)       -- White border when enabled
    end
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    -- Draw button text
    love.graphics.setColor(1, 1, 1) -- Always white text
    local textWidth = self.font:getWidth(self.text)
    local textHeight = self.font:getHeight()
    love.graphics.print(self.text,
        self.x + (self.width - textWidth) / 2,
        self.y + (self.height - textHeight) / 2)

    -- Restore previous font
    love.graphics.setFont(previousFont)
end

function Button:update(dt)
    if self.enabled then
        local mx, my = love.mouse.getPosition()
        self.hovered = (mx >= self.x and mx <= self.x + self.width and
            my >= self.y and my <= self.y + self.height)
    else
        self.hovered = false
    end
end

function Button:mousepressed(button)
    if button == 1 and self.hovered and self.enabled then
        self.callback()
    end
end

function Button:setEnabled(enabled)
    self.enabled = enabled
end

return Button
