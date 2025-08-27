local Component = require("compose.src.core.Component")

--- @class Button : Component
--- A clickable button component.
--- @field textColor? number The color of the button text.
--- @field textScale? number The scale of the button text.
local Button = Component:new("Button", {})
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
  local instance = Component:new("Button", props)
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
--- @return table<fun()> The LaunchedEffect callback functions.
function Button:draw(x, y, monitor, availableWidth, availableHeight)
  self.x = x
  self.y = y
  local text = self.props.text or ""

  local modifier = self.modifier or {properties = {}}
  local padding = modifier.properties.padding or {left = 0, top = 0, right = 0, bottom = 0}
  local border = modifier.properties.border or {width = 0, color = nil}

  self.width = (modifier.properties.fillMaxWidth and availableWidth) or self.width
  self.height = (modifier.properties.fillMaxHeight and availableHeight) or self.height

  local originalBackgroundColor = monitor.getBackgroundColor()
  local originalTextColor = monitor.getTextColor()

  local effectiveBackground = self.backgroundColor or modifier.properties.backgroundColor
  local effectiveTextColor = self.textColor or modifier.properties.textColor

  -- Calculate inner drawing area for content (text)
  local innerX = x + padding.left + border.width
  local innerY = y + padding.top + border.width
  local innerWidth = self.width - padding.left - padding.right - (border.width * 2)
  local innerHeight = self.height - padding.top - padding.bottom - (border.width * 2)

  if effectiveBackground then
    monitor.setBackgroundColor(effectiveBackground)
    -- Draw background within the component's calculated bounds (self.width, self.height)
    for row = y, y + self.height - 1 do
      monitor.setCursorPos(x, row)
      monitor.write(string.rep(" ", self.width))
    end
  end

  if effectiveTextColor then
    monitor.setTextColor(effectiveTextColor)
  end

  local buttonText = "[" .. text .. "]"
  -- Truncate buttonText based on innerWidth
  if #buttonText > innerWidth then
    buttonText = string.sub(buttonText, 1, innerWidth)
  end

  local textX = innerX + math.floor((innerWidth - #buttonText) / 2)
  local textY = innerY + math.floor((innerHeight - 1) / 2)

  monitor.setCursorPos(textX, textY)
  monitor.write(buttonText)

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