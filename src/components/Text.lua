local Component = require("compose.src.core.Component")

local Text = Component:new()
Text.__index = Text

function Text:new(props)
  local instance = Component:new(props)
  setmetatable(instance, self)
  instance.textColor = props.textColor
  instance.textScale = props.textScale or 1

  -- Intrinsic size based on text content, will be overridden by modifiers
  local textContent = tostring(props.text or "")
  instance.width = #textContent * (instance.textScale or 1)
  instance.height = 1 * (instance.textScale or 1)
  
  return instance
end

function Text:draw(x, y, monitor, availableWidth, availableHeight)
  self.x = x
  self.y = y
  local text = self.props.text or ""

  local modifier = self.modifier or {properties = {}}

  -- Determine final size based on modifiers and available space
  self.width = (modifier.properties.fillMaxWidth and availableWidth) or self.width
  self.height = (modifier.properties.fillMaxHeight and availableHeight) or self.height

  local originalBackgroundColor = monitor.getBackgroundColor()
  local originalTextColor = monitor.getTextColor()

  local effectiveBackgroundColor = self.backgroundColor or modifier.properties.backgroundColor
  local effectiveTextColor = self.textColor or modifier.properties.textColor

  -- Draw background
  if effectiveBackgroundColor then
    monitor.setBackgroundColor(effectiveBackgroundColor)
    for row = y, y + self.height - 1 do
      monitor.setCursorPos(x, row)
      monitor.write(string.rep(" ", self.width))
    end
  end
  
  if effectiveTextColor then
    monitor.setTextColor(effectiveTextColor)
  end

  monitor.setCursorPos(x, y)
  -- Truncate text if it exceeds the component's width
  local truncatedText = text
  if #text > self.width then
    truncatedText = string.sub(text, 1, self.width)
  end
  monitor.write(truncatedText)

  -- Restore original colors
  monitor.setBackgroundColor(originalBackgroundColor)
  monitor.setTextColor(originalTextColor)

  if self.onDrawn then
    self:onDrawn(self)
  end

  return self.x, self.y, self.width, self.height
end

function Text:getSize()
  return { width = self.width, height = self.height }
end

return Text
