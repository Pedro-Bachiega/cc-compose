local Modifier = {}
Modifier.__index = Modifier

--- Creates a new Modifier instance.
--- @return table A new Modifier instance.
function Modifier:new()
  local instance = setmetatable({}, self)
  instance.properties = {}
  return instance
end

--- Sets the background color of the component.
--- @param color number The color to set.
--- @return table The Modifier instance for chaining.
function Modifier:background(color)
  self.properties.backgroundColor = color
  return self
end

--- Sets the padding of the component.
--- @param left number The left padding.
--- @param top number The top padding.
--- @param right number The right padding.
--- @param bottom number The bottom padding.
--- @return table The Modifier instance for chaining.
function Modifier:padding(left, top, right, bottom)
  if type(left) == "number" and top == nil then
    self.properties.padding = {left = left, top = left, right = left, bottom = left}
  elseif type(left) == "number" and type(top) == "number" and right == nil then
    self.properties.padding = {left = left, top = top, right = left, bottom = top}
  elseif type(left) == "number" and type(top) == "number" and type(right) == "number" and type(bottom) == "number" then
    self.properties.padding = {left = left, top = top, right = right, bottom = bottom}
  else
    self.properties.padding = {left = 0, top = 0, right = 0, bottom = 0}
  end
  return self
end

--- Sets the text scale of the component.
--- @param scale number The text scale to set.
--- @return table The Modifier instance for chaining.
function Modifier:textScale(scale)
  self.properties.textScale = scale
  return self
end

--- Sets the border of the component.
--- @param width number The width of the border.
--- @param color number The color of the border.
--- @return table The Modifier instance for chaining.
function Modifier:border(width, color)
  self.properties.border = {width = width, color = color}
  return self
end

--- Makes the component fill the maximum width available.
--- @return table The Modifier instance for chaining.
function Modifier:fillMaxWidth()
  self.properties.fillMaxWidth = true
  return self
end

--- Makes the component fill the maximum height available.
--- @return table The Modifier instance for chaining.
function Modifier:fillMaxHeight()
  self.properties.fillMaxHeight = true
  return self
end

--- Makes the component fill the maximum size available.
--- @return table The Modifier instance for chaining.
function Modifier:fillMaxSize()
  self.properties.fillMaxWidth = true
  self.properties.fillMaxHeight = true
  return self
end

return Modifier