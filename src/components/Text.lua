local Component = require("compose.src.core.Component")

--- @class Text : Component
--- A component for displaying text.
--- @field textColor? number The color of the text.
--- @field textScale? number The scale of the text.
local Text = Component:new()
Text.__index = Text

--- Creates a new Text instance.
--- @param props table A table of properties for the component.
--- @param props.text? string The text to display.
--- @param props.textColor? number The color of the text.
--- @param props.textScale? number The scale of the text.
--- @param props.modifier? Modifier A Modifier instance to apply to the component.
--- @return Text A new Text instance.
function Text:new(props)
  --- @class Text : Component
  local instance = Component:new(props)
  setmetatable(instance, self)
  instance.textColor = props.textColor or colors.white
  instance.textScale = props.textScale or 1

  local textContent = tostring(props.text or "")
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
--- @return table<fun()> The LaunchedEffect callback functions.
function Text:draw(x, y, monitor, availableWidth, availableHeight)
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

  monitor.setCursorPos(x, y)
  local truncatedText = text
  if #text > self.width then
    truncatedText = string.sub(text, 1, self.width)
  end
  monitor.write(truncatedText)

  monitor.setBackgroundColor(originalBackgroundColor)
  monitor.setTextColor(originalTextColor)

  if self.onDrawn then
    self:onDrawn()
  end

  if self.onLaunched then
    return {self.onLaunched}
  end

  return {}
end

--- Returns the size of the component.
--- @return {width: number, height: number} A table containing the width and height of the component.
function Text:getSize()
  return { width = self.width, height = self.height }
end

return Text