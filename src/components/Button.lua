local Component = require("compose.src.core.Component")

local Button = Component:new()
Button.__index = Button

--- Creates a new Button instance.
--- @param props table A table of properties for the component.
--- @return table A new Button instance.
function Button:new(props)
  local instance = Component:new(props)
  setmetatable(instance, self)
  instance.textColor = props.textColor
  instance.textScale = props.textScale or 1

  local textContent = "[" .. tostring(props.text or "") .. "]"
  instance.width = #textContent * (instance.textScale or 1)
  instance.height = 1 * (instance.textScale or 1)

  return instance
end

--- Draws the component on the screen.
--- @param x number The x coordinate to draw at.
--- @param y number The y coordinate to draw at.
--- @param monitor table The monitor to draw on.
--- @param availableWidth number The available width for the component.
--- @param availableHeight number The available height for the component.
--- @return number, number, number, number The x, y, width, and height of the component.
function Button:draw(x, y, monitor, availableWidth, availableHeight)
  self.x = x
  self.y = y
  local text = self.props.text or ""

  local modifier = self.modifier or {properties = {}}

  self.width = (modifier.properties.fillMaxWidth and availableWidth) or self.width
  self.height = (modifier.properties.fillMaxHeight and availableHeight) or self.height

  local originalBackgroundColor = monitor.getBackgroundColor()
  local originalTextColor = monitor.getTextColor()

  local effectiveBackground = self.backgroundColor or modifier.properties.backgroundColor
  local effectiveTextColor = self.textColor or modifier.properties.textColor

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

  local buttonText = "[" .. text .. "]"
  if #buttonText > self.width then
    buttonText = string.sub(buttonText, 1, self.width)
  end

  local textX = x + math.floor((self.width - #buttonText) / 2)
  local textY = y + math.floor((self.height - 1) / 2)

  monitor.setCursorPos(textX, textY)
  monitor.write(buttonText)

  monitor.setBackgroundColor(originalBackgroundColor)
  monitor.setTextColor(originalTextColor)

  if self.onDrawn then
    self:onDrawn(self)
  end

  return self.x, self.y, self.width, self.height
end

--- Handles a click event on the component.
--- @param x number The x coordinate of the click.
--- @param y number The y coordinate of the click.
function Button:onClick(x, y)
  if self.props.onClick then
    self.props.onClick()
  end
end

--- Returns the size of the component.
--- @return table A table containing the width and height of the component.
function Button:getSize()
  return { width = self.width, height = self.height }
end

return Button