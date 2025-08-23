--- @class Modifier
--- A chainable object used to apply styling and behavior to a component.
--- @field properties table A table holding all the modifier properties.
--- @field properties.backgroundColor? number The background color of the component.
--- @field properties.padding? {left: number, top: number, right: number, bottom: number} The padding of the component.
--- @field properties.textScale? number The scale of the text.
--- @field properties.border? {width: number, color: number} The border properties.
--- @field properties.fillMaxWidth? boolean Whether the component should fill the maximum width.
--- @field properties.fillMaxHeight? boolean Whether the component should fill the maximum height.
--- @field properties.onClick? fun() The function to call when the component is clicked.
local Modifier = {}
Modifier.__index = Modifier

--- Creates a new Modifier instance.
--- @return Modifier A new, empty Modifier instance.
function Modifier:new()
  local instance = setmetatable({}, self)
  instance.properties = {}
  return instance
end

--- Sets the background color of the component.
--- @param color number The background color.
--- @return Modifier The Modifier instance for chaining.
function Modifier:background(color)
  self.properties.backgroundColor = color
  return self
end

--- Sets the padding of the component.
--- Can be called with 1, 2, or 4 arguments.
--- * 1 argument: all sides will have the same padding.
--- * 2 arguments: left/right and top/bottom padding.
--- * 4 arguments: left, top, right, and bottom padding respectively.
--- @param left number The padding for all sides, or the left padding.
--- @param top? number The top and bottom padding.
--- @param right? number The right padding.
--- @param bottom? number The bottom padding.
--- @return Modifier The Modifier instance for chaining.
function Modifier:padding(left, top, right, bottom)
  if type(left) == "number" and top == nil then
    self.properties.padding = {left = left, top = left, right = left, bottom = left}
  elseif type(left) == "number" and type(top) == "number" and right == nil then
    self.properties.padding = {left = left, top = top, right = left, bottom = top}
  elseif type(left) == "number" and type(top) == "number" and type(right) == "number" and type(bottom) == "number" then
    self.properties.padding = {left = left, top = top, right = right, bottom = bottom}
  else
    -- Default to 0 padding if arguments are invalid
    self.properties.padding = {left = 0, top = 0, right = 0, bottom = 0}
  end
  return self
end

--- Sets the text scale of the component.
--- @param scale number The text scale factor.
--- @return Modifier The Modifier instance for chaining.
function Modifier:textScale(scale)
  self.properties.textScale = scale
  return self
end

--- Sets the border of the component.
--- @param width number The width of the border in characters.
--- @param color number The color of the border.
--- @return Modifier The Modifier instance for chaining.
function Modifier:border(width, color)
  self.properties.border = {width = width, color = color}
  return self
end

--- Makes the component fill the available width.
--- @return Modifier The Modifier instance for chaining.
function Modifier:fillMaxWidth()
  self.properties.fillMaxWidth = true
  return self
end

--- Makes the component fill the available height.
--- @return Modifier The Modifier instance for chaining.
function Modifier:fillMaxHeight()
  self.properties.fillMaxHeight = true
  return self
end

--- Makes the component fill the available width and height.
--- @return Modifier The Modifier instance for chaining.
function Modifier:fillMaxSize()
  self.properties.fillMaxWidth = true
  self.properties.fillMaxHeight = true
  return self
end

--- Makes the component clickable.
--- @param onClick fun() The function to execute when the component is clicked.
--- @return Modifier The Modifier instance for chaining.
function Modifier:clickable(onClick)
  self.properties.onClick = onClick
  return self
end

return Modifier