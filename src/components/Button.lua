local Component = require("compose.src.core.Component")

--- @class Button : Component
--- A clickable button component.
--- @field textColor? number The color of the button text.
--- @field textScale? number The scale of the button text.
local Button = Component:new()
Button.__index = Button

--- Creates a new Button instance.
--- @param props table A table of properties for the component.
--- @param props.padding? number The padding around the button.
--- @param props.text? string The text to display on the button.
--- @param props.textColor? number The color of the button text.
--- @param props.textScale? number The scale of the button text.
--- @param props.onClick? fun() A function to call when the button is clicked.
--- @param props.modifier? Modifier A Modifier instance to apply to the component.
--- @return Button A new Button instance.
function Button:new(props)
  --- @class Button : Component
  local instance = Component:new(props)
  setmetatable(instance, self)
  instance.padding = props.padding or 0
  instance.backgroundColor = props.backgroundColor or colors.white
  instance.textColor = props.textColor or colors.black
  instance.textScale = props.textScale or 1

  local textContent = "[" .. tostring(props.text or "") .. "]"
  instance.width = (#textContent * (instance.textScale or 1)) + (instance.padding * 2)
  instance.height = (instance.textScale or 1) + (instance.padding * 2)

  return instance
end

--- Draws the component on the screen.
--- @param x number The x coordinate to draw at.
--- @param y number The y coordinate to draw at.
--- @param monitor table The monitor to draw on.
--- @param availableWidth number The available width for the component.
--- @param availableHeight number The available height for the component.
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
    for row = y - self.padding, y + self.height + self.padding - 1 do
      monitor.setCursorPos(x - self.padding, row)
      monitor.write(string.rep(" ", self.width + self.padding * 2))
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
--- @return {width: number, height: number} A table containing the width and height of the component.
function Button:getSize()
  return { width = self.width, height = self.height }
end

return Button