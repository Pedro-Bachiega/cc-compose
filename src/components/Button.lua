local Component = require("compose.src.core.Component")

local Button = Component:new()
Button.__index = Button

function Button:new(props)
  local instance = Component:new(props)
  setmetatable(instance, self)
  instance.textColor = props.textColor
  instance.textScale = props.textScale or 1

  -- Intrinsic size based on text content, will be overridden by modifiers
  local textContent = "[" .. tostring(props.text or "") .. "]"
  instance.width = #textContent * (instance.textScale or 1)
  instance.height = 1 * (instance.textScale or 1)

  return instance
end

function Button:draw(x, y, monitor, availableWidth, availableHeight)
  self.x = x
  self.y = y
  local text = self.props.text or ""

  local modifier = self.modifier or {properties = {}}

  -- Determine final size based on modifiers and available space
  self.width = (modifier.properties.fillMaxWidth and availableWidth) or self.width
  self.height = (modifier.properties.fillMaxHeight and availableHeight) or self.height

  local originalBackground = monitor.getBackgroundColor()
  local originalTextColor = monitor.getTextColor()

  local effectiveBackground = self.backgroundColor or modifier.properties.backgroundColor
  local effectiveTextColor = self.textColor or modifier.properties.textColor

  -- Draw background
  if effectiveBackground then
    monitor.setBackgroundColor(effectiveBackground)
    for row = y, y + self.height - 1 do
      monitor.setCursorPos(x, row)
      monitor.write(string.rep(" ", self.width))
    end
  end
  
  if effectiveTextColor then
    monitor.setTextColor(effectiveTextColor)
  end

  -- Center and truncate text
  local buttonText = "[" .. text .. "]"
  if #buttonText > self.width then
    buttonText = string.sub(buttonText, 1, self.width)
  end

  local textX = x + math.floor((self.width - #buttonText) / 2)
  local textY = y + math.floor((self.height - 1) / 2)

  monitor.setCursorPos(textX, textY)
  monitor.write(buttonText)

  -- Restore original colors
  monitor.setBackgroundColor(originalBackground)
  monitor.setTextColor(originalTextColor)

  if self.onDrawn then
    self:onDrawn(self)
  end

  return self.x, self.y, self.width, self.height
end

function Button:onClick(x, y)
  if self.props.onClick then
    self.props.onClick()
  end
end

function Button:getSize()
  return { width = self.width, height = self.height }
end

return Button
